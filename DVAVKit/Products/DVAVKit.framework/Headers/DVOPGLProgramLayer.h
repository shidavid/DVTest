//
//  DVOPGLProgramLayer.h
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVOPGLContextLayer.h"
#import "DVOPGLShaderDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVOPGLProgramLayer : DVOPGLContextLayer <DVOPGLShaderDataSource>

@property(nonatomic, assign, readonly) GLuint program;

- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
