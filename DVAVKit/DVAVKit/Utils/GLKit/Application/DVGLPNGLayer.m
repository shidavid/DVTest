//
//  DVGLPNGLayer.m
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVGLPNGLayer.h"
#import "GLKTextureLoader+DVGL.h"

@interface DVGLPNGLayer () 

@end


@implementation DVGLPNGLayer

#pragma mark - <-- Instancetype -->
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        [self initVertices];
        [self initTexture];
    }
    return self;
}


#pragma mark - <-- Init -->
- (void)initVertices {

    const GLfloat vertices[] = {
        -0.9f, -0.6f, 0.0f,     0.0f, 0.0f,
         0.9f, -0.6f, 0.0f,     1.0f, 0.0f,
        -0.9f,  0.6f, 0.0f,     0.0f, 1.0f,
         0.9f,  0.6f, 0.0f,     1.0f, 1.0f,
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

- (void)initTexture {    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithBundleName:@"1.png"];
    
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    self.baseEffect.texture2d0.name = textureInfo.name;
}


#pragma mark - <-- Delegate -->
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self drawElements];
}

@end
