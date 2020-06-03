//
//  DVOPGLPNGLayer.m
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVOPGLPNGLayer.h"

@interface DVOPGLPNGLayer ()

@property(nonatomic, assign) GLuint vertexBuffer;
@property(nonatomic, assign) GLuint indexBuffer;
@property(nonatomic, assign) GLuint positionAttr;
@property(nonatomic, assign) GLuint texCoordAttr;
@property(nonatomic, assign) GLuint inputImageTex;
@property(nonatomic, assign) GLuint texId;
@property(nonatomic, strong) dispatch_queue_t glQueue;

@end


@implementation DVOPGLPNGLayer

#pragma mark - <-- Initializer -->
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.glQueue = dispatch_queue_create("com.dv.avkit.opgl.demo.png", NULL);
        [self initRender];
    }
    return self;
}

- (void)dealloc {
    [self deleteBuffer:&_vertexBuffer];
    [self deleteBuffer:&_indexBuffer];
    [self disableVertexAttrib:&_positionAttr];
    [self disableVertexAttrib:&_texCoordAttr];
    [self deleteTexture:&_texId];
}


#pragma mark - <-- Init -->
- (void)initRender {
//
//    const GLfloat vertices[] = {
//          -1.0f, -1.0f, 0.0f,   0.0f, 1.0f,
//           1.0f, -1.0f, 0.0f,   1.0f, 1.0f,
//          -1.0f,  1.0f, 0.0f,   0.0f, 0.0f,
//           1.0f,  1.0f, 0.0f,   1.0f, 0.0f,
//    };
    
    const GLfloat vertices[] = {
          -1.0f,  1.0f, 0.0f,   0.0f, 0.0f,
           1.0f,  1.0f, 0.0f,   1.0f, 0.0f,
          -1.0f,  -1.0f, 0.0f,   0.0f, 1.0f,
           1.0f,  -1.0f, 0.0f,   1.0f, 1.0f,
    };
    
    const GLubyte indices[] = {
        0, 1, 2,
        1, 2, 3,
    };
    
    
    [self createBuffer:&_vertexBuffer vertices:vertices size:sizeof(vertices)];
    [self createBuffer:&_indexBuffer indices:indices size:sizeof(indices)];
    
    
    _positionAttr = [self getAttribLocationWithName:@"position"];
    _texCoordAttr = [self getAttribLocationWithName:@"texcoord"];
    _inputImageTex = [self getUniformLocationWithName:@"texSampler"];
    
    [self enableVertexAttrib:&_positionAttr index:0 len:3 stride:5];
    [self enableVertexAttrib:&_texCoordAttr index:3 len:2 stride:5];
    
    [self createTexture:&_texId];
}


#pragma mark - <-- Method -->
- (void)renderData:(NSData *)data size:(CGSize)size {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.glQueue, ^{
        [weakSelf _renderData:data size:size];
    });
}

- (void)_renderData:(NSData *)data size:(CGSize)size {
    [self clearLayer];
    
    [self preEnableTextureWithUniform:&_inputImageTex index:0];
    
    [self enableTexture2DWithTexture:&_texId];
    
    [self fillTexture2DFromRGBAData:data size:size];
    
    [self drawElements];
    
    [self disableTexture2D];
}



#pragma mark - <-- DataSource -->
- (NSString *)vertexShaderBundleName {
    return @"png_vertex.vs";
}

- (NSString *)fragmentShaderBundleName {
    return @"png_fragment.fs";
}

@end
