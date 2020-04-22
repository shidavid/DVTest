//
//  DVGLContextLayer.m
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVGLContextLayer.h"

@interface DVGLContextLayer ()


@end

@implementation DVGLContextLayer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initContext];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}


#pragma mark - <-- Init -->
- (void)initContext {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSAssert(context, @"OpenGL create context failed");
    
    BOOL ret = [EAGLContext setCurrentContext:context];
    NSAssert(ret, @"OpenGL set context failed");
    
    self.context = context;
    self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888; // 颜色格式
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;       // 深度格式
}

@end
