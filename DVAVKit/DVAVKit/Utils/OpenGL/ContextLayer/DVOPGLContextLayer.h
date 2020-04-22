//
//  DVOPGLContextLayer.h
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


NS_ASSUME_NONNULL_BEGIN

@interface DVOPGLContextLayer : UIView

@property(nonatomic, strong, readonly) EAGLContext *context;
@property(nonatomic, assign, readonly) GLint glWidth;
@property(nonatomic, assign, readonly) GLint glHeight;

- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
