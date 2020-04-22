//
//  DVGLPreview.h
//  DVAVKit
//
//  Created by DV on 2019/4/2.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVGLRenderLayer.h"
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVGLPreview : DVGLRenderLayer

- (void)displayWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
