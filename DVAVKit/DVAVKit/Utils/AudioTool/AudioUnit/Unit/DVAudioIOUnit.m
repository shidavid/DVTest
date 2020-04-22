//
//  DVAudioIOUnit.m
//  iOS_Test
//
//  Created by DV on 2019/1/11.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import "DVAudioIOUnit.h"
#import "DVAudioError.h"
#import "DVAudioUnit.h"

@interface DVAudioIOUnit() {
    @public
    AudioBufferList _bufferList;
}

@property(nonatomic, weak)  DVAudioUnit *wAudioUnit;
@property(nonatomic, assign) BOOL isShouldAllocateBufferStatus;

@property(nonatomic, strong) NSMutableArray<DVAudioPacket *> *packetBuffer;
@property(nonatomic, strong) dispatch_semaphore_t bufferLock;

@end


@implementation DVAudioIOUnit

static const int kInputBus = 1;
static const int kOutputBus = 0;

#pragma mark - <-- Instancetype -->
- (instancetype)init {
    self = [super init];
    if (self) {
        self.isShouldAllocateBufferStatus = YES;
    }
    return self;
}

- (void)dealloc {
    _wAudioUnit = nil;
    
    
}

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


#pragma mark - <-- Setter -->
// 为录制打开 IO
- (void)setInputPortStatus:(BOOL)inputPortStatus {
    UInt32 flag = inputPortStatus ? 1 : 0;
    OSStatus status = AudioUnitSetProperty([self audioUnit],
                                          kAudioOutputUnitProperty_EnableIO,
                                          kAudioUnitScope_Input,
                                          kInputBus,
                                          &flag,
                                          sizeof(flag));
    
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: set input port %@ error", inputPortStatus ? @"open" : @"close"]);
}

// 为播放打开 IO
- (void)setOutputPortStatus:(BOOL)outputPortStatus {
    UInt32 flag = outputPortStatus ? 1 : 0;
    OSStatus status = AudioUnitSetProperty([self audioUnit],
                                           kAudioOutputUnitProperty_EnableIO,
                                           kAudioUnitScope_Output,
                                           kOutputBus,
                                           &flag,
                                           sizeof(flag));
    
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: set output port %@ error", outputPortStatus ? @"open" : @"close"]);
}

// 设置格式
- (void)setAudioFormat:(AudioStreamBasicDescription)audioFormat {
    AudioStreamBasicDescription kFormat = audioFormat;
    OSStatus status = AudioUnitSetProperty([self audioUnit],
                                           kAudioUnitProperty_StreamFormat,
                                           kAudioUnitScope_Output,
                                           kInputBus,
                                           &kFormat,
                                           sizeof(kFormat));
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: set input audio format error"]);
    
    status = AudioUnitSetProperty([self audioUnit],
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &kFormat,
                                  sizeof(kFormat));
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: set output audio format error"]);
    
    _bufferList.mBuffers[0].mNumberChannels = kFormat.mChannelsPerFrame;
}


// 设置数据采集回调函数
- (void)setInputCallBackSwitch:(BOOL)inputCallBackSwitch {
    if (self.wAudioUnit.delegate == nil) {
        NSLog(@"[DVAudioIOUnit ERROR]: set input callback error -> \'AudioCoreUnit\' delegate is nil");
        return;
    }
    if (!( [self.wAudioUnit.delegate respondsToSelector:@selector(DVAudioUnit:recordData:error:)]
          ^[self.wAudioUnit.delegate respondsToSelector:@selector(DVAudioUnit:recordData:size:error:)] )) {
        NSLog(@"[DVAudioIOUnit ERROR]: set input callback error -> \'AudioCoreUnit\' delegate 中的 方法 \'DVAudioUnit:recordData:error:\' 和 方法\'DVAudioUnit:recordData:size:error:\' 同时实现 或者 都没实现,只能二选一");
        return;
    }
    
    
    AURenderCallback callBackMethod = [self.wAudioUnit.delegate respondsToSelector:@selector(DVAudioUnit:recordData:error:)] ? recordCallback : recordCallback_mData;
    
    AURenderCallbackStruct callbackStruct = {
        .inputProc = inputCallBackSwitch ? callBackMethod : NULL,
        .inputProcRefCon = inputCallBackSwitch ? (__bridge void* _Nullable)(self) : NULL,
    };
    
    OSStatus status = AudioUnitSetProperty([self audioUnit],
                                           kAudioOutputUnitProperty_SetInputCallback,
                                           kAudioUnitScope_Global,
                                           kInputBus,
                                           &callbackStruct,
                                           sizeof(callbackStruct));
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: set input callback error"]);
    
    _bufferList.mNumberBuffers = 1;
//    _bufferList.mBuffers[0].mNumberChannels = 1;
    _bufferList.mBuffers[0].mDataByteSize = 0;
    _bufferList.mBuffers[0].mData = NULL;
}

// 设置声音输出回调函数。当speaker需要数据时就会调用回调函数去获取数据。它是 "拉" 数据的概念
- (void)setOutputCallBackSwitch:(BOOL)outputCallBackSwitch {
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = outputCallBackSwitch ? playCallback : NULL;
    callbackStruct.inputProcRefCon = outputCallBackSwitch ? (__bridge void* _Nullable)(self) : NULL;
    
    OSStatus status = AudioUnitSetProperty([self audioUnit],
                                           kAudioUnitProperty_SetRenderCallback,
                                           kAudioUnitScope_Global,
                                           kOutputBus,
                                           &callbackStruct,
                                           sizeof(callbackStruct));
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: set output callback error"]);
}

- (void)setBypassVoiceProcessingStatus:(BOOL)bypassVoiceProcessingStatus {
    UInt32 flag = bypassVoiceProcessingStatus ? 0 : 1;
    OSStatus status = AudioUnitSetProperty([self audioUnit],
                                           kAUVoiceIOProperty_BypassVoiceProcessing,
                                           kAudioUnitScope_Global,
                                           kOutputBus,
                                           &flag,
                                           sizeof(flag));
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: set bypassVoiceProcessing error"]);
}

- (void)setShouldAllocateBufferStatus:(BOOL)shouldAllocateBufferStatus {
    // 关闭为录制分配的缓冲区（我们想使用我们自己分配的）
    self.isShouldAllocateBufferStatus = shouldAllocateBufferStatus;
    
    UInt32 flag = shouldAllocateBufferStatus ? 1 : 0;
    OSStatus status = AudioUnitSetProperty([self audioUnit],
                                           kAudioUnitProperty_ShouldAllocateBuffer,
                                           kAudioUnitScope_Output,
                                           kInputBus,
                                           &flag,
                                           sizeof(flag));
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: set auto allocate buffer error"]);
}



#pragma mark - <-- Getter -->
- (AudioUnit)audioUnit {
    return self.wAudioUnit.audioUnit;
}

- (BOOL)inputPortStatus {
    UInt32 flag;
    UInt32 size = sizeof(flag);
    OSStatus status = AudioUnitGetProperty([self audioUnit],
                                           kAudioOutputUnitProperty_EnableIO,
                                           kAudioUnitScope_Input,
                                           kInputBus,
                                           &flag,
                                           &size);
    
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: get input port error"]);
    return status != noErr ? NO : (flag != 0 ? YES : NO);
}

- (BOOL)outputPortStatus {
    UInt32 flag;
    UInt32 size = sizeof(flag);
    OSStatus status = AudioUnitGetProperty([self audioUnit],
                                           kAudioOutputUnitProperty_EnableIO,
                                           kAudioUnitScope_Output,
                                           kOutputBus,
                                           &flag,
                                           &size);
    
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: get output port error"]);
    return status != noErr ? NO : (flag != 0 ? YES : NO);
}

- (AudioStreamBasicDescription)audioFormat {
    AudioStreamBasicDescription kFormat;
    UInt32 size = sizeof(kFormat);
    OSStatus status = AudioUnitGetProperty([self audioUnit],
                                           kAudioUnitProperty_StreamFormat,
                                           kAudioUnitScope_Output,
                                           kInputBus,
                                           &kFormat,
                                           &size);
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: get audio format error"]);
    return kFormat;
}

- (BOOL)inputCallBackSwitch {
    AURenderCallbackStruct callbackStruct;
    UInt32 size = sizeof(callbackStruct);
    
    OSStatus status = AudioUnitGetProperty([self audioUnit],
                                           kAudioOutputUnitProperty_SetInputCallback,
                                           kAudioUnitScope_Global,
                                           kInputBus,
                                           &callbackStruct,
                                           &size);
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: get input callback error"]);
    
    return status != noErr ? NO : (callbackStruct.inputProcRefCon == NULL ? NO : YES);
}

- (BOOL)outputCallBackSwitch {
    AURenderCallbackStruct callbackStruct;
    UInt32 size = sizeof(callbackStruct);
    
    OSStatus status = AudioUnitGetProperty([self audioUnit],
                                           kAudioUnitProperty_SetRenderCallback,
                                           kAudioUnitScope_Global,
                                           kOutputBus,
                                           &callbackStruct,
                                           &size);
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: get output callback error"]);
    
    return status != noErr ? NO : (callbackStruct.inputProcRefCon == NULL ? NO : YES);
}

- (BOOL)bypassVoiceProcessingStatus {
    UInt32 flag;
    UInt32 size = sizeof(flag);
    OSStatus status = AudioUnitGetProperty([self audioUnit],
                                           kAUVoiceIOProperty_BypassVoiceProcessing,
                                           kAudioUnitScope_Global,
                                           kOutputBus,
                                           &flag,
                                           &size);
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: set bypassVoiceProcessing error"]);
    
    return status != noErr ? NO : (flag == 0 ? YES : NO);
}

- (BOOL)shouldAllocateBufferStatus {
    // 关闭为录制分配的缓冲区（我们想使用我们自己分配的）
    UInt32 flag;
    UInt32 size = sizeof(flag);
    OSStatus status = AudioUnitGetProperty([self audioUnit],
                                           kAudioUnitProperty_ShouldAllocateBuffer,
                                           kAudioUnitScope_Output,
                                           kInputBus,
                                           &flag,
                                           &size);
    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: set allocate buffer status error"]);
    
    return status != noErr ? NO : (flag ==  1 ? YES : NO);
}


#pragma mark - <-- Method -->
- (void)playAudioData:(uint8_t *)data size:(UInt32)size {
    dispatch_semaphore_wait(self.bufferLock, DISPATCH_TIME_FOREVER);
    DVAudioPacket *packet = [[DVAudioPacket alloc] initWithData:data size:size];
    [self.packetBuffer addObject:packet];
    dispatch_semaphore_signal(self.bufferLock);
}


#pragma mark - <-- CallBack -->
OSStatus recordCallback(void *inRefCon,
                        AudioUnitRenderActionFlags *ioActionFlags,
                        const AudioTimeStamp *inTimeStamp,
                        UInt32 inBusNumber,
                        UInt32 inNumberFrames,
                        AudioBufferList * ioData) {
    
    DVAudioIOUnit *object = (__bridge DVAudioIOUnit*)inRefCon;
    AudioBufferList *bufferList = &(object->_bufferList);
    
    if (object.isShouldAllocateBufferStatus == YES) {
        bufferList->mBuffers[0].mDataByteSize = 0;
        bufferList->mBuffers[0].mData = NULL;
    } else {
        bufferList->mBuffers[0].mDataByteSize = inNumberFrames*2;
        bufferList->mBuffers[0].mData = (UInt64 *)malloc(sizeof(UInt64) * inNumberFrames*2);
    }
    
  
    OSStatus status = AudioUnitRender([object audioUnit],
                                      ioActionFlags,
                                      inTimeStamp,
                                      inBusNumber,
                                      inNumberFrames,
                                      bufferList);

    // dataWithBytes会复制bytes的数据，NSData内存释放后，bytes内存没释放，所以要用dataWithBytesNoCopy
    NSData *data = [NSData dataWithBytesNoCopy:bufferList->mBuffers[0].mData
                                        length:bufferList->mBuffers[0].mDataByteSize
                                  freeWhenDone:NO];
    
    [object.wAudioUnit.delegate DVAudioUnit:object.wAudioUnit
                                 recordData:data
                                      error:status == noErr ? nil : [DVAudioError errorWithType:DVAudioError_notRecord]];
    
    
    if (object.isShouldAllocateBufferStatus == NO) {
        free(bufferList->mBuffers[0].mData);
        bufferList->mBuffers[0].mData = NULL;
    }
    
    return noErr;
}


OSStatus recordCallback_mData(void *inRefCon,
                              AudioUnitRenderActionFlags *ioActionFlags,
                              const AudioTimeStamp *inTimeStamp,
                              UInt32 inBusNumber,
                              UInt32 inNumberFrames,
                              AudioBufferList * ioData) {
    
    DVAudioIOUnit *object = (__bridge DVAudioIOUnit *)inRefCon;
    AudioBufferList *bufferList = &(object->_bufferList);
    
    if (object.isShouldAllocateBufferStatus == YES) {
        bufferList->mBuffers[0].mDataByteSize = 0;
        bufferList->mBuffers[0].mData = NULL;
    } else {
        bufferList->mBuffers[0].mDataByteSize = inNumberFrames*2;
        bufferList->mBuffers[0].mData = (UInt64 *)malloc(sizeof(UInt64) * inNumberFrames*2);
    }
    
    
    OSStatus status = AudioUnitRender([object audioUnit],
                                      ioActionFlags,
                                      inTimeStamp,
                                      inBusNumber,
                                      inNumberFrames,
                                      bufferList);
    
    [object.wAudioUnit.delegate DVAudioUnit:object.wAudioUnit
                                  recordData:bufferList->mBuffers[0].mData
                                        size:bufferList->mBuffers[0].mDataByteSize
                                       error:status == noErr ? nil : [DVAudioError errorWithType:DVAudioError_notRecord]];
    
    if (object.isShouldAllocateBufferStatus == NO) {
        free(bufferList->mBuffers[0].mData);
        bufferList->mBuffers[0].mData = NULL;
    }
    
    return noErr;
}


OSStatus playCallback(void *inRefCon,
                      AudioUnitRenderActionFlags *ioActionFlags,
                      const AudioTimeStamp *inTimeStamp,
                      UInt32 inBusNumber,
                      UInt32 inNumberFrames,
                      AudioBufferList * ioData) {
    
    DVAudioIOUnit *object = (__bridge DVAudioIOUnit*) inRefCon;
   
    dispatch_semaphore_wait(object.bufferLock, DISPATCH_TIME_FOREVER);
    
    if (object.packetBuffer.count > 0) {

        DVAudioPacket *packet = object.packetBuffer.firstObject;
        UInt32 ioSize = ioData->mBuffers[0].mDataByteSize;

        while (ioSize > 0) {
            UInt32 pktMaxSize = packet.mSize - packet.readIndex;

            if (ioSize <= pktMaxSize) {
                memcpy(ioData->mBuffers[0].mData, packet.mData+packet.readIndex, ioSize);

                if (ioSize == pktMaxSize) {
                    [object.packetBuffer removeObjectAtIndex:0];
                } else {
                    packet.readIndex += ioSize;
                }
                ioSize = 0;

                break;
            } else {
                memcpy(ioData->mBuffers[0].mData, packet.mData+packet.readIndex, pktMaxSize);
                ioSize -= pktMaxSize;
                [object.packetBuffer removeObjectAtIndex:0];

                if (object.packetBuffer.count > 0) {
                    packet = object.packetBuffer.firstObject;
                } else {
                    break;
                }
            }
        }

        if (ioSize > 0) {
            memset(ioData->mBuffers[0].mData + ioData->mBuffers[0].mDataByteSize - ioSize, 0, ioSize);
        }
    } else {
        memset(ioData->mBuffers[0].mData, 0, ioData->mBuffers[0].mDataByteSize);
    }

    dispatch_semaphore_signal(object.bufferLock);
    
    if (object.feedbackSwitch) {
        // 麦克风声音返回扬声器
        OSStatus status = AudioUnitRender([object audioUnit],
                                          ioActionFlags,
                                          inTimeStamp,
                                          kInputBus,
                                          inNumberFrames,
                                          ioData);
    }
    
    
//    AudioCheckStatus(status, [NSString stringWithFormat:@"[DVAudioIOUnit ERROR]: play callback error"]);

    return noErr;
}

@end
