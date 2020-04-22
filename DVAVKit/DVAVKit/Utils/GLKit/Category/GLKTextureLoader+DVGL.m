//
//  GLKTextureLoader+GL.m
//  DVGLKit
//
//  Created by DV on 2019/1/16.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "GLKTextureLoader+DVGL.h"

@implementation GLKTextureLoader (DVGL)

+ (GLKTextureInfo *)textureWithBundleName:(NSString *)bundleName {
    NSString *path = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:bundleName];
    NSDictionary *options = @{
        GLKTextureLoaderOriginBottomLeft : @(1),
    };
    NSError *error;
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path
                                                                      options:options
                                                                        error:&error];
    if (error) {
        NSAssert(error, @"[GLKTextureLoader ERROR]: textureInfo failer to load",error.localizedDescription);
    }
    
    return textureInfo;
}

@end
