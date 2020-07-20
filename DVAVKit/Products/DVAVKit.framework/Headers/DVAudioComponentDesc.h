//
//  DVAudioComponentDesc.h
//  iOS_Test
//
//  Created by DV on 2019/1/11.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVAudioComponentDesc : NSObject

#pragma mark - <-- Instancetype -->
+ (AudioComponentDescription)kComponentDescWithType:(OSType)type subType:(OSType)subType;

#pragma mark - <-- Default -->
+ (AudioComponentDescription)kComponentDesc_Output_IO;
+ (AudioComponentDescription)kComponentDesc_Output_VPIO;

@end

NS_ASSUME_NONNULL_END
