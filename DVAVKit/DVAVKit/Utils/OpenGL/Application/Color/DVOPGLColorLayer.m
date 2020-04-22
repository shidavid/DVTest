//
//  DVOPGLColorLayer.m
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVOPGLColorLayer.h"

@interface DVOPGLColorLayer ()

@property(nonatomic, assign) GLuint verticesBuffer;
@property(nonatomic, assign) GLuint indicesBuffer;
@property(nonatomic, assign) GLuint positionAttr;
@property(nonatomic, assign) GLuint colorAttr;
@property(nonatomic, strong) dispatch_queue_t glQueue;

@end

@implementation DVOPGLColorLayer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.glQueue = dispatch_queue_create("com.opengl.2d", NULL);
        [self initRender];
        [self render];
    }
    return self;
}

- (void)dealloc {
    [self deleteBuffer:&_verticesBuffer];
    [self deleteBuffer:&_indicesBuffer];
    [self disableVertexAttrib:&_positionAttr];
    [self disableVertexAttrib:&_colorAttr];
}

- (void)initRender {

    const GLfloat vertices[] = {
        -1.f, -1.f, 0.f,  1,0,0,1,
         1.f, -1.f, 0.f,  0.8,0,0,1,
        -1.f,  1.f, 0.f,  1,0,0,1,
         1.f,  1.f, 0.f,  0.6,0,0,1,
    };

    const GLubyte indices[] = {
        0,  1,  2,
        1,  2,  3
    };
    
    [self createBuffer:&_verticesBuffer vertices:(GLfloat *)vertices size:sizeof(vertices)];
    [self createBuffer:&_indicesBuffer indices:(GLubyte *)indices size:sizeof(indices)];
    
    _positionAttr = [self getAttribLocationWithName:@"position"];
    _colorAttr = [self getAttribLocationWithName:@"inColor"];
    
    [self enableVertexAttrib:&_positionAttr index:0 len:3 stride:7];
    [self enableVertexAttrib:&_colorAttr index:3 len:4 stride:7];
}

- (void)render {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.glQueue, ^{
        [weakSelf _render];
    });
}

- (void)_render {
    [self clearLayer];
    [self drawElements];
}


#pragma mark - <-- DataSource -->
- (NSString *)vertexShaderBundleName {
    return @"color_vertex.vs";
}

- (NSString *)fragmentShaderBundleName {
    return @"color_fragment.fs";
}

@end
