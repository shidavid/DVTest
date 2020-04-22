//
//  GLKTextureLoader+GL.h
//  DVGLKit
//
//  Created by DV on 2019/1/16.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLKTextureLoader (DVGL)

+ (nullable GLKTextureInfo *)textureWithBundleName:(NSString *)bundleName;

@end

NS_ASSUME_NONNULL_END
