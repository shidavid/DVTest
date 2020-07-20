//
//  DVOPGLRenderLayer.h
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVOPGLProgramLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVOPGLRenderLayer : DVOPGLProgramLayer

#pragma mark - <-- Initializer -->
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;


#pragma mark - <-- Method -->
// 截图
- (UIImage *)openglSnapshotImage;


// 配置
- (void)setBackgroundColorWithR:(float)r G:(float)g B:(float)b A:(float)a;


// 内存数据
- (void)createBuffer:(GLuint *)buffer vertices:(GLfloat *)vertices size:(int32_t)size;
- (void)createBuffer:(GLuint *)buffer indices:(GLubyte *)indices size:(int32_t)size;
- (void)deleteBuffer:(GLuint *)buffer;


// 顶点
- (GLuint)getAttribLocationWithName:(NSString *)name;
- (GLuint)getUniformLocationWithName:(NSString *)name;

- (void)enableVertexAttrib:(GLuint *)vertexAttrib index:(int32_t)index len:(int32_t)len stride:(size_t)stride;
- (void)disableVertexAttrib:(GLuint *)vertexAttrib;


// 纹理
- (void)createTexture:(GLuint *)texture;
- (void)deleteTexture:(GLuint *)texture;

- (void)preEnableTextureWithUniform:(GLuint *)uniform index:(int)index;
- (void)enableTexture2DWithTexture:(GLuint *)texture;
- (void)fillTexture2DFromRGBAData:(NSData *)data size:(CGSize)size;
- (void)disableTexture2D;


// 绘画
- (void)clearLayer;
- (void)drawElements;

@end

NS_ASSUME_NONNULL_END
