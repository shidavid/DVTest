//
//  DVGLPreview.m
//  DVAVKit
//
//  Created by DV on 2019/4/2.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVGLPreview.h"
#import <CoreVideo/CoreVideo.h>

@interface DVGLPreview () {
    CVOpenGLESTextureCacheRef _textureCacheRef;
    
    CVOpenGLESTextureRef _yTextureRef;
    CVOpenGLESTextureRef _uvTextureRef;
    
    CVOpenGLESTextureRef _rgbTextureRef;
}

@end

@implementation DVGLPreview

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initCacheRef];
        [self initVertices];
    }
    return self;
}

- (void)initCacheRef {
    CVOpenGLESTextureCacheRef textureCacheRef;
    
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &textureCacheRef);
    if (err != noErr) {
        NSLog(@"[DVGLPreview ERROR]: create texture cache error");
        if (textureCacheRef != NULL) CFRelease(textureCacheRef);
    } else {
        _textureCacheRef = textureCacheRef;
    }
}

- (void)initVertices {
    const GLfloat vertices[] = {
        -1.0f, -1.0f, 0.0f,     0.0f, 0.0f,
         1.0f, -1.0f, 0.0f,     1.0f, 0.0f,
        -1.0f,  1.0f, 0.0f,     0.0f, 1.0f,
         1.0f,  1.0f, 0.0f,     1.0f, 1.0f,
    };
    
    const GLubyte indeices[] = {
        0, 1, 2,
        1, 2, 3,
    };
    
    
    [self bindVertexBufferWithVertices:(GLfloat *)vertices size:sizeof(vertices)];
    [self bindIndexBufferWithIndices:(GLubyte *)indeices size:sizeof(indeices)];
    
    [self enableVertexAttribPositionWithIndex:0 len:3 stride:5];
    [self enableVertexAttribTexCoord0WithIndex:3 len:2 stride:5];
}


- (void)displayWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (pixelBuffer == NULL || _textureCacheRef == NULL) return;
    [self clearLayer];
    
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    [EAGLContext setCurrentContext:self.context];
    
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    
    if (type == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        || type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        
        CVOpenGLESTextureRef yTextureRef;
        CVOpenGLESTextureRef uvTextureRef = NULL;
        CVReturn error;
        
        do {
            error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                         _textureCacheRef,
                                                                         pixelBuffer,
                                                                         NULL,
                                                                         GL_TEXTURE_2D,
                                                                         GL_LUMINANCE,
                                                                         width,
                                                                         height,
                                                                         GL_LUMINANCE,
                                                                         GL_UNSIGNED_BYTE,
                                                                         0,
                                                                         &yTextureRef);
            if (error) {
                NSLog(@"yTextureRef 失败");
                break;
            }
                    
                    
            error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                 _textureCacheRef,
                                                                 pixelBuffer,
                                                                 NULL,
                                                                 GL_TEXTURE_2D,
                                                                 GL_LUMINANCE_ALPHA,
                                                                 width / 2,
                                                                 height / 2,
                                                                 GL_LUMINANCE_ALPHA,
                                                                 GL_UNSIGNED_BYTE,
                                                                 1,
                                                                 &uvTextureRef);
            if (error) {
                NSLog(@"uvTextureRef 失败");
                break;
            }
            
            
            GLenum target = CVOpenGLESTextureGetTarget(yTextureRef);
            GLuint name = CVOpenGLESTextureGetName(yTextureRef);
            GLenum target1 = CVOpenGLESTextureGetTarget(uvTextureRef);
            GLuint name1 = CVOpenGLESTextureGetName(uvTextureRef);
            
            self.baseEffect.texture2d0.enabled = GL_TRUE;
//            self.baseEffect.texture2d0.target = target;
            self.baseEffect.texture2d0.name = name;
            
            self.baseEffect.texture2d1.enabled = GL_TRUE;
//            self.baseEffect.texture2d1.target = target1;
            self.baseEffect.texture2d1.name = name1;
            
        } while (NO);
        
        if (yTextureRef) CFRelease(yTextureRef);
        if (uvTextureRef) CFRelease(uvTextureRef);
        
        

    }
    else if (type == kCVPixelFormatType_32BGRA) {
        
        
        
        
        
        
        
    }
    
    
    
    
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self drawElements];
}




@end
