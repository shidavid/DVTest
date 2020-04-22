//
//  DVAudioAACHardwareDecoder.h
//  DVAVKit
//
//  Created by 施达威 on 2019/4/7.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVAudioDecoder.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVAudioAACHardwareDecoder : NSObject <DVAudioDecoder>

#pragma mark - <-- Property -->
/// 解码数据包大小, 默认:1024
@property(nonatomic, assign) UInt32 outputDataPacketSize;


#pragma mark - <-- Initializer -->
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
