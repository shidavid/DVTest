//
//  DVRtmpSocket.h
//  iOS_Test
//
//  Created by DV on 2019/10/17.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVRtmp.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVRtmpSocket : NSObject <DVRtmp>

- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
