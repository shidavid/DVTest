//
//  DVVideoHEVCHardwareEncoder.m
//  iOS_Test
//
//  Created by DV on 2019/10/11.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVVideoHEVCHardwareEncoder.h"
#import "DVVideoError.h"

@interface DVVideoHEVCHardwareEncoder ()

@property(nonatomic, strong) DVVideoConfig *config;
@property(nonatomic, assign) VTCompressionSessionRef sessionRef;
@property(nonatomic, assign) uint64_t frameCount;
@property(nonatomic, strong) NSData *NALUHeader4;
@property(nonatomic, strong) NSData *NALUHeader3;
@property(nonatomic, assign) NSInteger errorCount;

@end

@implementation DVVideoHEVCHardwareEncoder

@synthesize delegate = _delegate;
@synthesize isRealTime = _isRealTime;
@synthesize profileLevel = _profileLevel;
@synthesize fps = _fps;
@synthesize gop = _gop;
@synthesize bitRate = _bitRate;
@synthesize isEnableBFrame = _isEnableBFrame;
@synthesize entropyMode = _entropyMode;


#pragma mark - <-- Initializer -->
- (instancetype)initWithConfig:(DVVideoConfig *)config delegate:(id<DVVideoEncoderDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.config = config;
        self.frameCount = 0;
        
        [self initNALUHeader];
        [self initVideoSession];
    }
    return self;
}

- (void)dealloc {
    [self uninitVideoSession];
    _delegate = nil;
    _config = nil;
}


#pragma mark - <-- Init -->
- (void)initNALUHeader {
    const UInt8 header4[] = {0x00, 0x00, 0x00, 0x01};
    self.NALUHeader4 = [NSData dataWithBytes:header4 length:4];
    
    const UInt8 header3[] = {0x00, 0x00, 0x01};
    self.NALUHeader3 = [NSData dataWithBytes:header3 length:3];
}

- (void)initVideoSession {
    if (_sessionRef) [self uninitVideoSession];
    
    OSStatus status = VTCompressionSessionCreate(NULL,                        // 分配器
                                                 self.config.size.width,      // 宽
                                                 self.config.size.height,     // 高
                                                 kCMVideoCodecType_HEVC,      // 编码格式
                                                 NULL,                        // 编码规范
                                                 NULL,                        // 源像素的缓冲区
                                                 NULL,                        // 压缩数据分配器
                                                 vtHEVCCompressionOutputCallback, // 回调函数
                                                 (__bridge void *)(self),     // 回调函数引用
                                                 &_sessionRef);               // 编码会话对象引用
    
    if (status != noErr) {
        VideoCheckStatus(status, @"[VideoToolBox ERROR]: vt compression create error");
        _sessionRef = NULL;
        return;
    }
    
    self.isRealTime = YES;
    if (@available(iOS 11.0, *)) {
        self.profileLevel = kVTProfileLevel_HEVC_Main_AutoLevel;
    }
    self.fps = self.config.fps;
    self.gop = self.config.gop;
    self.bitRate = self.config.bitRate;
    self.isEnableBFrame = self.config.isEnableBFrame;
//    self.entropyMode = kVTH264EntropyMode_CABAC;
    
    VTCompressionSessionPrepareToEncodeFrames(_sessionRef);
    NSLog(@"[DVVideoHEVCHardwareEncoder LOG]: 编码器已初始化");
}

- (void)uninitVideoSession {
    if (!_sessionRef) return;
    
    VTCompressionSessionCompleteFrames(_sessionRef, kCMTimeInvalid);
    VTCompressionSessionInvalidate(_sessionRef);
    CFRelease(_sessionRef);
    _sessionRef = NULL;
    NSLog(@"[DVVideoHEVCHardwareEncoder LOG]: 编码器关闭");
}



#pragma mark - <-- Property -->
- (void)setIsRealTime:(BOOL)isRealTime {
    if (!_sessionRef) return;
    _isRealTime = isRealTime;
    
    // 设置实时编码输出（避免延迟）w
    CFBooleanRef boolRef = isRealTime ? kCFBooleanTrue : kCFBooleanFalse;
    OSStatus status = VTSessionSetProperty(_sessionRef,
                                           kVTCompressionPropertyKey_RealTime,
                                           boolRef);
    if (status != noErr) {
        VideoCheckStatus(status, @"fail to set realTime");
    }
}

- (void)setProfileLevel:(CFStringRef)profileLevel {
    if (!_sessionRef) return;
    _profileLevel = profileLevel;
    
    OSStatus status = VTSessionSetProperty(_sessionRef,
                                           kVTCompressionPropertyKey_ProfileLevel,
                                           profileLevel);
    if (status != noErr) {
        VideoCheckStatus(status, @"fail to set profileLevel");
    }
}

- (void)setFps:(NSUInteger)fps {
    if (!_sessionRef) return;
    _fps = fps;
    self.config.fps = fps;
    
    // 设置期望帧率
    OSStatus status = VTSessionSetProperty(_sessionRef,
                                           kVTCompressionPropertyKey_ExpectedFrameRate,
                                           (__bridge CFTypeRef)(@(fps)));
    if (status != noErr) {
        VideoCheckStatus(status, @"fail to set fps");
    }
}

- (void)setGop:(NSUInteger)gop {
    if (!_sessionRef) return;
    _gop = gop;
    self.config.gop = gop;
    
    // 设置关键帧（GOPsize)间隔
    OSStatus status = VTSessionSetProperty(_sessionRef,
                                           kVTCompressionPropertyKey_MaxKeyFrameInterval ,
                                           (__bridge CFTypeRef)(@(gop)));
    if (status != noErr) {
        VideoCheckStatus(status, @"fail to set gop");
    }
}

- (void)setBitRate:(NSUInteger)bitRate {
    if (!_sessionRef) return;
    _bitRate = bitRate;
    self.config.bitRate = bitRate;
 
    //设置码率，均值，单位是byte
    OSStatus status1 = VTSessionSetProperty(_sessionRef,
                                            kVTCompressionPropertyKey_AverageBitRate,
                                            (__bridge CFTypeRef)@(bitRate));
    if (status1 != noErr) {
        VideoCheckStatus(status1, @"fail to set averageBitRate");
    }
    
    //设置码率，上限，单位是bps
    NSArray *maxBitRate = @[@(bitRate * 1.5 / 8),@(1.0)];
    OSStatus status2 = VTSessionSetProperty(_sessionRef,
                                            kVTCompressionPropertyKey_DataRateLimits,
                                            (__bridge CFTypeRef)maxBitRate);
    if (status2 != noErr) {
        VideoCheckStatus(status2, @"fail to set bitRate");
    }
}

- (void)setIsEnableBFrame:(BOOL)isEnableBFrame {
    if (!_sessionRef) return;
    _isEnableBFrame = isEnableBFrame;
    
    // 不产生b帧
    CFBooleanRef boolRef = isEnableBFrame ? kCFBooleanTrue : kCFBooleanFalse;
    OSStatus status = VTSessionSetProperty(_sessionRef,
                                           kVTCompressionPropertyKey_AllowFrameReordering,
                                           boolRef);
    if (status != noErr) {
        VideoCheckStatus(status, @"fail to set has b frame");
    }
}

- (void)setEntropyMode:(CFStringRef)entropyMode {
    if (!_sessionRef) return;
    _entropyMode = entropyMode;
    
    // kVTH264EntropyMode_CABAC
    OSStatus status = VTSessionSetProperty(_sessionRef,
                                           kVTCompressionPropertyKey_H264EntropyMode,
                                           entropyMode);
    if (status != noErr) {
        VideoCheckStatus(status, @"fail to set entropyMode");
    }
}



#pragma mark - <-- Method -->
- (void)encodeVideoBuffer:(CMSampleBufferRef)buffer userInfo:(void *)userInfo {
    if (!_sessionRef) return;
        
    // 抽离出未压缩的源数据
    CVImageBufferRef imageBufRef = (CVImageBufferRef)CMSampleBufferGetImageBuffer(buffer);
    if (!imageBufRef) return;
    
    // 帧时间，如果不设置会导致时间轴过长
    CMTime pts = CMTimeMake(self.frameCount, (int32_t)self.fps);
    CMTime duration = CMTimeMake(1, (int32_t)self.fps);
    VTEncodeInfoFlags flags = kVTEncodeInfo_Asynchronous;
    
    // 强制编成I帧
    NSDictionary *properties = nil;
    if (self.frameCount % (uint64_t)self.gop == 0) {
        properties = @{(__bridge NSString *)kVTEncodeFrameOptionKey_ForceKeyFrame : @(YES)};
    }
    
    // 进行压缩, 异步回调
    OSStatus status = VTCompressionSessionEncodeFrame(_sessionRef,  // 编码会话
                                                      imageBufRef,  // 未压缩的源数据
                                                      pts,          // 时间戳
                                                      duration,     // 时长
                                                      (__bridge CFDictionaryRef)properties, // 数据其他属性
                                                      userInfo,     // 引用
                                                      &flags);      // 传递给回调函数
    self.frameCount++;
    
    if (status != noErr) {
        VideoCheckStatus(status, @"encode frame error");
        
        ++_errorCount;
        if (_errorCount > 10) {
            _errorCount = 0;
            [self uninitVideoSession];
            [self initVideoSession];
        }
    } else {
        _errorCount = 0;
    }
}

- (void)closeEncoder {
    [self uninitVideoSession];
}

- (NSData *)convertToNALUWithData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame {
    NSMutableData *mData = [NSMutableData data];
    isKeyFrame ? [mData appendData:self.NALUHeader4] : [mData appendData:self.NALUHeader3];
    [mData appendData:[data subdataWithRange:NSMakeRange(4, data.length-4)]];
    return [mData copy];
}

- (NSData *)convertToNALUWithSpsOrPps:(NSData *)data {
    NSMutableData *mData = [NSMutableData data];
    [mData appendData:self.NALUHeader4];
    [mData appendData:data];
    return [mData copy];
}

#pragma mark - <-- Callback -->
// 异步回调
void vtHEVCCompressionOutputCallback(void *outputCallbackRefCon,
                                     void *sourceFrameRefCon,
                                     OSStatus status,
                                     VTEncodeInfoFlags infoFlags,
                                     CMSampleBufferRef sampleBuffer ){
    if (status != noErr) {
        VideoCheckStatus(status, @"compression to HEVC error");
        return;
    }
    
    DVVideoHEVCHardwareEncoder *encoder = (__bridge DVVideoHEVCHardwareEncoder *)outputCallbackRefCon;
    if (!encoder.delegate) {
        NSLog(@"[DVVideoHEVCHardwareEncoder ERROR]: delegate 为 nil");
        return;
    }
    
    
    if (!CMSampleBufferDataIsReady(sampleBuffer)) return; // 数据是否准备好
    
    // 是否为关键帧
    if (!sampleBuffer) return;
    CFArrayRef attachArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true);
    if (!attachArray) return;
    CFDictionaryRef dict = CFArrayGetValueAtIndex(attachArray, 0);
    if (!dict) return;
    BOOL isKeyFrame = !CFDictionaryContainsKey(dict, kCMSampleAttachmentKey_NotSync);
    
    
    
    
    // 获取sps & pps数据
    if (isKeyFrame) {
        do {
            CMFormatDescriptionRef formatDescRef = CMSampleBufferGetFormatDescription(sampleBuffer);
            
            #pragma mark - <-- vps -->
            size_t vpsSize, vpsCount;
            const uint8_t *vps;
            OSStatus vpsStatus = CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(formatDescRef,
                                                                                    0,
                                                                                    &vps,
                                                                                    &vpsSize,
                                                                                    &vpsCount,
                                                                                    0);
            if (vpsStatus != noErr) {
                VideoCheckStatus(vpsStatus, @"获取 vps error");
                break;
            }
            
            
            #pragma mark - <-- sps -->
            size_t spsSize, spsCount;
            const uint8_t *sps;
            OSStatus spsStatus = CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(formatDescRef,
                                                                                    1,
                                                                                    &sps,
                                                                                    &spsSize,
                                                                                    &spsCount,
                                                                                    0);
            if (spsStatus != noErr) {
                VideoCheckStatus(spsStatus, @"获取 sps error");
                break;
            }
            
            
            #pragma mark - <-- pps -->
            size_t ppsSize, ppsCount;
            const uint8_t *pps;
            OSStatus ppsStatus = CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(formatDescRef,
                                                                                    2,
                                                                                    &pps,
                                                                                    &ppsSize,
                                                                                    &ppsCount,
                                                                                    0);
            if (ppsStatus != noErr) {
                VideoCheckStatus(ppsStatus, @"获取 pps error");
                break;
            }
            
            
            
            NSData *vpsData = [NSData dataWithBytes:vps length:vpsSize];
            NSData *spsData = [NSData dataWithBytes:sps length:spsSize];
            NSData *ppsData = [NSData dataWithBytes:pps length:ppsSize];
            [encoder.delegate DVVideoEncoder:encoder vps:vpsData sps:spsData pps:ppsData];
            
        } while (NO);
    }
    
    
    CMBlockBufferRef dataBufRef = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t len, totalLen;
    char *dataPointer;
    
    OSStatus dataStatus = CMBlockBufferGetDataPointer(dataBufRef, 0, &len, &totalLen, &dataPointer);
    if (dataStatus != noErr) {
        VideoCheckStatus(status, @"获取 已压缩数据 失败");
        return;
    }
    
    size_t dataOffset = 0;
    const int AVCCHeaderLen = 4; // 返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length
    
    // 循环获取nalu数据
    while (dataOffset < totalLen - AVCCHeaderLen) {
        uint32_t NALULen = 0;
        memcpy(&NALULen, dataPointer + dataOffset, AVCCHeaderLen);
        NALULen = CFSwapInt32BigToHost(NALULen); // 大端模式帧长度 转换为 系统端
         
        NSData *pktData = [NSData dataWithBytes:(dataPointer + dataOffset)
                                         length:(AVCCHeaderLen + NALULen)];
        [encoder.delegate DVVideoEncoder:encoder codedData:pktData
                              isKeyFrame:isKeyFrame
                                userInfo:sourceFrameRefCon];
        
        dataOffset += AVCCHeaderLen + NALULen;
    }
}


@end
