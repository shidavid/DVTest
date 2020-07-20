//
//  DVGLShaderDataSource.h
//  DVLibrary
//
//  Created by DV on 2019/1/14.
//  Copyright © 2019 DVLibrary. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVOPGLShaderDataSource <NSObject>
@optional
- (NSString *)vertexShaderBundleName;
- (NSString *)fragmentShaderBundleName;

- (NSString *)vertexShaderString;
- (NSString *)fragmentShaderString;

@end

NS_ASSUME_NONNULL_END
