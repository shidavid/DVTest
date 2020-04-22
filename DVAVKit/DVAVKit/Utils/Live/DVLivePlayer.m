//
//  DVLivePlayer.m
//  DVAVKit
//
//  Created by 施达威 on 2019/3/22.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVLivePlayer.h"
#import "DVFFmpegKit.h"
#import "DVVideoToolKit.h"
#import "DVAudioToolKit.h"
#import "DVOPGLPreview.h"
#import "DVAudioQueue.h"
#import "DVVideoUtils.h"


@interface DVLivePlayer () <FFInFormatContextDelegate, FFOutFormatContextDelegate, DVVideoDecoderDelegate, DVAudioDecoderDelegate, DVAudioQueueDelegate>

@property(nonatomic, strong) DVOPGLPreview *preOPGLView;
@property(nonatomic, strong) DVAudioQueue *audioQueue;

@property(nonatomic, strong) FFInFormatContext *inFmtCtx;
@property(nonatomic, strong) FFOutFormatContext *recordFmtCtx;

@property(nonatomic, strong, nullable) id<DVVideoDecoder> videoDecoder;
@property(nonatomic, strong, nullable) id<DVAudioDecoder> audioDecoder;

@property(nonatomic, strong) dispatch_semaphore_t recordLock;
@property(nonatomic, strong) dispatch_semaphore_t videoLock;

@property(nonatomic, assign) BOOL isRecording;
@property(nonatomic, assign) BOOL isRecordToPhotoAlbum;
@property(nonatomic, copy) void(^recordCompletion)(BOOL finished);

@property(nonatomic, assign) CGRect preViewFrame;

@property(nonatomic, strong) NSMutableArray<DVVideoPacket *> *videoPacketBuffer;
@property(nonatomic, assign) int64_t lastVideoPTS;
@property(nonatomic, assign) BOOL isPreFirshVideoFrame;

@end


@implementation DVLivePlayer

@synthesize isRecording = _isRecording;

- (instancetype)initWithPreViewFrame:(CGRect)previewFrame {
    self = [self init];
    if (self) {
        self.preViewFrame = previewFrame;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
        [FFSession enableSession];
        [FFSession enableNetWork];
    }
    return self;
}

- (void)dealloc {
    if (_inFmtCtx) {
        [_inFmtCtx stopReadPacket];
        [_inFmtCtx closeURL];
        _inFmtCtx.delegate = nil;
    }
    
    if (_recordFmtCtx) {
        [_recordFmtCtx closeURL];
        _recordFmtCtx.delegate = nil;
    }
    
    if (_videoDecoder) {
        [_videoDecoder closeDecoder];
        _videoDecoder.delegate = nil;
    }
    
    if (_audioDecoder) {
        [_audioDecoder closeDecoder];
        _audioDecoder.delegate = nil;
    }
    
    if (_audioQueue) {
        [_audioQueue stop];
        _audioQueue.delegate = nil;
    }
    
    if (_videoPacketBuffer) {
        [_videoPacketBuffer removeAllObjects];
    }
}


#pragma mark - <-- Property -->
- (FFInFormatContext *)inFmtCtx {
    if (!_inFmtCtx) {
        _inFmtCtx = [FFInFormatContext context];
        _inFmtCtx.delegate = self;
    }
    return _inFmtCtx;
}

- (FFOutFormatContext *)recordFmtCtx {
    if (!_recordFmtCtx) {
        _recordFmtCtx = [FFOutFormatContext contextFromInFmtCtx:self.inFmtCtx];
        _recordFmtCtx.delegate = self;
    }
    return _recordFmtCtx;
}

- (dispatch_semaphore_t)recordLock {
    if (!_recordLock) {
        _recordLock = dispatch_semaphore_create(1);
    }
    return _recordLock;
}

- (dispatch_semaphore_t)videoLock {
    if (!_videoLock) {
        _videoLock = dispatch_semaphore_create(1);
    }
    return _videoLock;
}

- (BOOL)isRecording {
    dispatch_semaphore_wait(self.recordLock, DISPATCH_TIME_FOREVER);
    BOOL ret = _isRecording;
    dispatch_semaphore_signal(self.recordLock);
    return ret;
}

- (void)setIsRecording:(BOOL)isRecording {
    dispatch_semaphore_wait(self.recordLock, DISPATCH_TIME_FOREVER);
    _isRecording = isRecording;
    dispatch_semaphore_signal(self.recordLock);
}

- (UIView *)preView {
    return self.preOPGLView;
}

- (DVOPGLPreview *)preOPGLView {
    if (!_preOPGLView) {
        _preOPGLView = [[DVOPGLPreview alloc] initWithFrame:self.preViewFrame];
    }
    return _preOPGLView;
}

- (NSMutableArray<DVVideoPacket *> *)videoPacketBuffer {
    if (!_videoPacketBuffer) {
        _videoPacketBuffer = [NSMutableArray array];
    }
    return _videoPacketBuffer;
}


#pragma mark - <-- Method -->
- (void)connectToURL:(NSString *)url {
    [self.inFmtCtx openWithURL:url];
}

- (void)disconnect {
    [self.inFmtCtx closeURL];
}

- (void)startPlay {
    if (self.inFmtCtx.isReading) return;
    [self.inFmtCtx startReadPacket];
}

- (void)stopPlay {
    if (!self.inFmtCtx.isReading) return;
    if (self.isRecording) [self stopRecord];
    [self.inFmtCtx stopReadPacket];
}

- (UIImage *)screenshot {
    return self.preOPGLView.openglSnapshotImage;
}

- (void)saveScreenshotToPhotoAlbumWithCompletion:(void (^)(BOOL))completion {
    UIImage *image = self.preOPGLView.openglSnapshotImage;
    if (!image) {
        NSLog(@"[DVLivePlayer ERROR]: 截图为空");
        return;
    }
    
    [DVVideoUtils saveImageToPhotoAlbum:image completion:completion];
    
}

- (void)startRecordToURL:(NSString *)url completion:(void (^)(BOOL))completion {
    if (self.isRecording) return;
    
    if (!self.inFmtCtx.isOpening) {
        NSLog(@"[DVLivePlayer ERROR]: 请打开源文件,再录制");
        return;
    }
    
    NSArray *array = [url componentsSeparatedByString:@"."];
    NSString *format = @"mp4";
    if (array.count >= 2) format = array.lastObject;
    
    self.isRecordToPhotoAlbum = NO;
    self.recordCompletion = completion;
    [self.recordFmtCtx openWithURL:url format:format];
    self.isRecording = YES;
}

- (void)startRecordToPhotoAlbumWithCompletion:(void (^)(BOOL))completion {
    if (!self.inFmtCtx.isOpening) {
        NSLog(@"[DVLivePlayer ERROR]: 请打开源文件,再录制");
        return;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"temp-live-record-%@.mp4", [NSDate date]];
    NSString *documemtPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *url = [documemtPath stringByAppendingPathComponent:fileName];
    self.isRecordToPhotoAlbum = YES;
    self.recordCompletion = completion;
    [self.recordFmtCtx openWithURL:url format:@"mp4"];
    self.isRecording = YES;
}

- (void)stopRecord {
    if (!self.isRecording) return;
    
    if (!self.inFmtCtx.isOpening) {
        NSLog(@"[DVLivePlayer ERROR]: 请打开源文件,再录制");
        return;
    }
    
    self.isRecording = NO;
    [self.recordFmtCtx closeURL];
}


#pragma mark - <-- FF Input Delegate -->
- (void)FFInFormatContext:(FFInFormatContext *)context videoInfo:(FFVideoInfo *)videoInfo {
    self.isPreFirshVideoFrame = YES;
    
    if ([videoInfo.codecName isEqualToString:@"h264"]) {
        self.videoDecoder = [[DVVideoH264HardwareDecoder alloc] initWithSps:videoInfo.sps
                                                                        pps:videoInfo.pps
                                                                   delegate:self];
    }
    else if ([videoInfo.codecName isEqualToString:@"hevc"]) {
        self.videoDecoder = [[DVVideoHEVCHardwareDecoder alloc] initWithVps:videoInfo.vps
                                                                        sps:videoInfo.sps
                                                                        pps:videoInfo.pps
                                                                   delegate:self];
    }
}

- (void)FFInFormatContext:(FFInFormatContext *)context audioInfo:(FFAudioInfo *)audioInfo {
    if ([audioInfo.codecName isEqualToString:@"aac"]) {
        
        
        DVAudioConfig *audioConfig = [DVAudioConfig configWithSampleRate:audioInfo.sampleRate
                                                          bitsPerChannel:audioInfo.bitsPerChannel
                                                        numberOfChannels:audioInfo.numberOfChannels];
        
        // 1.初始化 AAC解码器
        AudioStreamBasicDescription inputDesc  = [DVAudioStreamBaseDesc aacBasicDescWithConfig:audioConfig];
        AudioStreamBasicDescription outputDesc = [DVAudioStreamBaseDesc pcmBasicDescWithConfig:audioConfig];
        self.audioDecoder = [[DVAudioAACHardwareDecoder alloc] initWithInputBasicDesc:inputDesc
                                                                      outputBasicDesc:outputDesc
                                                                             delegate:self];
        ((DVAudioAACHardwareDecoder *)self.audioDecoder).outputDataPacketSize = 1024;
        
        
        // 2.初始化播放器
        self.audioQueue = [[DVAudioQueue alloc] initOutputQueueWithBasic:outputDesc bufferSize:2048];
        self.audioQueue.delegate = self;
        [self.audioQueue start];
    }
}

- (void)FFInFormatContext:(FFInFormatContext *)context readVideoPacket:(FFPacket *)packet {
    
    // 首帧视频渲染
    if (self.isPreFirshVideoFrame) {
        // 转换时间戳
        FFVideoInfo *videoInfo = self.inFmtCtx.videoInfo;
        int64_t vPts = packet.pts;
        int64_t vDts = packet.dts;
        NSData *data = packet.datas;
        [self.videoDecoder decodeVideoData:data
                                       pts:vPts
                                       dts:vDts
                                       fps:(int)videoInfo.fps
                                  userInfo:nil];
        
        self.isPreFirshVideoFrame = NO;
    }
    

    if (self.videoDecoder) {
        dispatch_semaphore_wait(self.videoLock, DISPATCH_TIME_FOREVER);
        DVVideoPacket *videoPkt = [[DVVideoPacket alloc] initWithData:packet.data size:packet.size];
        videoPkt.pts = packet.pts;
        videoPkt.dts = packet.dts;
        [self.videoPacketBuffer addObject:videoPkt];
        dispatch_semaphore_signal(self.videoLock);
    }
    
    if (self.isRecording) [self.recordFmtCtx writePacket:packet];
}

- (void)FFInFormatContext:(FFInFormatContext *)context readAudioPacket:(FFPacket *)packet {

    if (self.audioDecoder) {
        NSData *data = packet.datas;
        NSNumber *numPts = [NSNumber numberWithLongLong:packet.pts];
        [self.audioDecoder decodeAudioData:data userInfo:(__bridge void *)numPts];
    }
    
    if (self.isRecording) [self.recordFmtCtx writePacket:packet];
}


#pragma mark - <-- FF Output Delegate -->
- (void)FFOutFormatContextDidFinishedOutput:(FFOutFormatContext *)context {
    if (!context.url) return;
    
    if (!self.recordCompletion) return;
    __weak __typeof(self)weakSelf = self;
    [DVVideoUtils saveVideoToPhotoAlbum:context.url completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.isRecordToPhotoAlbum) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:context.url]) {
                    [fileManager removeItemAtPath:context.url error:nil];
                }
                weakSelf.isRecordToPhotoAlbum = NO;
            }
            
            weakSelf.recordCompletion(finished);
            weakSelf.recordCompletion = nil;
        });
    }];
}


#pragma mark - <-- Decodec Delegate -->
- (void)DVVideoDecoder:(id<DVVideoDecoder>)decoder
         decodecBuffer:(CMSampleBufferRef)buffer
          isFirstFrame:(BOOL)isFirstFrame
              userInfo:(void *)userInfo {
    
    if (_preOPGLView) {
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(buffer);
        [self.preOPGLView displayWithPixelBuffer:pixelBuffer];
    }
}

- (void)DVAudioDecoder:(id<DVAudioDecoder>)decoder
           decodedData:(NSData *)data
              userInfo:(void *)userInfo {
    
    if (_audioQueue) {
        [self.audioQueue playAudioData:(uint8_t *)data.bytes size:(UInt32)data.length userInfo:userInfo];
    }
}


#pragma mark - <-- AudioQueue Delegate -->
//- (void)DVAudioQueue:(DVAudioQueue *)audioQueue
//        playbackData:(uint8_t *)data
//                size:(UInt32)size
//            userInfo:(void *)userInfo {
//
//    // 音视频同步, 视频解码到渲染几乎是实时，而音频解码到播放有段时间，首播快可以减少音频的码率
//    int64_t aPts = [(__bridge NSNumber *)userInfo longLongValue];
//
//    dispatch_semaphore_wait(self.videoLock, DISPATCH_TIME_FOREVER);
//
//    FFVideoInfo *videoInfo = self.inFmtCtx.videoInfo;
//
//    while (self.videoPacketBuffer.count > 0) {
//        DVVideoPacket *videoPkt = self.videoPacketBuffer.firstObject;
//        // 时间戳
//        int64_t vPts = videoPkt.pts;
//        int64_t vDts = videoPkt.dts;
//
//        if (aPts < vPts) break;
//
//        NSData *data = videoPkt.data;
//        [self.videoDecoder decodeVideoData:data
//                                       pts:vPts
//                                       dts:vDts
//                                       fps:(int)videoInfo.fps
//                                  userInfo:nil];
//
//        [self.videoPacketBuffer removeObjectAtIndex:0];
//        videoPkt = nil;
//    }
//
//    NSLog(@"[DVLivePlayer LOG]: audioPacket count-> %d", audioQueue.packetBuffer.count);
//    NSLog(@"[DVLivePlayer LOG]: videoPacket count-> %d", self.videoPacketBuffer.count);
//
//    dispatch_semaphore_signal(self.videoLock);
//}

- (void)DVAudioQueue:(DVAudioQueue *)audioQueue
        playbackData:(uint8_t *)data
                size:(UInt32)size
            userInfo:(void *)userInfo {

    // 音视频同步
    if (audioQueue.packetBuffer.count < 2) return;

    DVAudioPacket *audioPkt1 = audioQueue.packetBuffer[0];
    DVAudioPacket *audioPkt2 = audioQueue.packetBuffer[1];

    int64_t aPts1 = [(__bridge NSNumber *)audioPkt1->_userInfo longLongValue];
    int64_t aPts2 = [(__bridge NSNumber *)audioPkt2->_userInfo longLongValue];

    dispatch_semaphore_wait(self.videoLock, DISPATCH_TIME_FOREVER);

    FFVideoInfo *videoInfo = self.inFmtCtx.videoInfo;

    while (self.videoPacketBuffer.count > 0) {
        DVVideoPacket *videoPkt = self.videoPacketBuffer.firstObject;
        // 时间戳
        int64_t vPts = videoPkt.pts;
        int64_t vDts = videoPkt.dts;

        if (aPts1 < vPts && aPts2 < vPts) {
            break;
        }


        NSData *data = videoPkt.data;
        [self.videoDecoder decodeVideoData:data
                                       pts:vPts
                                       dts:vDts
                                       fps:(int)videoInfo.fps
                                  userInfo:nil];

        [self.videoPacketBuffer removeObjectAtIndex:0];


        if (self.lastVideoPTS == vPts || (aPts1 <= vPts && vPts <= aPts2)) {
            self.lastVideoPTS = vPts;
            break;
        }

        videoPkt = nil;
    }

//    NSLog(@"[DVLivePlayer LOG]: audioPacket count-> %d", audioQueue.packetBuffer.count);
//    NSLog(@"[DVLivePlayer LOG]: videoPacket count-> %d", self.videoPacketBuffer.count);

    dispatch_semaphore_signal(self.videoLock);
}

@end
