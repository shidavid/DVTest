//
//  DVGLRenderLayer.m
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVGLRenderLayer.h"

@interface DVGLRenderLayer ()

@property(nonatomic, strong, readwrite) GLKBaseEffect *baseEffect;

@property(nonatomic, assign) GLuint vertexBuffer;
@property(nonatomic, assign) GLuint indexBuffer;

@property(nonatomic, assign) int32_t indexsCount;

@property(nonatomic, assign) NSInteger r;
@property(nonatomic, assign) NSInteger g;
@property(nonatomic, assign) NSInteger b;
@property(nonatomic, assign) NSInteger a;

@end


@implementation DVGLRenderLayer

#pragma mark - <-- Initializer -->
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfigs];
        [self clearLayer];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    [self deleteBuffer:&_vertexBuffer];
    [self deleteBuffer:&_indexBuffer];
}


#pragma mark - <-- Init -->
- (void)initConfigs {
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    self.r = 0;
    self.g = 0;
    self.b = 0;
    self.a = 1;
}


#pragma mark - <-- Method -->
- (void)setBackgroundColorWithR:(float)r G:(float)g B:(float)b A:(float)a {
    self.r = r;
    self.g = g;
    self.b = b;
    self.a = a;
    
    [self clearLayer];
}

// 绑定顶点数据
- (void)bindVertexBufferWithVertices:(GLfloat *)vertices size:(int32_t)size {
    [self bindBuffer:&_vertexBuffer vertices:vertices size:size];
}

// 绑定顶点顺序
- (void)bindIndexBufferWithIndices:(GLubyte *)indices size:(int32_t)size {
    self.indexsCount = size;
    [self bindBuffer:&_indexBuffer indices:indices size:size];
}

// 生成缓冲，加载顶点数据
- (void)bindBuffer:(GLuint *)buffer vertices:(GLfloat *)vertices size:(int32_t)size {
    [self deleteBuffer:buffer];
    
    GLuint *vertexBuffer = buffer;
    glGenBuffers(1, vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, *vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, size, vertices, GL_STATIC_DRAW);
}

// 生成缓冲，加载顶点顺序
- (void)bindBuffer:(GLuint *)buffer indices:(GLubyte *)indices size:(int32_t)size {
    [self deleteBuffer:buffer];
    
    GLuint *indexBuffer = buffer;
    glGenBuffers(1, indexBuffer); //生成buffer
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, *indexBuffer); //buffer绑定GL_ELEMENT_ARRAY_BUFFER
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, indices, GL_STATIC_DRAW); //填充数据到buffer
}

- (void)deleteBuffer:(GLuint *)buffer {
    if (*buffer) {
        glDeleteBuffers(1, buffer);
        *buffer = 0;
    }
}

// 启动顶点
- (void)enableVertexAttribPositionWithIndex:(int32_t)index len:(int32_t)len stride:(size_t)stride {
    [self enableVertexAttrib:GLKVertexAttribPosition index:index len:len stride:stride];
}

// 启动颜色
- (void)enableVertexAttribColorWithIndex:(int32_t)index len:(int32_t)len stride:(size_t)stride {
    [self enableVertexAttrib:GLKVertexAttribColor index:index len:len stride:stride];
}

// 启动纹理0
- (void)enableVertexAttribTexCoord0WithIndex:(int32_t)index len:(int32_t)len stride:(size_t)stride {
    [self enableVertexAttrib:GLKVertexAttribTexCoord0 index:index len:len stride:stride];
}

// 启动纹理1
- (void)enableVertexAttribTexCoord1WithIndex:(int32_t)index len:(int32_t)len stride:(size_t)stride {
    [self enableVertexAttrib:GLKVertexAttribTexCoord1 index:index len:len stride:stride];
}

- (void)enableVertexAttrib:(GLKVertexAttrib)vertexAttrib
                     index:(int32_t)index
                       len:(int32_t)len
                    stride:(size_t)stride {
    glEnableVertexAttribArray(vertexAttrib);
    glVertexAttribPointer(vertexAttrib,
                          len,
                          GL_FLOAT,
                          GL_FALSE,
                          (GLsizei)(sizeof(GLfloat) * stride),
                          (GLfloat *)NULL + index);
}

- (void)clearLayer {
    glClearColor(self.r, self.g, self.b, self.a);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)drawElements {
    [EAGLContext setCurrentContext:self.context];
    [self clearLayer];
    
    [self.baseEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.indexsCount, GL_UNSIGNED_BYTE, 0);
}


#pragma mark - <-- Delegate -->
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self drawElements];
}

@end
