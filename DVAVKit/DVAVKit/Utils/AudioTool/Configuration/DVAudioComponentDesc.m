//
//  DVAudioComponentDesc.m
//  iOS_Test
//
//  Created by DV on 2019/1/11.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import "DVAudioComponentDesc.h"

@implementation DVAudioComponentDesc

#pragma mark - <-- Instancetype -->
+ (AudioComponentDescription)kComponentDescWithType:(OSType)type subType:(OSType)subType {
    AudioComponentDescription componentDesc = {
        .componentType = type,
        .componentSubType = subType,
        .componentManufacturer = kAudioUnitManufacturer_Apple,
        .componentFlagsMask = 0,
        .componentFlags = 0,
    };
    return componentDesc;
}

#pragma mark - <-- Default -->
+ (AudioComponentDescription)kComponentDesc_Output_IO {
    return [self kComponentDescWithType:kAudioUnitType_Output
                                subType:kAudioUnitSubType_RemoteIO];
}

+ (AudioComponentDescription)kComponentDesc_Output_VPIO {
    return [self kComponentDescWithType:kAudioUnitType_Output
                                subType:kAudioUnitSubType_VoiceProcessingIO];
}

@end
