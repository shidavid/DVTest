//
//  DVVideoHEVCHardwareDecoder.m
//  DVAVKit
//
//  Created by 施达威 on 2019/3/23.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVVideoHEVCHardwareDecoder.h"
#import "DVVideoError.h"

@interface DVVideoHEVCHardwareDecoder () {
    VTDecompressionSessionRef _sessionRef;
    CMVideoFormatDescriptionRef _descriptionRef;
}

@property(nonatomic, assign) uint64_t frameCount;
@property(nonatomic, assign) NSInteger errorCount;

@property(nonatomic, strong, nonnull) NSData *vps;
@property(nonatomic, strong, nonnull) NSData *sps;
@property(nonatomic, strong, nonnull) NSData *pps;
@property(nonatomic, assign) BOOL isFirstFrame;

@property(nonatomic, strong) dispatch_semaphore_t sessionLock;

@end


@implementation DVVideoHEVCHardwareDecoder

@synthesize delegate = _delegate;

- (instancetype)initWithVps:(NSData *)vps
                        sps:(NSData *)sps
                        pps:(NSData *)pps
                   delegate:(id<DVVideoDecoderDelegate>)delegate {
    self = [super init];
    if (self) {
        self.vps = vps;
        self.sps = sps;
        self.pps = pps;
        self.isFirstFrame = YES;
        self.delegate = delegate;
        self.sessionLock = dispatch_semaphore_create(1);
        [self initVideoSession];
    }
    return self;
}

- (void)dealloc {
    [self uninitVideoSession];
    _delegate = nil;
}


#pragma mark - <-- Init -->
- (void)initVideoSession {
    [self uninitVideoSession];
    
    if (!self.vps || !self.sps || !self.pps) {
        NSLog(@"[DVVideoHEVCHardwareDecoder ERROR]: vps/sps/pps为空, 初始化失败");
        return;
    }
    
    OSStatus status;
    CMVideoFormatDescriptionRef descriptionRef;
    const uint8_t *const paramSetPointers[3] = {self.vps.bytes, self.sps.bytes, self.pps.bytes};
    const size_t paramSetSizes[3] = {(size_t)self.vps.length, (size_t)self.sps.length, (size_t)self.pps.length};

    // 1. 根据sps pps 获取描述
    status = CMVideoFormatDescriptionCreateFromHEVCParameterSets(kCFAllocatorDefault,
                                                                 3,                     // 参数个数
                                                                 paramSetPointers,
                                                                 paramSetSizes,
                                                                 4,
                                                                 NULL,
                                                                 &descriptionRef);
    if (status != noErr) {
        VideoCheckStatus(status, @"[VideoToolBox ERROR]: vt paramterSets create error");
        if (descriptionRef) CFRelease(descriptionRef);
        descriptionRef = NULL;
        return;
    }
    
    
    VTDecompressionSessionRef sessionRef;
    uint32_t pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    const void *keys[] = {kCVPixelBufferPixelFormatTypeKey};
    const void *values[] = {CFNumberCreate(NULL, kCFNumberSInt32Type, &pixelFormatType)};
    CFDictionaryRef dict = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    VTDecompressionOutputCallbackRecord callBackRecord = {
        .decompressionOutputCallback = vtHEVCDecompressionOutputCallback,
        .decompressionOutputRefCon = (__bridge void *)self,
    };
    
    // 2. 根据描述创建解码器
    status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                          descriptionRef,
                                          NULL,
                                          dict,
                                          &callBackRecord,
                                          &sessionRef);
    CFRelease(dict);
    
    if (status != noErr) {
        VideoCheckStatus(status, @"[VideoToolBox ERROR]: vt decompression create error");
        if (sessionRef) CFRelease(sessionRef);
        sessionRef = NULL;
        return;
    }
    
     
    
    _descriptionRef = descriptionRef;
    _sessionRef = sessionRef;
    
     
    
    [self printLog:@"解码器已初始化"];
}

- (void)uninitVideoSession {
     
    
    if (_sessionRef) {
        // 等待解码完成才关闭解码器
        VTDecompressionSessionWaitForAsynchronousFrames(_sessionRef);
        VTDecompressionSessionInvalidate(_sessionRef);
        CFRelease(_sessionRef);
        _sessionRef = NULL;
    }
    
    if (_descriptionRef) {
        CFRelease(_descriptionRef);
        _descriptionRef = NULL;
    }
    
     
    
    [self printLog:@"解码器关闭"];
}



#pragma mark - <-- Property -->



#pragma mark - <-- Method -->
- (void)decodeVideoData:(NSData *)data pts:(int64_t)pts dts:(int64_t)dts fps:(int)fps userInfo:(void *)userInfo {
    
    if (!_descriptionRef || !_sessionRef) return;
    if (!data || data.length == 0) return;
    
    
    CMBlockBufferRef blockBufRef = NULL;
    OSStatus statuts;
    size_t size = data.length;
    uint8_t *memory = (uint8_t *)malloc(size);
    memcpy(memory, data.bytes, size);
    
    CMSampleBufferRef sampleBufRef = NULL;
    const size_t sampleSizes[] = {size};
    CMSampleTimingInfo timingInfo = {
        .presentationTimeStamp = CMTimeMakeWithSeconds(pts, fps),
        .decodeTimeStamp = CMTimeMakeWithSeconds(dts, fps),
    };
    
    VTDecodeFrameFlags frameFlags = kVTDecodeFrame_EnableAsynchronousDecompression;
    VTDecodeInfoFlags infoFlags = 0;
    
    
    do {
        // 1.将压缩数据放入 CMBlockBufferRef
        statuts = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                     (void *)memory,
                                                     size,
                                                     kCFAllocatorNull,
                                                     NULL,
                                                     0,
                                                     size,
                                                     0,
                                                     &blockBufRef);
        if (statuts != kCMBlockBufferNoErr || !blockBufRef) {
            VideoCheckStatus(statuts, @"create block buffer error");
            break;
        }
        
        
        // 2.将 描述 时间 Block 封装成 CMSampleBuffer
        statuts = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                            blockBufRef,
                                            _descriptionRef,
                                            1,
                                            1,
                                            &timingInfo,
                                            1,
                                            sampleSizes,
                                            &sampleBufRef);
         
        if (statuts != kCMBlockBufferNoErr || !sampleBufRef) {
            VideoCheckStatus(statuts, @"create sample buffer error");
            break;
        }
        
        
        // 3.解码数据
        statuts = VTDecompressionSessionDecodeFrame(_sessionRef,
                                                    sampleBufRef,
                                                    frameFlags,
                                                    userInfo,
                                                    &infoFlags);
         
        if (statuts == kVTInvalidSessionErr) {
            VideoCheckStatus(statuts, @"decompress error");
            [self uninitVideoSession];
            [self initVideoSession];
            break;
        }
        
    } while (NO);
    
  
    free(memory);
    memory = NULL;
    if (blockBufRef) CFRelease(blockBufRef);
    blockBufRef = NULL;
    if (sampleBufRef) CFRelease(sampleBufRef);
    sampleBufRef = NULL;
}

- (void)closeDecoder {
    [self uninitVideoSession];
}

- (void)printLog:(NSString *)message {
    NSLog(@"[DVVideoHEVCHardwareDecoder LOG]: %@",message);
}


#pragma mark - <-- Callback -->
void vtHEVCDecompressionOutputCallback(void * CM_NULLABLE decompressionOutputRefCon,
                                       void * CM_NULLABLE sourceFrameRefCon,
                                       OSStatus status,
                                       VTDecodeInfoFlags infoFlags,
                                       CM_NULLABLE CVImageBufferRef imageBuffer,
                                       CMTime presentationTimeStamp,
                                       CMTime presentationDuration) {
    
    if (!imageBuffer) return;
    if (status != noErr) {
        VideoCheckStatus(status, @"decompression to hevc error");
        return;
    }
    
    
    
    DVVideoHEVCHardwareDecoder *decoder = (__bridge DVVideoHEVCHardwareDecoder *)decompressionOutputRefCon;
    if (!decoder.delegate) {
        NSLog(@"[DVVideoHEVCHardwareDecoder ERROR]: delegate 为 nil");
        return;
    }
    
    
    CMSampleTimingInfo timeInfo = {
        .presentationTimeStamp = presentationTimeStamp,
        .decodeTimeStamp = presentationTimeStamp,
    };
    CMSampleBufferRef sampleBufRef = NULL;
    CMVideoFormatDescriptionRef descriptionRef = NULL;
    OSStatus status1;
    
    
    do {
        // 1.根据imagebuffer 创建描述
        status1 = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, imageBuffer, &descriptionRef);
        if (status1 != noErr) {
            VideoCheckStatus(status1, @"create description buffer error");
            break;
        }
        

        // 2.将 imagebuffer timeinfo 描述 封装成 CMSampleBuffer
        status1 = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
                                                    imageBuffer,
                                                    YES,
                                                    NULL,
                                                    NULL,
                                                    descriptionRef,
                                                    &timeInfo,
                                                    &sampleBufRef);
        if (status1 != noErr) {
            VideoCheckStatus(status1, @"create sample buffer error");
            break;
        }
        
        
        if (sampleBufRef) {
            [decoder.delegate DVVideoDecoder:decoder
                               decodecBuffer:sampleBufRef
                                isFirstFrame:decoder.isFirstFrame
                                    userInfo:sourceFrameRefCon];
            decoder.isFirstFrame = NO;
        }
        
    } while (NO);
    
    if (descriptionRef) {
        CFRelease(descriptionRef);
        descriptionRef = NULL;
    }
    
    if (sampleBufRef) {
        CFRelease(sampleBufRef);
        sampleBufRef = NULL;
    }
}



@end
