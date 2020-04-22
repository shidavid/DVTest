//
//  FFOutFormatContext.m
//  DVAVKit
//
//  Created by 施达威 on 2019/3/30.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "FFOutFormatContext.h"
#import "FFUtils.h"
#import "FFBuffer.h"
#import "libFFmpeg.hpp"
#import "FFOutFormatContext+IO.h"

@interface FFPacket () {
    @public
    AVPacket *_pkt;
}
@end


@interface FFOutFormatContext () {
    @public
    AVFormatContext *_outFmtCtx;
    AVIOContext *_outIOCtx;
    unsigned char *_outBuffer;
}

// Thread
@property(nonatomic, strong) dispatch_queue_t outQueue;
@property(nonatomic, strong) dispatch_queue_t writeQueue;
@property(nonatomic, strong) dispatch_semaphore_t fmtCtxLock;
@property(nonatomic, strong) dispatch_semaphore_t writeLock;
@property(nonatomic, strong) dispatch_semaphore_t bufferLock;

// VAR
@property(nonatomic, copy, readwrite) NSString *url;
@property(nonatomic, assign) int videoStreamIndex;
@property(nonatomic, assign) int audioStreamIndex;
@property(nonatomic, assign) BOOL isWriting;
@property(nonatomic, assign) BOOL isFirstWrite;
@property(nonatomic, assign) int64_t write_pts;
@property(nonatomic, assign) int64_t write_dts;
@property(nonatomic, assign) int64_t write_last_pts;
@property(nonatomic, assign) int64_t write_last_dts;

// Delegate
@property(nonatomic, assign) BOOL isHadOutIODelegate;

// IO
@property(nonatomic, assign) int bufferSize;


@property(nonatomic, weak) FFInFormatContext *weakInFmtCtx;
@property(nonatomic, strong) FFBuffer *buffer;

// Method
- (void)_closeOutIO;

@end


@implementation FFOutFormatContext

@synthesize isWriting = _isWriting;

#pragma mark - <-- Initializer -->
+ (instancetype)contextFromInFmtCtx:(FFInFormatContext *)inFmtCtx {
    FFOutFormatContext *outFmtCtx = [[FFOutFormatContext alloc] init];
    outFmtCtx.weakInFmtCtx = inFmtCtx;
    return outFmtCtx;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isFirstWrite = YES;
        self.isWriting = NO;
        self.videoStreamIndex = -1;
        self.audioStreamIndex = -1;
        self.bufferSize = 32 * 1024;
        self.write_last_pts = -9999;
        self.write_last_dts = -9999;
    }
    return self;
}

- (void)dealloc {
    [self _closeURL];
    [self _closeOutIO];
    _outQueue = nil;
    _writeQueue = nil;
    _delegate = nil;
}


#pragma mark - <-- Property -->
- (dispatch_queue_t)outQueue {
    if (!_outQueue) {
        _outQueue = dispatch_queue_create("com.dv.avkit.ff.out", NULL);
    }
    return _outQueue;
}

- (dispatch_queue_t)writeQueue {
    if (!_writeQueue) {
        _writeQueue = dispatch_queue_create("com.dv.avkit.ff.write", NULL);
    }
    return _writeQueue;
}

- (dispatch_semaphore_t)writeLock {
    if (!_writeLock) {
        _writeLock = dispatch_semaphore_create(1);
    }
    return _writeLock;
}

- (dispatch_semaphore_t)fmtCtxLock {
    if (!_fmtCtxLock) {
        _fmtCtxLock = dispatch_semaphore_create(1);
    }
    return _fmtCtxLock;
}

- (dispatch_semaphore_t)bufferLock {
    if (!_bufferLock) {
        _bufferLock = dispatch_semaphore_create(1);
    }
    return _bufferLock;
}

- (BOOL)isWriting {
    dispatch_semaphore_wait(self.writeLock, DISPATCH_TIME_FOREVER);
    BOOL ret = _isWriting;
    dispatch_semaphore_signal(self.writeLock);
    return ret;
}

- (void)setIsWriting:(BOOL)isWriting {
    dispatch_semaphore_wait(self.writeLock, DISPATCH_TIME_FOREVER);
    _isWriting = isWriting;
    dispatch_semaphore_signal(self.writeLock);
    if (!isWriting) [self _writePacket];
}

- (BOOL)isOpening {
    dispatch_semaphore_wait(self.fmtCtxLock, DISPATCH_TIME_FOREVER);
    BOOL ret =  _outFmtCtx != NULL ;
    dispatch_semaphore_signal(self.fmtCtxLock);
    return ret;
}

- (void)setDelegate:(id<FFOutFormatContextDelegate>)delegate {
    _delegate = delegate;
    
    self.isHadOutIODelegate = delegate ? [delegate respondsToSelector:@selector(FFOutFormatContext:outIOPacket:)] : NO;
}

- (FFBuffer *)buffer {
    if (!_buffer) {
        _buffer = [[FFBuffer alloc] init];
    }
    return _buffer;
}


#pragma mark - <-- Public Method -->
- (void)openWithURL:(NSString *)url format:(NSString *)format {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.outQueue, ^{
        weakSelf.url = url;
        [weakSelf _openWithURL:url format:format];
    });
}

- (void)closeURL {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.outQueue, ^{
        [weakSelf _closeURL];
    });
}

- (void)writePacket:(FFPacket *)packet {
    if (!packet) return;
    [self.buffer pushBuffer:packet];
    [self _writePacket];
}


#pragma mark - <-- Private Method -->
- (BOOL)_openWithURL:(NSString *)url format:(NSString *)format {
    [self _closeURL];
    
    int ret = 0;
    
    // 1.初始化上下
    AVFormatContext *fmtCtx = NULL;
    
    // 2.打开 文件
    if ((ret = [self _openOutputWithFmtCtx:&fmtCtx url:url format:format]) >= 0) {
        
        _outFmtCtx = fmtCtx;
        
        self.isWriting = YES;
        if (self.weakInFmtCtx) {
           [FFUtils convertCodecparFromInFmtCtx:self.weakInFmtCtx toOutFmtCtx:self];
        }
        
        // 3.打开输出文件
        if (!(fmtCtx->oformat->flags & AVFMT_NOFILE)) {
            if (avio_open(&fmtCtx->pb, [url UTF8String], AVIO_FLAG_WRITE) < 0) {
                av_log(NULL, AV_LOG_ERROR, "Could not open output file '%s'", [url UTF8String]);
            }
        }
        
        // 4.写视频文件头
        if (avformat_write_header(fmtCtx, NULL) < 0) {
            av_log(NULL, AV_LOG_ERROR, "无法写入头信息");
        }
        
        self.isWriting = NO;
    } else {
        if (fmtCtx != NULL) [self _closeOutputWithFmtCtx:&fmtCtx];
    }
    
    return ret < 0 ? NO : YES;
}

- (void)_closeURL {
    dispatch_semaphore_wait(self.fmtCtxLock, DISPATCH_TIME_FOREVER);
    _isFirstWrite = YES;
    _isWriting = NO;
    if (_outFmtCtx != NULL) [self _closeOutputWithFmtCtx:&_outFmtCtx];
    dispatch_semaphore_signal(self.fmtCtxLock);
}

- (void)_writePacket {
    if (self.isWriting || self.buffer.bufferCount == 0 || _outFmtCtx == NULL) return;
    
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.writeQueue, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (weakSelf.isWriting || weakSelf.buffer.bufferCount == 0 || strongSelf->_outFmtCtx == NULL) return;
        
        do {
            FFPacket *ffPkt = [weakSelf.buffer popBuffer];
            
            if (weakSelf.isFirstWrite && ffPkt->_pkt->pts == ffPkt->_pkt->dts) {
                weakSelf.write_pts = ffPkt->_pkt->pts;
                weakSelf.write_dts = ffPkt->_pkt->dts;
                weakSelf.isFirstWrite = NO;
            }
            
            if (weakSelf.isFirstWrite) break;
            
            ffPkt->_pkt->pts -= weakSelf.write_pts;
            ffPkt->_pkt->dts -= weakSelf.write_dts;
            
            if (ffPkt->_pkt->pts == weakSelf.write_last_pts) ffPkt->_pkt->pts += 1;
            if (ffPkt->_pkt->dts == weakSelf.write_last_dts) ffPkt->_pkt->dts += 1;
            weakSelf.write_last_pts = ffPkt->_pkt->pts;
            weakSelf.write_last_dts = ffPkt->_pkt->dts;
            
            if (weakSelf.weakInFmtCtx) {
                [FFUtils convertTimeBaseWithPacket:ffPkt
                                      fromInFmtCtx:weakSelf.weakInFmtCtx
                                       toOutFmtCtx:weakSelf];
            }
            
            av_interleaved_write_frame(strongSelf->_outFmtCtx, ffPkt->_pkt);
            

        } while (NO);
        
        weakSelf.isWriting = NO;
    });
}


#pragma mark - <-- New Method -->
- (int)_openOutputWithFmtCtx:(AVFormatContext **)fmtCtx
                         url:(NSString *)url
                      format:(NSString *)format {
    int ret = 0;
    
    // 1.初始化上下文
//    *fmtCtx = avformat_alloc_context();
    
    // 2.打开文件
    ret = avformat_alloc_output_context2(fmtCtx, NULL, [format UTF8String], [url UTF8String]);
    if (ret < 0) {
        av_log(NULL, AV_LOG_ERROR, "无法打开 输出URL -> %s", [url UTF8String]);
    }

    av_dump_format(*fmtCtx, 0, [url UTF8String], 1);
    
    return ret;
}

- (void)_closeOutputWithFmtCtx:(AVFormatContext **)fmtCtx {
    if (*fmtCtx != NULL) {
        av_write_trailer(*fmtCtx);
        avformat_free_context(*fmtCtx);
        *fmtCtx = NULL;
        if (self.delegate && [self.delegate respondsToSelector:@selector(FFOutFormatContextDidFinishedOutput:)]) {
            [self.delegate FFOutFormatContextDidFinishedOutput:self];
        }
    }
}

@end
