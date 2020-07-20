//
//  DVOPGLPreview.h
//  DVAVKit
//
//  Created by 施达威 on 2019/4/3.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVOPGLRenderLayer.h"
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVOPGLPreview : DVOPGLRenderLayer

#pragma mark - <-- Property -->
@property(nonatomic, assign) BOOL isFullYUVRange;


#pragma mark - <-- Method -->
- (void)displayWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
