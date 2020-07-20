//
//  DVGLContextLayer.h
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVGLContextLayer : GLKView 

#pragma mark - <-- Initializer -->
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
