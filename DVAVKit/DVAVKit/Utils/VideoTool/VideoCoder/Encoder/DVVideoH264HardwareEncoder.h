//
//  DVVideoH264HardwareEncoder.h
//  iOS_Test
//
//  Created by DV on 2019/10/11.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVVideoEncoder.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVVideoH264HardwareEncoder : NSObject <DVVideoEncoder>

#pragma mark - <-- Initializer -->
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
