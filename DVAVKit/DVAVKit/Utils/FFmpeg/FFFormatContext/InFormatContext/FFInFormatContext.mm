//
//  FFInFormatContext.m
//  DVAVKit
//
//  Created by 施达威 on 2019/3/30.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "FFInFormatContext.h"
#import "FFInFormatContext+IO.h"
#import "FFBuffer.h"
#import "libFFmpeg.hpp"
#import "FFUtils.h"
#import <QuartzCore/CABase.h>

@interface FFPacket () {
    @public
    AVPacket *_pkt;
}
@end


@interface FFInFormatContext () {
    @public
    AVFormatContext *_inFmtCtx;
    AVBitStreamFilterContext *_bitFilterCtx;
    AVIOContext *_inIOCtx;
    unsigned char *_inBuffer;
}

// Thread
@property(nonatomic, strong) dispatch_queue_t inQueue;
@property(nonatomic, strong) dispatch_queue_t readQueue;
@property(nonatomic, strong) dispatch_semaphore_t fmtCtxLock;
@property(nonatomic, strong) dispatch_semaphore_t readLock;

// VAR
@property(nonatomic, assign) BOOL isPreRead;
@property(nonatomic, assign) BOOL isReading;
@property(nonatomic, assign) BOOL isOpening;
@property(nonatomic, assign) int videoStreamIndex;
@property(nonatomic, assign) int audioStreamIndex;
@property(nonatomic, assign) BOOL isFFReading;

// Delegate
@property(nonatomic, assign) BOOL isHadReadVideoDelegate;
@property(nonatomic, assign) BOOL isHadReadAudioDelegate;
@property(nonatomic, assign) BOOL isHadInIODelegate;

// IO
@property(nonatomic, assign) int bufferSize;

// Other
@property(nonatomic, strong, readwrite, nullable) FFVideoInfo *videoInfo;
@property(nonatomic, strong, readwrite, nullable) FFAudioInfo *audioInfo;
@property(nonatomic, strong) FFBuffer *videoBuffer;
@property(nonatomic, strong) FFBuffer *audioBuffer;


// Method
- (void)_closeInIO;

@end


@implementation FFInFormatContext

@synthesize isPreRead = _isPreRead;
@synthesize isReading = _isReading;
@synthesize isFFReading = _isFFReading;

#pragma mark - <-- Initializer -->
+ (instancetype)context {
    FFInFormatContext *fmtCtx = [[FFInFormatContext alloc] init];
    return fmtCtx;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isReading = NO;
        self.videoStreamIndex = -1;
        self.audioStreamIndex = -1;
        self.bufferSize = 32 * 1024;
    }
    return self;
}

- (void)dealloc {
    [self _closeURL];
    [self _closeInIO];
    
    _inQueue = nil;
    _readQueue = nil;
    _delegate = nil;
}


#pragma mark - <-- Property -->
- (dispatch_queue_t)inQueue {
    if (!_inQueue) {
        _inQueue = dispatch_queue_create("com.dv.avkit.ff.in", NULL);
    }
    return _inQueue;
}

- (dispatch_queue_t)readQueue {
    if (!_readQueue) {
        _readQueue = dispatch_queue_create("com.dv.avkit.ff.read", NULL);
    }
    return _readQueue;
}

- (dispatch_semaphore_t)readLock {
    if (!_readLock) {
        _readLock = dispatch_semaphore_create(1);
    }
    return _readLock;
}

- (dispatch_semaphore_t)fmtCtxLock {
    if (!_fmtCtxLock) {
        _fmtCtxLock = dispatch_semaphore_create(1);
    }
    return _fmtCtxLock;
}

- (BOOL)isPreRead {
    dispatch_semaphore_wait(self.readLock, DISPATCH_TIME_FOREVER);
    BOOL ret = _isPreRead;
    dispatch_semaphore_signal(self.readLock);
    return ret;
}

- (void)setIsPreRead:(BOOL)isPreRead {
    dispatch_semaphore_wait(self.readLock, DISPATCH_TIME_FOREVER);
    _isPreRead = isPreRead;
    dispatch_semaphore_signal(self.readLock);
}

- (BOOL)isReading {
    dispatch_semaphore_wait(self.readLock, DISPATCH_TIME_FOREVER);
    BOOL ret = _isReading;
    dispatch_semaphore_signal(self.readLock);
    return ret;
}

- (void)setIsReading:(BOOL)isReading {
    dispatch_semaphore_wait(self.readLock, DISPATCH_TIME_FOREVER);
    _isReading = isReading;
    dispatch_semaphore_signal(self.readLock);
}

- (BOOL)isFFReading {
    dispatch_semaphore_wait(self.readLock, DISPATCH_TIME_FOREVER);
    BOOL ret = _isFFReading;
    dispatch_semaphore_signal(self.readLock);
    return ret;
}

- (void)setIsFFReading:(BOOL)isFFReading {
    dispatch_semaphore_wait(self.readLock, DISPATCH_TIME_FOREVER);
    _isFFReading = isFFReading;
    dispatch_semaphore_signal(self.readLock);
}

- (BOOL)isOpening {
    dispatch_semaphore_wait(self.fmtCtxLock, DISPATCH_TIME_FOREVER);
    BOOL ret = _inFmtCtx != NULL;
    dispatch_semaphore_signal(self.fmtCtxLock);
    return ret;
}

- (void)setDelegate:(id<FFInFormatContextDelegate>)delegate {
    _delegate = delegate;
    
    self.isHadReadVideoDelegate = delegate ? [delegate respondsToSelector:@selector(FFInFormatContext:readVideoPacket:)] : NO;
    self.isHadReadAudioDelegate = delegate ? [delegate respondsToSelector:@selector(FFInFormatContext:readAudioPacket:)] : NO;
    
    self.isHadInIODelegate = delegate ? [delegate respondsToSelector:@selector(FFInFormatContext:inIOPacket:)] : NO;
}

- (FFBuffer *)videoBuffer {
    if (!_videoBuffer) {
        _videoBuffer = [[FFBuffer alloc] init];
    }
    return _videoBuffer;
}

- (FFBuffer *)audioBuffer {
    if (!_audioBuffer) {
        _audioBuffer = [[FFBuffer alloc] init];
    }
    return _audioBuffer;
}


#pragma mark - <-- Public Method -->
- (void)openWithURL:(NSString *)url {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.inQueue, ^{
        [weakSelf _openWithURL:url];
    });
}

- (void)closeURL {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.inQueue, ^{
        [weakSelf _closeURL];
    });
}

- (void)startReadPacket {
    if (self.isReading) return;
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.readQueue, ^{
        [weakSelf _readPacket];
    });
}

- (void)stopReadPacket {
    self.isReading = NO;
}


#pragma mark - <-- Private Method -->
- (int)_openWithURL:(NSString *)url {
    [self _closeURL];
    
    int ret = 0;
    self.isFFReading = YES;
    
    // 1.打开 文件
    AVFormatContext *fmtCtx = NULL;
    if ((ret = [self _openInputWithFmtCtx:&fmtCtx url:url]) >= 0) {
        _inFmtCtx = fmtCtx;
        if (self.isPreRead) [self startReadPacket];
    } else {
        if (fmtCtx != NULL) [self _closeInputWithFmtCtx:&fmtCtx];
    }
    
    return ret < 0 ? NO : YES;
}

- (void)_closeURL {
    self.isFFReading = NO;
    self.isReading = NO;
    self.isPreRead = NO;
    self.videoInfo = nil;
    self.audioInfo = nil;
    [self.videoBuffer removeAllBuffer];
    [self.audioBuffer removeAllBuffer];
    if (_inFmtCtx != NULL) [self _closeInputWithFmtCtx:&_inFmtCtx];
}

- (void)_readPacket {
    if (_inFmtCtx == NULL) {
        self.isPreRead = YES;
        return;
    }
    
    if (self.isReading) return;
    self.isReading = YES;
    self.isPreRead = NO;
    
    AVPacket *pkt = av_packet_alloc();
    while (_inFmtCtx != NULL && av_read_frame(_inFmtCtx, pkt) >= 0) {
        if (!self.isReading) break;
        
        AVPacket *clonePkt = av_packet_clone(pkt);
        FFPacket *ffPkt = [[FFPacket alloc] init];
        ffPkt->_pkt = clonePkt;
        
        if (self.isHadReadVideoDelegate && self.videoStreamIndex == pkt->stream_index) {
            ffPkt.type = FFPacketTypeVideo;
            
            [self.delegate FFInFormatContext:self readVideoPacket:ffPkt];
            
//            [self.videoBuffer pushBuffer:ffPkt];
//            FFPacket *videoPkt = [self.videoBuffer popBuffer];
//            if (videoPkt) {
//                [self.delegate FFInFormatContext:self readVideoPacket:videoPkt];
//            }
        }
        else if (self.isHadReadAudioDelegate && self.audioStreamIndex == pkt->stream_index) {
            ffPkt.type = FFPacketTypeAudio;
            
            [self.delegate FFInFormatContext:self readAudioPacket:ffPkt];
            
//            [self.audioBuffer pushBuffer:ffPkt];
//            FFPacket *audioPkt = [self.audioBuffer popBuffer];
//            if (audioPkt) {
//                [self.delegate FFInFormatContext:self readAudioPacket:audioPkt];
//            }
        }
        
        av_packet_unref(pkt);
        ffPkt = nil;
    }
    av_packet_free(&pkt);
    self.isReading = NO;
}




#pragma mark - <-- New Method -->
- (int)_openInputWithFmtCtx:(AVFormatContext **)fmtCtx url:(NSString *)url {
    
    int ret = 0;
    
    do {
        
        // 1.初始化上下文
        *fmtCtx = avformat_alloc_context();
        (*fmtCtx)->interrupt_callback = {in_interrupt_callback, (__bridge void *)self};
        
        
        // 2.设置参数
        AVInputFormat *inputFmt = NULL;
        AVDictionary *opts = NULL;
        if ([url hasPrefix:@"rtmp"] || [url hasPrefix:@"rtsp"]) {
            av_dict_set(&opts, "timeout", NULL, 0);
            
            // 首屏优化
            (*fmtCtx)->max_streams = 2;
            (*fmtCtx)->probesize = 500 * 1024;
            (*fmtCtx)->max_analyze_duration = 2 * AV_TIME_BASE;
            (*fmtCtx)->fps_probe_size = 2;
        }
        
        // 3.打开文件
        double duration = CACurrentMediaTime();
        NSLog(@"[FFInFormatContext LOG]: 正在打开 URL: %@", url);
        ret = avformat_open_input(fmtCtx, [url UTF8String], inputFmt, &opts);
        av_dict_free(&opts);
        if (ret < 0) {
            av_log(NULL, AV_LOG_ERROR, "无法打开 URL: %s",[url UTF8String]);
            break;
        }
        
        NSLog(@"[FFInFormatContext LOG]: 打开URL耗费时间 -> %f s", CACurrentMediaTime() - duration);
        duration = CACurrentMediaTime();
        
        
        // 4.填充文件的流信息
        if ([url hasPrefix:@"rtmp"] || [url hasPrefix:@"rtsp"]) {
            // 首屏优化
            (*fmtCtx)->probesize = 500 * 1024;
            (*fmtCtx)->max_analyze_duration = 2 * AV_TIME_BASE;
            (*fmtCtx)->fps_probe_size = 2;
        }
        
        ret = avformat_find_stream_info(*fmtCtx, NULL);
        if (ret < 0) {
            av_log(NULL, AV_LOG_ERROR, "读取不到 Meta信息");
            break;
        }
        NSLog(@"[FFInFormatContext LOG]: 分析流信息耗费时间 -> %f s", CACurrentMediaTime() - duration);
        duration = CACurrentMediaTime();
        
        
        // 5.寻找视频流 音频流
        for (int i = 0; i < (*fmtCtx)->nb_streams; ++i) {
            
            AVStream *stream = (*fmtCtx)->streams[i];
            AVMediaType codecType = (AVMediaType)stream->codecpar->codec_type;
            
            switch (codecType) {
                case AVMEDIA_TYPE_VIDEO:
                    self.videoStreamIndex = i;
                    self.videoInfo = [self _analyVideoInfoWithStream:stream];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(FFInFormatContext:videoInfo:)]) {
                        [self.delegate FFInFormatContext:self videoInfo:self.videoInfo];
                    }
                    break;
                    
                case AVMEDIA_TYPE_AUDIO:
                    self.audioStreamIndex = i;
                    self.audioInfo = [self _analyAudioInfoWithStream:stream];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(FFInFormatContext:audioInfo:)]) {
                        [self.delegate FFInFormatContext:self audioInfo:self.audioInfo];
                    }
                    break;
                    
                default:
                    break;
            }
        }
        
        // 6.输出基本信息
        av_dump_format(*fmtCtx, 0, [url UTF8String], 0);
        
    } while (NO);
    
    return ret;
}

- (void)_closeInputWithFmtCtx:(AVFormatContext **)fmtCtx {
    if (*fmtCtx != NULL) {
        avformat_close_input(fmtCtx);
        avformat_free_context(*fmtCtx);
        *fmtCtx = NULL;
    }
}

- (FFVideoInfo *)_analyVideoInfoWithStream:(AVStream *)stream {
    
    FFVideoInfo *videoInfo = [[FFVideoInfo alloc] init];
    
    if (stream->codecpar->codec_id == AV_CODEC_ID_H264) {
        NSArray<NSData *> *extra = [FFUtils analyH264SpsPpsWithExtradata:stream->codecpar->extradata
                                                                    size:stream->codecpar->extradata_size];
        videoInfo.vps = nil;
        videoInfo.sps = extra ? (extra.count > 0 ? extra[0] : nil) : nil;
        videoInfo.pps = extra ? (extra.count > 1 ? extra[1] : nil) : nil;
        videoInfo.codecName = @"h264";
    } else if (stream->codecpar->codec_id == AV_CODEC_ID_HEVC) {
        NSArray<NSData *> *extra = [FFUtils analyHEVCVpsSpsPpsWithExtradata:stream->codecpar->extradata
                                                                       size:stream->codecpar->extradata_size];
        videoInfo.vps = extra ? (extra.count > 0 ? extra[0] : nil) : nil;
        videoInfo.sps = extra ? (extra.count > 1 ? extra[1] : nil) : nil;
        videoInfo.pps = extra ? (extra.count > 2 ? extra[2] : nil) : nil;
        videoInfo.codecName = @"hevc";
    }
    
    videoInfo.size = CGSizeMake(stream->codecpar->width, stream->codecpar->height);
    videoInfo.fps = av_q2d(stream->avg_frame_rate);
    videoInfo.bitRate = stream->codecpar->bit_rate;
    videoInfo.timeBase = CMTimeMake(stream->time_base.num, stream->time_base.den);
    videoInfo.pts = stream->start_time;
    videoInfo.dts = stream->first_dts;
    
    return videoInfo;
}

- (FFAudioInfo *)_analyAudioInfoWithStream:(AVStream *)stream {
    
    FFAudioInfo *audioInfo = [[FFAudioInfo alloc] init];
    
    if (stream->codecpar->codec_id == AV_CODEC_ID_AAC) {
        audioInfo.codecName = @"aac";
    }
    
    audioInfo.sampleRate = stream->codecpar->sample_rate;
    audioInfo.bitsPerChannel = stream->codecpar->bits_per_coded_sample;
    audioInfo.numberOfChannels = stream->codecpar->channels;
    audioInfo.extraData = [NSData dataWithBytes:stream->codecpar->extradata length:stream->codecpar->extradata_size];
    audioInfo.timeBase = CMTimeMake(stream->time_base.num, stream->time_base.den);
    audioInfo.pts = stream->start_time;
    audioInfo.dts = stream->first_dts;
    
    return audioInfo;
}


#pragma mark - <-- CallBack -->
int in_interrupt_callback(void *opaque) {
    
    FFInFormatContext *fmtCtx = (__bridge FFInFormatContext *)opaque;
    return fmtCtx.isFFReading ? 0 : -1;
}

@end
