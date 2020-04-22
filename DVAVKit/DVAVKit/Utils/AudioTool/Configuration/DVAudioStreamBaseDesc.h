//
//  DVAudioStreamBaseDesc.h
//  iOS_Test
//
//  Created by DV on 2019/1/11.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DVAudioConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVAudioStreamBaseDesc : NSObject

#pragma mark - <-- Instance -->
+ (AudioStreamBasicDescription)pcmBasicDescWithConfig:(DVAudioConfig *)config;

+ (AudioStreamBasicDescription)aacBasicDescWithConfig:(DVAudioConfig *)config;

@end

NS_ASSUME_NONNULL_END
