//
//  FFOutFormatContext+IO.m
//  DVAVKit
//
//  Created by DV on 2019/3/31.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "FFOutFormatContext+IO.h"
#import "FFBuffer.h"
#import "libFFmpeg.hpp"
#import "FFPacket.h"

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
@property(nonatomic, assign) BOOL isWriting;
@property(nonatomic, assign) int videoStreamIndex;
@property(nonatomic, assign) int audioStreamIndex;
@property(nonatomic, assign) BOOL isFirstWrite;
@property(nonatomic, assign) int64_t write_pts;
@property(nonatomic, assign) int64_t write_dts;

// Delegate
@property(nonatomic, assign) BOOL isHadOutIODelegate;

// IO
@property(nonatomic, assign) int bufferSize;


@property(nonatomic, weak) FFInFormatContext *weakInFmtCtx;
@property(nonatomic, strong) FFBuffer *buffer;

// Method
- (int)_openOutputWithFmtCtx:(AVFormatContext **)fmtCtx
                         url:(NSString *)url
                      format:(NSString *)format;
- (void)_closeOutputWithFmtCtx:(AVFormatContext **)fmtCtx;

@end


@implementation FFOutFormatContext (IO)

#pragma mark - <-- Initializer -->
+ (instancetype)IOWithBufferSize:(int)bufferSize {
    FFOutFormatContext *fmtCtx = [[FFOutFormatContext alloc] init];
    fmtCtx.bufferSize = bufferSize;
    return fmtCtx;
}


#pragma mark - <-- Public Method -->
- (void)openIOWithFormat:(NSString *)format {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.outQueue, ^{
        [weakSelf _openOutIOWithFormat:format];
    });
}

- (void)closeIO {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.outQueue, ^{
        [weakSelf _closeOutIO];
    });
}


#pragma mark - <-- Private Method -->
- (void)_openOutIOWithFormat:(NSString *)format {
    [self _closeOutIO];
    
    int ret = 0;
    AVFormatContext  *fmtCtx = NULL;
    AVIOContext *ioCtx = NULL;
    unsigned char *buffer = NULL;
    

    // 1.打开 文件
    if ((ret = [self _openOutputWithFmtCtx:&fmtCtx url:@"nothing" format:format]) >= 0) {
        
        // 3.初始化IO口
        [self _openBufferIO:&ioCtx buffer:&buffer size:self.bufferSize];
        fmtCtx->pb = ioCtx;
        fmtCtx->flags = AVFMT_FLAG_CUSTOM_IO; // 自定义IO
        
        _outFmtCtx = fmtCtx;
        _outIOCtx = ioCtx;
        _outBuffer = buffer;
        
    } else {
        if (fmtCtx != NULL) [self _closeOutputWithFmtCtx:&fmtCtx];
        if (ioCtx != NULL || buffer != NULL) [self _closeBufferIO:&ioCtx buffer:&buffer];
    }
}

- (void)_closeOutIO {
    if (_outIOCtx != NULL || _outBuffer != NULL) [self _closeBufferIO:&_outIOCtx buffer:&_outBuffer];
    if (_outFmtCtx != NULL) [self _closeOutputWithFmtCtx:&_outFmtCtx];
}


#pragma mark - <-- New Method -->
- (void)_openBufferIO:(AVIOContext **)ioCtx
               buffer:(unsigned char **)buffer
                 size:(int)size {
   
    *buffer = (unsigned char *)av_malloc(size);
    void *opaque = (__bridge void *)self;
    *ioCtx = avio_alloc_context(*buffer, size, 1, opaque, NULL, outBufferCallBack, NULL);
}

- (void)_closeBufferIO:(AVIOContext **)ioCtx buffer:(unsigned char **)buffer {
    if (*ioCtx != NULL) {
        avio_close(*ioCtx);
        av_free(*ioCtx);
        *ioCtx = NULL;
    }
    
    if (*buffer != NULL) {
        av_free(*buffer);
        *buffer = NULL;
    }
}


#pragma mark - <-- Callback Method -->
int outBufferCallBack(void *opaque, uint8_t *buf, int bufSize) {
    
    FFOutFormatContext *fmtCtx = (__bridge FFOutFormatContext *)opaque;

    if (fmtCtx.isHadOutIODelegate) {
        AVPacket *pkt = NULL;
        av_new_packet(pkt, bufSize);
        memcpy(pkt->data, buf, bufSize);
        
        FFPacket *ffPkt = [[FFPacket alloc] init];
        ffPkt->_pkt = pkt;
        [fmtCtx.delegate FFOutFormatContext:fmtCtx outIOPacket:ffPkt];
    }
    
    return bufSize;
}

@end
