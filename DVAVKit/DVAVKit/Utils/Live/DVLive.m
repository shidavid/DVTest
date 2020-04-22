//
//  DVLive.m
//  DVAVKit
//
//  Created by 施达威 on 2019/3/23.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVLive.h"
#import "DVVideoToolKit.h"
#import "DVAudioToolKit.h"
#import "DVFlvKit.h"
#import "DVRtmpKit.h"

@interface DVLive () < DVVideoCaptureDelegate,
                       DVAudioUnitDelegate,
                       DVVideoEncoderDelegate,
                       DVAudioEncoderDelegate,
                       DVRtmpDelegate,
                       DVRtmpBufferDelegate>

@property(nonatomic, strong, readwrite) DVVideoConfig *videoConfig;
@property(nonatomic, strong, readwrite) DVAudioConfig *audioConfig;

@property(nonatomic, strong, nullable) DVVideoCapture *videoCapture;
@property(nonatomic, strong, nullable) DVAudioUnit *audioUnit;
@property(nonatomic, strong, nullable) id<DVVideoEncoder> videoEncoder;
@property(nonatomic, strong, nullable) id<DVAudioEncoder> audioEncoder;
@property(nonatomic, strong, nullable) id<DVRtmp> rtmpSocket;

@property(nonatomic, strong) dispatch_semaphore_t videoEncoderLock;
@property(nonatomic, strong) dispatch_semaphore_t audioEncoderLock;

@property(nonatomic, assign, readwrite) DVLiveStatus liveStatus;
@property(nonatomic, assign, readwrite) BOOL isLiving;
@property(nonatomic, assign, readwrite) BOOL isRecording;

@property(nonatomic, strong) NSFileHandle *fileHandle;
@property(nonatomic, strong) dispatch_queue_t fileQueue;
@property(nonatomic, copy) NSString *recordPath;

@end


@implementation DVLive

#pragma mark - <-- Initializer -->
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initLock];
        [self initSession];
        [self initRtmpSocket];
    }
    return self;
}

- (void)dealloc {
     if (_videoCapture) {
        [_videoCapture stop];
        _videoCapture.delegate = nil;
        _videoCapture = nil;
    }
    
    if (_audioUnit) {
        [_audioUnit stop];
        _audioUnit.delegate = nil;
        _audioUnit = nil;
    }
    
    if (_videoEncoder) {
        [_videoEncoder closeEncoder];
        _videoEncoder.delegate = nil;
        _videoEncoder = nil;
    }
    
    if (_audioEncoder) {
        [_audioEncoder closeEncoder];
        _audioEncoder.delegate = nil;
        _audioEncoder = nil;
    }
    
    if (_rtmpSocket) {
        [_rtmpSocket disconnect];
        _rtmpSocket.delegate = nil;
        _rtmpSocket.bufferDelegate = nil;
        _rtmpSocket = nil;
    }
    
    if (_fileHandle) {
        dispatch_sync(self.fileQueue, ^{
            [_fileHandle closeFile];
            _fileHandle = nil;
        });
    }
}


#pragma mark - <-- Property -->
- (UIView *)preView {
    return self.videoCapture ? self.videoCapture.preView : nil;
}

- (DVVideoCapture *)camera {
    return self.videoCapture;
}

- (BOOL)isLiving {
    BOOL status = NO;
    if (self.videoCapture && self.audioUnit && self.rtmpSocket) {
        status = self.videoCapture.isRunning
                || self.audioUnit.isRunning
                || self.rtmpSocket.rtmpStatus == DVRtmpStatus_Connected;
    }
    return status;
}


- (dispatch_queue_t)fileQueue {
    if (!_fileQueue) {
        _fileQueue = dispatch_queue_create("com.dv.avkit.live.record", nil);
    }
    return _fileQueue;
}

- (NSFileHandle *)fileHandle {
    if (!_fileHandle && _recordPath) {
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_recordPath];
        [self.fileHandle seekToEndOfFile];
    }
    return _fileHandle;
}


#pragma mark - <-- Init -->
- (void)initLock {
    self.videoEncoderLock = dispatch_semaphore_create(1);
    self.audioEncoderLock = dispatch_semaphore_create(1);
}

- (void)initSession {
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [self printfError:error];
    
    [audioSession setActive:YES error:&error];
    [self printfError:error];
}

- (void)initRtmpSocket {
    self.rtmpSocket = [[DVRtmpSocket alloc] initWithDelegate:self];
    self.rtmpSocket.bufferDelegate = self;
}


#pragma mark - <-- Public Method -->
- (void)setVideoConfig:(DVVideoConfig *)videoConfig {
    if (self.isLiving) {
        [self printfLog:@"请先关闭推流和断开连接，再配置视频参数"];
        return;
    }
    
    _videoConfig = videoConfig;

    // 1.初始化摄像头
    if (!self.videoCapture) {
        self.videoCapture = [[DVVideoCapture alloc] initWithConfig:videoConfig delegate:self];
        [self.videoCapture updateCamera:^(DVVideoCamera * _Nonnull camera) {
            camera.stabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }];
    } else {
        [self.videoCapture updateConfig:videoConfig];
    }
    
    
    // 2.初始化视频编码器
    if (self.videoEncoder) {
        [self.videoEncoder closeEncoder];
        self.videoEncoder = nil;
    }
    self.videoEncoder = [self newVideoEncoderWithVideoConfig:videoConfig];
    
    
    // 3.设置rtmp头信息
    [self.rtmpSocket setMetaHeader:[self metaHeader]];
}

- (void)setAudioConfig:(DVAudioConfig *)audioConfig {
    if (self.isLiving) {
        [self printfLog:@"请先关闭推流和断开连接，再配置音频参数"];
        return;
    }
    
    _audioConfig = audioConfig;
    
    // 1.初始化录音
    if (!self.audioUnit) {
        AudioComponentDescription desc = [DVAudioComponentDesc kComponentDesc_Output_IO];
        NSError *error = nil;
        self.audioUnit = [[DVAudioUnit alloc] initWithComponentDesc:desc
                                                           delegate:self
                                                              error:&error];
        [self.audioUnit setupUnitConfig:^(DVAudioUnit * _Nonnull au) {
            au.IO.audioFormat = [DVAudioStreamBaseDesc pcmBasicDescWithConfig:audioConfig];
            au.IO.inputPortStatus = YES;
            au.IO.inputCallBackSwitch = YES;
            au.IO.outputPortStatus = YES;
            au.IO.bypassVoiceProcessingStatus = YES;
        }];
        
        [self printfError:error];
    } else {
        [self.audioUnit clearUnitConfig];
        [self.audioUnit setupUnitConfig:^(DVAudioUnit * _Nonnull au) {
            au.IO.audioFormat = [DVAudioStreamBaseDesc pcmBasicDescWithConfig:audioConfig];
            au.IO.inputPortStatus = YES;
            au.IO.inputCallBackSwitch = YES;
            au.IO.outputPortStatus = YES;
            au.IO.bypassVoiceProcessingStatus = YES;
        }];
    }
    
   
    // 2.初始化音频编码器
    if (self.audioEncoder) {
        [self.audioEncoder closeEncoder];
        self.audioEncoder = nil;
    }
    self.audioEncoder = [self newAudioEncoderWithAudioConfig:audioConfig];
    
    
    // 3.设置rtmp头信息
    [self.rtmpSocket setMetaHeader:[self metaHeader]];
    [self.rtmpSocket setAudioHeader:[self audioHeader]];
}

- (void)connectToURL:(NSString *)url {
    [self.rtmpSocket connectToURL:url];
}

- (void)disconnect {
    [self.rtmpSocket disconnect];
}

- (void)startLive {
    if (!_videoConfig || !_audioConfig) {
        [self printfLog:@"推流开启失败, 请先设置 VideoConfig 和 AudioConfig"];
        return;
    }
    
    if (self.videoCapture) [self.videoCapture start];
    if (self.audioUnit) [self.audioUnit start];
}

- (void)stopLive {
    if (!_videoConfig || !_audioConfig) {
        [self printfLog:@"推流关闭失败, 请先设置 VideoConfig 和 AudioConfig"];
        return;
    }
    
    if (self.videoCapture) [self.videoCapture stop];
    if (self.audioUnit) [self.audioUnit stop];
}

- (UIImage *)screenshot {
    return nil;
}

- (void)saveScreenshotToPhotoAlbum {
    
}

- (void)startRecordToURL:(NSString *)url {
    if (self.isRecording) {
        [self printfLog:@"正在录影中, 先停止录影"];
        return;
    }
    
    self.isRecording = YES;
}

- (void)startRecordToPhotoAlbum {
    if (self.isRecording) {
        [self printfLog:@"正在录影中, 先停止录影"];
        return;
    }
    
    self.isRecording = YES;
}

- (void)stopRecord {

}


#pragma mark - <-- Private Method -->
- (DVMetaFlvTagData *)metaHeader {
    if (!self.videoConfig || !self.audioConfig) return nil;
    
    DVMetaFlvTagData *tagData = [[DVMetaFlvTagData alloc] init];
    
    tagData.videoWidth = self.videoConfig.size.width;
    tagData.videoHeight = self.videoConfig.size.height;
    tagData.videoBitRate = self.videoConfig.bitRate;
    tagData.videoFps = self.videoConfig.fps;
    
    tagData.audioSampleRate = self.audioConfig.sampleRate;
    tagData.audioBits = self.audioConfig.bitsPerChannel;
    tagData.audioChannels = self.audioConfig.numberOfChannels;
    
    return tagData;
}

- (DVVideoFlvTagData *)videoHeaderWithVPS:(NSData *)vps sps:(NSData *)sps pps:(NSData *)pps {
    if (!self.videoConfig) return nil;
    
    DVVideoFlvTagData *tagData = nil;
    
    if (self.videoConfig.encoderType == DVVideoEncoderType_H264_Hardware) {
        DVAVCVideoPacket *packet = [DVAVCVideoPacket headerPacketWithSps:sps pps:pps];
        tagData = [DVVideoFlvTagData tagDataWithFrameType:DVVideoFlvTagFrameType_Key avcPacket:packet];
    }
    else if (self.videoConfig.encoderType == DVVideoEncoderType_HEVC_Hardware) {
        DVHEVCVideoPacket *packet = [DVHEVCVideoPacket headerPacketWithVps:vps sps:sps pps:pps];
        tagData = [DVVideoFlvTagData tagDataWithFrameType:DVVideoFlvTagFrameType_Key hevcPacket:packet];
    }
    
    return tagData;
}

- (DVAudioFlvTagData *)audioHeader {
    if (!self.audioConfig) return nil;
    
    DVAACAudioPacket *aacPacket = [DVAACAudioPacket headerPacketWithSampleRate:self.audioConfig.sampleRate
                                                                      channels:self.audioConfig.numberOfChannels];
    DVAudioFlvTagData *tagData = [DVAudioFlvTagData tagDataWithAACPacket:aacPacket];
    
    return tagData;
}

- (DVRtmpPacket *)videoPacketWithData:(NSData *)data
                           isKeyFrame:(BOOL)isKeyFrame
                            timeStamp:(uint64_t)timeStamp {
    
    DVRtmpPacket * packet = [[DVRtmpPacket alloc] init];
    packet.timeStamp = (uint32_t)timeStamp;
    
    DVVideoFlvTagFrameType frameType = isKeyFrame ? DVVideoFlvTagFrameType_Key : DVVideoFlvTagFrameType_NotKey;
    
    if (_videoConfig.encoderType == DVVideoEncoderType_H264_Hardware) {
        DVAVCVideoPacket *avcPacket = [DVAVCVideoPacket packetWithAVC:data timeStamp:0];
        packet.videoData = [DVVideoFlvTagData tagDataWithFrameType:frameType avcPacket:avcPacket];
    }
    else if (_videoConfig.encoderType == DVVideoEncoderType_HEVC_Hardware) {
        DVHEVCVideoPacket *hevcPacket = [DVHEVCVideoPacket packetWithHEVC:data timeStamp:0];
        packet.videoData = [DVVideoFlvTagData tagDataWithFrameType:frameType hevcPacket:hevcPacket];
    }
    
    return packet;
}

- (DVRtmpPacket *)audioPacketWithData:(NSData *)data
                            timeStamp:(uint64_t)timeStamp {
   
    DVRtmpPacket *packet = [[DVRtmpPacket alloc] init];
    packet.timeStamp = (uint32_t)timeStamp;
    
    DVAACAudioPacket *aacPacket = [DVAACAudioPacket packetWithAAC:data];
    packet.audioData = [DVAudioFlvTagData tagDataWithAACPacket:aacPacket];
       
    return packet;
}

- (id<DVVideoEncoder>)newVideoEncoderWithVideoConfig:(DVVideoConfig *)videoConfig {
    id<DVVideoEncoder> videoEncoder;
    
    if (videoConfig.encoderType == DVVideoEncoderType_H264_Hardware) {
        videoEncoder = [[DVVideoH264HardwareEncoder alloc] initWithConfig:videoConfig delegate:self];
    }
    else if (videoConfig.encoderType == DVVideoEncoderType_HEVC_Hardware) {
        videoEncoder = [[DVVideoHEVCHardwareEncoder alloc] initWithConfig:videoConfig delegate:self];
    }
    
    return videoEncoder;
}

- (id<DVAudioEncoder>)newAudioEncoderWithAudioConfig:(DVAudioConfig *)audioConfig {
    id<DVAudioEncoder> audioEncoder;
    
    AudioStreamBasicDescription inputDesc = [DVAudioStreamBaseDesc pcmBasicDescWithConfig:audioConfig];
    AudioStreamBasicDescription outputDesc = [DVAudioStreamBaseDesc aacBasicDescWithConfig:audioConfig];
    audioEncoder = [[DVAudioAACHardwareEncoder alloc] initWithInputBasicDesc:inputDesc
                                                             outputBasicDesc:outputDesc
                                                                    delegate:self];
    
    return audioEncoder;
}

- (void)createFileAtPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
       NSError *error;
       [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
       [self printfError:error];
   }
   
   [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}


#pragma mark - <-- Printf Method -->
- (void)printfLog:(NSString *)log {
    if (self.isEnableLog && log) NSLog(@"[DVLive LOG]: %@", log);
}

- (void)printfError:(NSError *)error {
    if (self.isEnableLog && error) NSLog(@"[DVLive ERROR]: %@", error.localizedDescription);
}


#pragma mark - <-- Capture Delegate -->
- (void)DVVideoCapture:(DVVideoCapture *)capture
    outputSampleBuffer:(CMSampleBufferRef)sampleBuffer
                 error:(DVVideoError *)error {
    
    if (self.videoEncoder && !error) {
        NSNumber *timeStampNum = [NSNumber numberWithUnsignedLongLong:RTMP_TIMESTAMP_NOW];
        [self.videoEncoder encodeVideoBuffer:sampleBuffer userInfo:(__bridge void *)timeStampNum];
    }
}

- (void)DVAudioUnit:(DVAudioUnit *)audioUnit recordData:(NSData *)data error:(DVAudioError *)error {
  
    if (self.audioEncoder && !error) {
        NSNumber *timeStampNum = [NSNumber numberWithUnsignedLongLong:RTMP_TIMESTAMP_NOW];
        [self.audioEncoder encodeAudioData:data userInfo:(__bridge void *)timeStampNum];
    }
}


#pragma mark - <-- Encoder Delegate -->
- (void)DVVideoEncoder:(id<DVVideoEncoder>)encoder vps:(NSData *)vps sps:(NSData *)sps pps:(NSData *)pps {
    [self printfLog:[NSString stringWithFormat:@"取得 vps:%d sps:%d  pps:%d", vps.length, sps.length, pps.length]];
        
    DVVideoFlvTagData *tagData = [self videoHeaderWithVPS:vps sps:sps pps:pps];
    if (tagData) [self.rtmpSocket setVideoHeader:tagData];
    
    
    if (self.isRecording) {
        dispatch_async(self.fileQueue, ^{
            if(vps) [self.fileHandle writeData:[encoder convertToNALUWithSpsOrPps:vps]];
            if(sps) [self.fileHandle writeData:[encoder convertToNALUWithSpsOrPps:sps]];
            if(pps) [self.fileHandle writeData:[encoder convertToNALUWithSpsOrPps:pps]];
        });
    }
}

- (void)DVVideoEncoder:(id<DVVideoEncoder>)encoder
             codedData:(NSData *)data
            isKeyFrame:(BOOL)isKeyFrame
              userInfo:(void *)userInfo {
    
    NSNumber *value = (__bridge NSNumber *)userInfo;
    uint64_t timeStamp = (uint64_t)[value unsignedLongLongValue];

    DVRtmpPacket *packet = [self videoPacketWithData:data isKeyFrame:isKeyFrame timeStamp:timeStamp];
    [self.rtmpSocket sendPacket:packet];

    
    if (isKeyFrame) [self printfLog:[NSString stringWithFormat:@"取得关键帧 -> %d", timeStamp]];
    
    if (self.isRecording) {
        dispatch_async(self.fileQueue, ^{
            [self.fileHandle writeData:[encoder convertToNALUWithData:data isKeyFrame:isKeyFrame]];
        });
    }
}

- (void)DVAudioEncoder:(id<DVAudioEncoder>)encoder codedData:(NSData *)data userInfo:(void *)userInfo {
    
    NSNumber *value = (__bridge NSNumber *)userInfo;
    uint64_t timeStamp = (uint64_t)[value unsignedLongLongValue];

    DVRtmpPacket *packet = [self audioPacketWithData:data timeStamp:timeStamp];
    [self.rtmpSocket sendPacket:packet];
}


#pragma mark - <-- RTMP Delegate -->
- (void)DVRtmp:(id<DVRtmp>)rtmp status:(DVRtmpStatus)status {
    self.liveStatus = (DVLiveStatus)status;
    if (self.delegate) [self.delegate DVLive:self status:self.liveStatus];
    
    NSString *desc = nil;
    switch (status) {
        case DVRtmpStatus_Disconnected:
            desc = @"未连接";
            break;
        case DVRtmpStatus_Connecting:
            desc = @"连接中";
            break;
        case DVRtmpStatus_Connected:
            desc = @"已连接";
            break;
        case DVRtmpStatus_Reconnecting:
            desc = @"重新连接中";
            break;
        default:
            break;
    }
    
    [self printfLog:desc];
}

- (void)DVRtmp:(id<DVRtmp>)rtmp error:(DVRtmpError *)error {
    [self printfError:error];
}

- (void)DVRtmpBuffer:(DVRtmpBuffer *)rtmpBuffer bufferStatus:(DVRtmpBufferStatus)bufferStatus {
    switch (bufferStatus) {
        case DVRtmpBufferStatus_Steady:
            [self printfLog:@"缓冲平稳"];
            break;
        case DVRtmpBufferStatus_Increase:
            [self printfLog:@"缓冲持续上涨"];
            
            if (self.videoConfig.adaptiveBitRate) {
                self.videoEncoder.bitRate -= 100 * 1024;
                if (self.videoEncoder.bitRate < self.videoConfig.minBitRate) {
                    self.videoEncoder.bitRate = self.videoConfig.minBitRate;
                }
            }

            break;
        case DVRtmpBufferStatus_Decrease:
            [self printfLog:@"缓冲持续下降"];

            if (self.videoConfig.adaptiveBitRate) {
                self.videoEncoder.bitRate += 100 * 1024;
                if (self.videoEncoder.bitRate > self.videoConfig.maxBitRate) {
                    self.videoEncoder.bitRate = self.videoConfig.maxBitRate;
                }
            }
            
            break;
        default:
            break;
    }
    
    NSUInteger kbs = self.videoEncoder.bitRate / 1024;
    [self printfLog:[NSString stringWithFormat:@"码率: %d kb/s", kbs]];
}

- (void)DVRtmpBuffer:(DVRtmpBuffer *)rtmpBuffer
  bufferOverMaxCount:(NSArray<DVRtmpPacket *> *)bufferList
        deleteBuffer:(void (^)(NSArray<DVRtmpPacket *> * _Nonnull))deleteBlock {
    

}

@end
