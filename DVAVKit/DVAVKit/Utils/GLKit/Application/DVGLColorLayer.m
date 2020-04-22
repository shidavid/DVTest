//
//  DVGLColorLayer.m
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVGLColorLayer.h"

@interface DVGLColorLayer ()

@end

@implementation DVGLColorLayer

#pragma mark - <-- Instancetype -->
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        [self initVertices];
        
    }
    return self;
}


#pragma mark - <-- Init -->
- (void)initVertices {
    const GLfloat vertices[] = {
        -1.0f,  1.0f, 0.0f,      0.0f, 0.0f, 1.0f, 1.0f,
         1.0f,  1.0f, 0.0f,      0.8f, 0.8f, 1.0f, 1.0f,
        -1.0f, -1.0f, 0.0f,      0.0f, 0.0f, 1.0f, 1.0f,
         1.0f, -1.0f, 0.0f,      0.6f, 0.6f, 1.0f, 1.0f,
    };
    
    const GLubyte indeices[] = {
        0, 1, 2,
        1, 2, 3,
    };
    
    [self bindVertexBufferWithVertices:(GLfloat *)vertices size:sizeof(vertices)];
    [self bindIndexBufferWithIndices:(GLubyte *)indeices size:sizeof(indeices)];
    
    [self enableVertexAttribPositionWithIndex:0 len:3 stride:7];
    [self enableVertexAttribColorWithIndex:3 len:4 stride:7];
}


#pragma mark - <-- Delegate -->
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self drawElements];
}


@end
