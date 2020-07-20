//
//  DVOPGLPNGLayer.h
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVOPGLRenderLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVOPGLPNGLayer : DVOPGLRenderLayer

- (void)renderData:(NSData *)data size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
