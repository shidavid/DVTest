//
//  DVOPGLContextLayer.m
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVOPGLContextLayer.h"

@interface DVOPGLContextLayer ()

@property(nonatomic, strong, readwrite) EAGLContext *context;
@property(nonatomic, assign) GLuint frameBuffer;
@property(nonatomic, assign) GLuint renderBuffer;
@property(nonatomic, assign, readwrite) GLint glWidth;
@property(nonatomic, assign, readwrite) GLint glHeight;

@end


@implementation DVOPGLContextLayer

#pragma mark - <-- Initializer -->
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initContext];
        [self initLayers];
        [self initRenderBuffer];
        [self initFrameBuffer];
        [self checkBufferStatus];
    }
    return self;
}

- (void)dealloc {
    if (_frameBuffer) {
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_renderBuffer) {
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:nil];
    _context = nil;
    [EAGLContext setCurrentContext:nil]; // 释放内存一直要设nil
}


#pragma mark - <-- Property -->
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


#pragma mark - <-- Init -->
/// 创建渲染的上下文环境
- (void)initContext {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSAssert(context, @"OpenGL create context failed");
    
    BOOL ret = [EAGLContext setCurrentContext:context];
    NSAssert(ret, @"OpenGL set context failed");
    
    self.context = context;
}


/// 设置layer属性
- (void)initLayers {
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    CAEAGLLayer *layer = (CAEAGLLayer *)[self layer];
    
    NSDictionary *dict = @{kEAGLDrawablePropertyRetainedBacking:@(NO),
                           kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    
    layer.opaque = YES;
    layer.drawableProperties = dict;
}

/// 创建绘制缓冲区
- (void)initRenderBuffer {
    glGenRenderbuffers(1, &_renderBuffer); // 创建绘制缓冲区
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer); // 绑定缓冲区
    
    // 为绘制缓冲区分配内存
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    // 获取绘制缓冲区像素高度/宽度
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_glWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_glHeight);
}

/// 创建帧缓冲区
- (void)initFrameBuffer {
    glGenFramebuffers(1, &_frameBuffer); // 创建帧缓冲区
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer); // 绑定帧缓冲区
    
    // //将绘制缓冲区绑定到帧缓冲区
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

- (void)checkBufferStatus {
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSAssert(NO, @"failed to make complete frame buffer object!");
    }
    
    GLenum glError = glGetError();
    if (glError != GL_NO_ERROR) {
        NSString *errLog = [NSString stringWithFormat:@"failed to setup GL %x", glError];
        NSAssert(NO, errLog);
    }
}

@end
