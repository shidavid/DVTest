//
//  DVAudioQueue.m
//  iOS_Test
//
//  Created by DV on 2019/1/10.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import "DVAudioQueue.h"
#import <AudioToolbox/AudioToolbox.h>

const int kNumberBuffer = 3;

@interface DVAudioQueue () {
    @public
    AudioQueueRef _queueRef;                   //输出音频播放队列
    AudioQueueBufferRef _queueBufferRef[kNumberBuffer];    //输出音频播放缓存
    AudioStreamBasicDescription _basicDesc;
}

@property(nonatomic, assign) UInt32 bufferSize;
@property(nonatomic, assign) Float64 sampleTimeInterval;

@property(nonatomic, assign, readwrite) DVAudioQueueStatus status;
@property(nonatomic, assign, readwrite) BOOL isInput;

@property(nonatomic, strong) dispatch_semaphore_t bufferLock;

@end


@implementation DVAudioQueue

#pragma mark - <-- Initializer -->
- (instancetype)initInputQueueWithBasic:(AudioStreamBasicDescription)basicDesc
                     sampleTimeInterval:(Float64)sampleTimeInterval {
    self = [self init];
    if (self) {
        self.sampleTimeInterval = sampleTimeInterval;
        _isInput = YES;
        _basicDesc = basicDesc;
        [self initInputAudioQueue];
    }
    return self;
}

- (instancetype)initOutputQueueWithBasic:(AudioStreamBasicDescription)basicDesc
                              bufferSize:(UInt32)bufferSize {
    self = [self init];
    if (self) {
        self.bufferSize = bufferSize;
        _isInput = NO;
        _basicDesc = basicDesc;
        [self initOutputAudioQueue];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _status = DVAudioQueueStatusStop;
        self.sampleTimeInterval = 0.05;
    }
    return self;
}

- (void)dealloc {
    if (_queueRef) AudioQueueStop(_queueRef, YES);
    
    if (_queueBufferRef && _queueRef) {
        for (int i = 0; i<kNumberBuffer; ++i) {
            AudioQueueFreeBuffer(_queueRef, _queueBufferRef[i]);
            _queueBufferRef[i] = nil;
        }
    }
    
    if (_queueRef) {
        AudioQueueDispose(_queueRef, YES);
        _queueRef = NULL;
    }
}


#pragma mark - <-- Init -->
- (void)initInputAudioQueue {
    
    AudioStreamBasicDescription inFormat = _basicDesc;
   
    // 1.初始化音频输入队列
    OSStatus status;
    status = AudioQueueNewInput(&inFormat,
                                dv_inputCallbackHandler,
                                (__bridge void *)(self),
                                NULL,
                                kCFRunLoopCommonModes,
                                0,
                                &_queueRef);
    if (status != noErr) {
        NSLog(@"[DVAudioQueue ERROR]: 创建 Input AudioQueue 失败");
        return;
    }

    // 2.创建Buffer
    self.bufferSize = ((UInt32)ceil(inFormat.mSampleRate * self.sampleTimeInterval)) * inFormat.mBytesPerFrame;
    
    for (int i = 0; i < kNumberBuffer; ++i) {
        status = AudioQueueAllocateBuffer(_queueRef, self.bufferSize, &_queueBufferRef[i]);
        if (status != noErr) {
            NSLog(@"[DVAudioQueue ERROR]: create queue buffer failer -> index: %d", i);
            break;
        }
        
        status = AudioQueueEnqueueBuffer(_queueRef, _queueBufferRef[i], 0, NULL);
        if (status != noErr) {
            NSLog(@"[DVAudioQueue ERROR]: enqueue buffer error -> index: %d", i);
            break;
        }
    }
}

- (void)initOutputAudioQueue {
    
    AudioStreamBasicDescription outFormat = _basicDesc;
    
    // 1.初始化音频输出队列
    OSStatus status;
    status = AudioQueueNewOutput(&outFormat,
                                 dv_outputCallbackHandler,
                                 (__bridge void *)(self),
                                 NULL,
                                 NULL,
                                 0,
                                 &_queueRef);
    if (status != noErr) {
        NSLog(@"[DVAudioQueue ERROR]: 创建 Output AudioQueue 失败");
        return;
    }

    // 2.创建Buffer
    for (int i = 0; i < kNumberBuffer; ++i) {
        status = AudioQueueAllocateBuffer(_queueRef, self.bufferSize, &_queueBufferRef[i]);
        if (status != noErr) {
            NSLog(@"[DVAudioQueue ERROR]: create queue buffer failer -> index: %d", i);
            break;
        }
        
        _queueBufferRef[i]->mAudioDataByteSize = self.bufferSize;
        
        status = AudioQueueEnqueueBuffer(_queueRef, _queueBufferRef[i], 0, NULL);
        if (status != noErr) {
            NSLog(@"[DVAudioQueue ERROR]: enqueue buffer error -> index: %d", i);
            break;
        }
    }
}


#pragma mark - <-- Property -->
- (NSMutableArray<DVAudioPacket *> *)packetBuffer {
    if (!_packetBuffer) {
        _packetBuffer = [NSMutableArray array];
    }
    return _packetBuffer;
}

- (dispatch_semaphore_t)bufferLock {
    if (!_bufferLock) {
        _bufferLock = dispatch_semaphore_create(1);
    }
    return _bufferLock;
}


#pragma mark - <-- Method -->
- (BOOL)start {
    if (self.status == DVAudioQueueStatusStart) return NO;
    
    OSStatus status = AudioQueueStart(_queueRef, NULL);
    if (status != noErr) {
        return NO;
    }
    self.status = DVAudioQueueStatusStart;
    return YES;
}

- (BOOL)stop {
    if (self.status == DVAudioQueueStatusStop) return NO;
    
    OSStatus status = AudioQueueStop(_queueRef, YES);
    if (status != noErr) {
        return NO;
    }
    AudioQueueReset(_queueRef);
    
    self.status = DVAudioQueueStatusStop;
    return YES;
}

- (BOOL)pause {
    if (self.status == DVAudioQueueStatusPause || self.status == DVAudioQueueStatusStop) return NO;
    
    OSStatus status = AudioQueuePause(_queueRef);
    if (status != noErr) {
        return NO;
    }
    self.status = DVAudioQueueStatusPause;
    return YES;
}

- (void)playAudioData:(uint8_t *)data size:(UInt32)size userInfo:(void *)userInfo {
    dispatch_semaphore_wait(self.bufferLock, DISPATCH_TIME_FOREVER);
    DVAudioPacket *packet = [[DVAudioPacket alloc] initWithData:data size:size];
    if (userInfo) packet->_userInfo = userInfo;
    [self.packetBuffer addObject:packet];
    dispatch_semaphore_signal(self.bufferLock);
}


#pragma mark - <-- CallBack -->
void dv_inputCallbackHandler(void *inUserData,
                             AudioQueueRef inAQ,
                             AudioQueueBufferRef inBuffer,
                             const AudioTimeStamp *inStartTime,
                             UInt32 inNumberPacket,
                             const AudioStreamPacketDescription *inPacketDescs) {
    
    DVAudioQueue *audioQueue = (__bridge DVAudioQueue*)inUserData;
    if (audioQueue.status != DVAudioQueueStatusStart) return;
    
    
    if (inNumberPacket > 0) {
        if (audioQueue.delegate) {
            [audioQueue.delegate DVAudioQueue:audioQueue
                                   recordData:inBuffer->mAudioData
                                         size:inBuffer->mAudioDataByteSize];
        }
    }
    
    // 将buffer给audio queue
    OSStatus status = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    if (status != noErr) {
        NSLog(@"[DVAudioQueue ERROR]: record enqueue buffer failer -> status: %d", (int)status);
    }
}

void dv_outputCallbackHandler(void *inUserData,
                              AudioQueueRef outAQ,
                              AudioQueueBufferRef outBuffer) {

    DVAudioQueue *audioQueue = (__bridge DVAudioQueue*)inUserData;

    // 1.填充数据
    dispatch_semaphore_wait(audioQueue.bufferLock, DISPATCH_TIME_FOREVER);

    do {
        if (audioQueue.packetBuffer.count > 0) {

            DVAudioPacket *packet = audioQueue.packetBuffer.firstObject;
            if (audioQueue.delegate) {
                [audioQueue.delegate DVAudioQueue:audioQueue
                                     playbackData:packet.mData
                                             size:packet.mSize
                                         userInfo:packet->_userInfo];
            }
            
            UInt32 ioSize = audioQueue.bufferSize;

            while (ioSize > 0) {
                UInt32 pktMaxSize = packet.mSize - packet.readIndex;

                if (ioSize <= pktMaxSize) {
                    memcpy(outBuffer->mAudioData, packet.mData+packet.readIndex, ioSize);

                    if (ioSize == pktMaxSize) {
                        [audioQueue.packetBuffer removeObjectAtIndex:0];
                    } else {
                        packet.readIndex += ioSize;
                    }
                    ioSize = 0;

                    break;
                } else {
                    memcpy(outBuffer->mAudioData, packet.mData+packet.readIndex, pktMaxSize);
                    ioSize -= pktMaxSize;
                    [audioQueue.packetBuffer removeObjectAtIndex:0];

                    if (audioQueue.packetBuffer.count > 0) {
                        packet = audioQueue.packetBuffer.firstObject;
                    } else {
                        break;
                    }
                }
            }

            if (ioSize > 0) {
                memset(outBuffer->mAudioData + audioQueue.bufferSize - ioSize, 0, ioSize);
            }

        } else {
            memset(outBuffer->mAudioData, 0, audioQueue.bufferSize);
        }
        
        // 2.将buffer给audio queue
        OSStatus status = AudioQueueEnqueueBuffer(outAQ, outBuffer, 0, NULL);
        if (status != noErr) {
//            NSLog(@"[DVAudioQueue ERROR]: record enqueue buffer failer -> status: %d", (int)status);
        }
        
    } while (NO);

    dispatch_semaphore_signal(audioQueue.bufferLock);
}

@end
