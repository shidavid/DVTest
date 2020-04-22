//
//  DVOPGLRenderLayer.m
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVOPGLRenderLayer.h"

@interface DVOPGLRenderLayer ()

@property(nonatomic, assign) int32_t indexsCount;

@property(nonatomic, assign) NSInteger r;
@property(nonatomic, assign) NSInteger g;
@property(nonatomic, assign) NSInteger b;
@property(nonatomic, assign) NSInteger a;

@end


@implementation DVOPGLRenderLayer

#pragma mark - <-- Initializer -->
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfig];
        [self clearLayer];
    }
    return self;
}

- (void)dealloc {
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    glBufferData(GL_ARRAY_BUFFER, 0, nil, GL_STATIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 0, nil, GL_STATIC_DRAW);
}


#pragma mark - <-- Init -->
- (void)initConfig {
    glViewport(0, 0, (GLsizei)self.glWidth, (GLsizei)self.glHeight);
    
    self.r = 0;
    self.g = 0;
    self.b = 0;
    self.a = 1;
}


#pragma mark - <-- Method -->

//MARK: - <-- 截图 -->
- (UIImage *)openglSnapshotImage {
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGRect rect = self.frame;
    [self drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}


//MARK: - <-- 配置 -->
- (void)setBackgroundColorWithR:(float)r G:(float)g B:(float)b A:(float)a {
    self.r = r;
    self.g = g;
    self.b = b;
    self.a = a;
}


//MARK: - <-- 内存 -->
// 生成缓冲，加载顶点数据
- (void)createBuffer:(GLuint *)buffer vertices:(GLfloat *)vertices size:(int32_t)size {
    [self deleteBuffer:buffer];
    
    GLuint *vertexBuffer = buffer;
    glGenBuffers(1, vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, *vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, size, vertices, GL_STATIC_DRAW);
}

// 生成缓冲，加载顶点顺序
- (void)createBuffer:(GLuint *)buffer indices:(GLubyte *)indices size:(int32_t)size {
    [self deleteBuffer:buffer];
    
    self.indexsCount = size;
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


//MARK: - <-- 顶点 -->
- (GLuint)getAttribLocationWithName:(NSString *)name {
    return glGetAttribLocation(self.program, name.UTF8String);
}

- (GLuint)getUniformLocationWithName:(NSString *)name {
    return glGetUniformLocation(self.program, name.UTF8String);
}

- (void)enableVertexAttrib:(GLuint *)vertexAttrib
                     index:(int32_t)index
                       len:(int32_t)len
                    stride:(size_t)stride {
    glEnableVertexAttribArray(*vertexAttrib);
    glVertexAttribPointer(*vertexAttrib,
                          len,
                          GL_FLOAT,
                          GL_FALSE,
                          (GLsizei)(sizeof(GLfloat) * stride),
                          (GLfloat *)NULL + index);
}

- (void)disableVertexAttrib:(GLuint *)vertexAttrib {
    if (*vertexAttrib) {
        glDisableVertexAttribArray(*vertexAttrib);
//        *vertexAttrib = 0;
    }
}


//MARK: - <-- 纹理 -->
- (void)createTexture:(GLuint *)texture {
    [self deleteTexture:texture];
    
    glGenTextures(1, texture);  // 生成纹理对象
    
    [self enableTexture2DWithTexture:texture]; // 将纹理对象 与 GL_TEXTURE_2D 进行绑定
  
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); // 放大
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); // 缩小
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // S轴
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); // T轴
    
    [self disableTexture2D]; // 暂时解绑纹理对象
}

- (void)deleteTexture:(GLuint *)texture {
    if (*texture) {
        glDeleteTextures(1, texture);
        *texture = 0;
    }
}

- (void)preEnableTextureWithUniform:(GLuint *)uniform index:(int32_t)index {
    
    GLenum texture = 0;
    
    switch (index) {
        case 0: texture = GL_TEXTURE0; break;
        case 1: texture = GL_TEXTURE1; break;
        case 2: texture = GL_TEXTURE2; break;
        case 3: texture = GL_TEXTURE3; break;
        case 4: texture = GL_TEXTURE4; break;
        case 5: texture = GL_TEXTURE5; break;
        default: break;
    }
    
    glActiveTexture(texture);  // 激活纹理句柄 0
    glUniform1i(*uniform, index); // 第二个参数根据上一行修改
}

- (void)enableTexture2DWithTexture:(GLuint *)texture {
    glBindTexture(GL_TEXTURE_2D, *texture); // 将纹理对象 与 GL_TEXTURE_2D 进行绑定
}

- (void)fillTexture2DFromRGBAData:(NSData *)data size:(CGSize)size {
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 (GLsizei)size.width,
                 (GLsizei)size.height, //此处为图片的实际尺寸 2的 幂
                 0,
                 GL_RGBA,
                 GL_UNSIGNED_BYTE,
                 (uint8_t *)data.bytes);
}

- (void)disableTexture2D {
    glBindTexture(GL_TEXTURE_2D, 0); // 解绑纹理对象
}


//MARK: - <-- 绘画 -->
- (void)clearLayer {
    if (!self.context) return;
//    if (self.context != EAGLContext.currentContext) {
//        [EAGLContext setCurrentContext:self.context];
//    }
    
    [EAGLContext setCurrentContext:self.context];
    glClearColor(self.r, self.g, self.b, self.a);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)drawElements {
    if (!self.context) return;
//    if (self.context != EAGLContext.currentContext) {
//        [EAGLContext setCurrentContext:self.context];
//    }

    [EAGLContext setCurrentContext:self.context];
    glDrawElements(GL_TRIANGLES, self.indexsCount, GL_UNSIGNED_BYTE, 0);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
