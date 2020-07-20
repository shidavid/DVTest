//
//  DVGLRenderLayer.h
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVGLContextLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVGLRenderLayer : DVGLContextLayer <GLKViewDelegate>

#pragma mark - <-- Property -->
@property(nonatomic, strong, readonly) GLKBaseEffect *baseEffect;


#pragma mark - <-- Initializer -->
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;


#pragma mark - <-- Method -->
- (void)setBackgroundColorWithR:(float)r G:(float)g B:(float)b A:(float)a;

- (void)bindVertexBufferWithVertices:(GLfloat *)vertices size:(int32_t)size;
- (void)bindIndexBufferWithIndices:(GLubyte *)indices size:(int32_t)size;

- (void)enableVertexAttribPositionWithIndex:(int32_t)index
                                        len:(int32_t)len
                                     stride:(size_t)stride;
- (void)enableVertexAttribColorWithIndex:(int32_t)index
                                     len:(int32_t)len
                                  stride:(size_t)stride;
- (void)enableVertexAttribTexCoord0WithIndex:(int32_t)index
                                         len:(int32_t)len
                                      stride:(size_t)stride;
- (void)enableVertexAttribTexCoord1WithIndex:(int32_t)index
                                         len:(int32_t)len
                                      stride:(size_t)stride;

- (void)clearLayer;
- (void)drawElements;

@end

NS_ASSUME_NONNULL_END
