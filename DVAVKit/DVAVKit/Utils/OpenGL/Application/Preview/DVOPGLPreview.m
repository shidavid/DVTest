//
//  DVOPGLPreview.m
//  DVAVKit
//
//  Created by 施达威 on 2019/4/3.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVOPGLPreview.h"
#import <CoreVideo/CoreVideo.h>
#import <AVFoundation/AVUtilities.h>


@interface DVOPGLPreview () {
    GLuint _verticesBuffer;
    GLuint _indicsBuffer;
    
    GLuint _position;
    GLuint _texCoord;
    GLuint _yTexture;
    GLuint _uvTexture;
    GLuint _colorMatrix;
    
    CVOpenGLESTextureCacheRef _textureCacheRef;
}

@property(nonatomic, assign) int lastWidth;
@property(nonatomic, assign) int lastHeight;
@property(nonatomic, assign) CGRect lastLayerBound;

@end


@implementation DVOPGLPreview




#pragma mark - <-- Initializer -->
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        glDisable(GL_DEPTH_TEST);
        self.lastLayerBound = self.layer.bounds;
        [self initCacheRef];
        [self initLocation];
    }
    return self;
}

- (void)dealloc {
    [self clearLayer];
    [self deleteBuffer:&_verticesBuffer];
    [self deleteBuffer:&_indicsBuffer];
    [self disableVertexAttrib:&_position];
    [self disableVertexAttrib:&_texCoord];
    if(_textureCacheRef) CFRelease(_textureCacheRef);
}

- (void)initCacheRef {
    CVOpenGLESTextureCacheRef textureCacheRef;
    
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                                                NULL,
                                                self.context,
                                                NULL,
                                                &textureCacheRef);
    if (err != noErr) {
        NSLog(@"[DVGLPreview ERROR]: create texture cache error");
        if (textureCacheRef != NULL) CFRelease(textureCacheRef);
        return;
    }
    
    _textureCacheRef = textureCacheRef;
}

- (void)initLocation {
    _position = [self getAttribLocationWithName:@"position"];
    _texCoord = [self getAttribLocationWithName:@"inTexcoord"];
    _yTexture = [self getUniformLocationWithName:@"yTexture"];
    _uvTexture = [self getUniformLocationWithName:@"uvTexture"];
    _colorMatrix = [self getUniformLocationWithName:@"colorMatrix"];
}

- (void)setupVerticesIndeicsWithWidth:(int)width height:(int)height {
    CGSize ratio = CGSizeMake(width, height);
    CGRect sampleRect = AVMakeRectWithAspectRatioInsideRect(ratio, self.layer.bounds);
    
    CGFloat w = sampleRect.size.width / (sampleRect.size.width + sampleRect.origin.x * 2);
    CGFloat h = sampleRect.size.height / (sampleRect.size.height + sampleRect.origin.y * 2);
    
    if (w >= 0.99) w = 1.0f;
    if (h >= 0.99) h = 1.0f;
    
    CGSize noramlSize = CGSizeMake(w, h);
    
    const GLfloat vertices[] = {
        -1 * noramlSize.width, -1*noramlSize.height, 0.0f,      0.0f, 1.0f,
             noramlSize.width, -1*noramlSize.height, 0.0f,      1.0f, 1.0f,
        -1 * noramlSize.width,    noramlSize.height, 0.0f,      0.0f, 0.0f,
             noramlSize.width,    noramlSize.height, 0.0f,      1.0f, 0.0f,
    };
    
//    const GLfloat vertices[] = {
//        -1.0f, -1.0f, 0.0f,     0.0f, 1.0f,
//         1.0f, -1.0f, 0.0f,     1.0f, 1.0f,
//        -1.0f,  1.0f, 0.0f,     0.0f, 0.0f,
//         1.0f,  1.0f, 0.0f,     1.0f, 0.0f,
//    };
//
    const GLubyte indeices[] = {
        0, 1, 2,
        1, 2, 3,
    };
    
    [self createBuffer:&_verticesBuffer vertices:(GLfloat *)vertices size:sizeof(vertices)];
    [self createBuffer:&_indicsBuffer indices:(GLubyte *)indeices size:sizeof(indeices)];
    [self enableVertexAttrib:&_position index:0 len:3 stride:5];
    [self enableVertexAttrib:&_texCoord index:3 len:2 stride:5];
}


#pragma mark - <-- Public Method -->
- (void)displayWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    __weak __typeof(self)weakSelf = self;
    CFRetain(pixelBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf _displayWithPixelBuffer:pixelBuffer];
        CFRelease(pixelBuffer);
    });
}

- (void)_displayWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (pixelBuffer == NULL || _textureCacheRef == NULL) return;
    [self clearLayer];
    
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    
    if (type == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        || type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        [self displayY420WithPixelBuffer:pixelBuffer];
    }
    else if (type == kCVPixelFormatType_32BGRA) {
        [self displayRGBWithPixelBuffer:pixelBuffer];
    }
}

- (void)displayY420WithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    CVOpenGLESTextureRef yTextureRef = NULL;
    CVOpenGLESTextureRef uvTextureRef = NULL;
    CVReturn error;
    
    do {
        // 1.获取 y分量纹理
        glActiveTexture(GL_TEXTURE0);
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
        
        // 绑定纹理
        GLenum yTarget = CVOpenGLESTextureGetTarget(yTextureRef);
        GLuint yName = CVOpenGLESTextureGetName(yTextureRef);
        glBindTexture(yTarget, yName);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                
            
        // 2.获取uv分量纹理
        glActiveTexture(GL_TEXTURE1);
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
        
        // 绑定纹理
        GLenum uvTarget = CVOpenGLESTextureGetTarget(uvTextureRef);
        GLuint uvName = CVOpenGLESTextureGetName(uvTextureRef);
        glBindTexture(uvTarget, uvName);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        
        
        if (self.lastWidth != width || self.lastHeight != height) {
            self.lastWidth = width;
            self.lastHeight = height;
            
            // 3.设置顶点
            [self setupVerticesIndeicsWithWidth:width height:height];
            
            // 4.颜色空间转换
            const GLfloat *colorConversion = [self getColorConversionFromPixelBuffer:pixelBuffer];
           
            glUniform1i(_yTexture, 0);
            glUniform1i(_uvTexture, 1);
            glUniformMatrix3fv(_colorMatrix, 1, GL_FALSE, colorConversion);
        }
        
        
        // 5.绘画
        [self drawElements];
        
        
        // 6.解绑纹理
        glBindTexture(yTarget, 0);
        glBindTexture(uvTarget, 0);
        
    } while (NO);
    
    if (yTextureRef) CFRelease(yTextureRef);
    if (uvTextureRef) CFRelease(uvTextureRef);
    if (_textureCacheRef) CVOpenGLESTextureCacheFlush(_textureCacheRef, 0);
}

- (void)displayRGBWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
}


#pragma mark - <-- Private Method -->
// BT.601, which is the standard for SDTV.
static const GLfloat kColorConversion601[] = {
        1.164,  1.164, 1.164,
          0.0, -0.392, 2.017,
        1.596, -0.813,   0.0,
};

// BT.709, which is the standard for HDTV.
static const GLfloat kColorConversion709[] = {
        1.164,  1.164, 1.164,
          0.0, -0.213, 2.112,
        1.793, -0.533,   0.0,
};

// BT.601 full range (ref: http://www.equasys.de/colorconversion.html)
const GLfloat kColorConversion601FullRange[] = {
    1.0,    1.0,    1.0,
    0.0,    -0.343, 1.765,
    1.4,    -0.711, 0.0,
};

- (const GLfloat *)getColorConversionFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
    CFTypeRef attachment = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
    
    if (attachment == kCVImageBufferYCbCrMatrix_ITU_R_601_4) {
        if (self.isFullYUVRange) return kColorConversion709;
        else return kColorConversion601;
    } else {
        return kColorConversion709;
    }
}


#pragma mark - <-- Delegate -->
- (NSString *)fragmentShaderBundleName {
    return @"pre_fragment.fs";
}

- (NSString *)vertexShaderBundleName {
    return @"pre_vertex.vs";
}

@end
