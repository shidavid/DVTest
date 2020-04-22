//
//  FFAudioInfo.h
//  DVAVKit
//
//  Created by DV on 2019/4/1.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFAudioInfo : NSObject

/// 采样率
@property(nonatomic, assign) NSUInteger sampleRate;
/// 位数
@property(nonatomic, assign) UInt32 bitsPerChannel;
/// 通道
@property(nonatomic, assign) UInt32 numberOfChannels;
/// @"aac"
@property(nonatomic, copy) NSString *codecName;
/// 
@property(nonatomic, strong) NSData *extraData;
/// 时间基准
@property(nonatomic, assign) CMTime timeBase;
/// 首帧 pts
@property(nonatomic, assign) int64_t pts;
/// 首帧 dts
@property(nonatomic, assign) int64_t dts;

@end

NS_ASSUME_NONNULL_END
