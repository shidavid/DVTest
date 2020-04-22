//
//  DVRtmpPacket.h
//  iOS_Test
//
//  Created by DV on 2019/10/24.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVFlvKit.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Protocol -------------------->
@interface DVRtmpPacket : NSObject

@property(nonatomic, assign) uint32_t timeStamp;
@property(nonatomic, strong, nullable) DVVideoFlvTagData *videoData;
@property(nonatomic, strong, nullable) DVAudioFlvTagData *audioData;

@end

NS_ASSUME_NONNULL_END
