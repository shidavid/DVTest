//
//  FFInFormatContext+IO.m
//  DVAVKit
//
//  Created by DV on 2019/3/31.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "FFInFormatContext+IO.h"
#import "libFFmpeg.hpp"


@interface FFInFormatContext () {
    @public
    AVFormatContext *_inFmtCtx;
    AVIOContext *_inIOCtx;
    unsigned char *_inBuffer;
}

// Thread
@property(nonatomic, strong) dispatch_queue_t inQueue;
@property(nonatomic, strong) dispatch_queue_t readQueue;
@property(nonatomic, strong) dispatch_semaphore_t fmtCtxLock;
@property(nonatomic, strong) dispatch_semaphore_t readLock;

// VAR
@property(nonatomic, assign) BOOL isReading;
@property(nonatomic, assign) int videoStreamIndex;
@property(nonatomic, assign) int audioStreamIndex;

// Delegate
@property(nonatomic, assign) BOOL isHadReadVideoDelegate;
@property(nonatomic, assign) BOOL isHadReadAudioDelegate;
@property(nonatomic, assign) BOOL isHadInIODelegate;

// IO
@property(nonatomic, assign) int bufferSize;


// Method
- (void)_readPacket;
- (int)_openInputWithFmtCtx:(AVFormatContext **)fmtCtx url:(NSString *)url;
- (void)_closeInputWithFmtCtx:(AVFormatContext **)fmtCtx;

@end


@implementation FFInFormatContext (IO)

#pragma mark - <-- Initializer -->
+ (instancetype)IOWithBufferSize:(int)bufferSize {
    FFInFormatContext *fmtCtx = [[FFInFormatContext alloc] init];
    fmtCtx.bufferSize = bufferSize;
    return fmtCtx;
}


#pragma mark - <-- Public Method -->
- (void)openIO {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.inQueue, ^{
        [weakSelf _openInIO];
    });
}

- (void)closeIO {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.inQueue, ^{
        weakSelf.isReading = NO;
        [weakSelf _closeInIO];
    });
}

- (void)startReadIO {
    if (self.isReading) return;
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.readQueue, ^{
        [weakSelf _readPacket];
    });
}

- (void)stopReadIO {
    self.isReading = NO;
}


#pragma mark - <-- Private Method -->
- (BOOL)_openInIO {
    [self _closeInIO];
    
    int ret = 0;
    AVFormatContext *fmtCtx = NULL;
    AVIOContext *ioCtx = NULL;
    unsigned char *buffer = NULL;
    
    // 1.初始化IO口
    [self _openBufferIO:&ioCtx buffer:&buffer size:self.bufferSize];
    fmtCtx->pb = ioCtx;
    fmtCtx->flags = AVFMT_FLAG_CUSTOM_IO; // 自定义IO
    fmtCtx->interrupt_callback = {in_buffer_interrupt_callback, (__bridge void *)self};
    
    // 2.打开 文件
    if ((ret = [self _openInputWithFmtCtx:&fmtCtx url:@"nothing"]) >= 0) {
        _inFmtCtx = fmtCtx;
        _inIOCtx = ioCtx;
        _inBuffer = buffer;
    } else {
        if (fmtCtx != NULL) [self _closeInputWithFmtCtx:&fmtCtx];
        if (ioCtx != NULL || buffer != NULL) [self _closeBufferIO:&ioCtx buffer:&buffer];
    }
    
    return ret < 0 ? NO : YES;
}

- (void)_closeInIO {
    if (_inIOCtx != NULL || _inBuffer != NULL) [self _closeBufferIO:&_inIOCtx buffer:&_inBuffer];
    if (_inFmtCtx != NULL) [self _closeInputWithFmtCtx:&_inFmtCtx];
}


#pragma mark - <-- New Method -->
- (void)_openBufferIO:(AVIOContext **)ioCtx
               buffer:(unsigned char **)buffer
                 size:(int)size {
   
    *buffer = (unsigned char *)av_malloc(size);
    void *opaque = (__bridge void *)self;
    *ioCtx = avio_alloc_context(*buffer, size, 0, opaque, inBufferCallBack, NULL, NULL);
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
int inBufferCallBack(void *opaque, uint8_t *buf, int bufSize) {
    
    FFInFormatContext *fmtCtx = (__bridge FFInFormatContext *)opaque;
    int size = 0;
    if (fmtCtx.isHadInIODelegate) {
        
    }
    
    return size;
}

int in_buffer_interrupt_callback(void *opaque) {
    
    FFInFormatContext *fmtCtx = (__bridge FFInFormatContext *)opaque;
    
    
    return 0;
}

@end
