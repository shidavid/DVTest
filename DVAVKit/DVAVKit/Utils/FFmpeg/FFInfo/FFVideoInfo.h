//
//  FFVideoInfo.h
//  DVAVKit
//
//  Created by DV on 2019/4/1.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Class -------------------->
@interface FFVideoInfo : NSObject

/// 宽高
@property(nonatomic, assign) CGSize size;
/// 帧率
@property (nonatomic, assign) NSUInteger fps;
/// 码率，单位是 bps
@property (nonatomic, assign) int64_t bitRate;
/// @"h264" / @"hevc"
@property(nonatomic, copy) NSString *codecName;
/// 时间基准
@property(nonatomic, assign) CMTime timeBase;
/// 首帧 pts
@property(nonatomic, assign) int64_t pts;
/// 首帧 dts
@property(nonatomic, assign) int64_t dts;
/// vps
@property(nonatomic, strong, nullable) NSData *vps;
/// sps
@property(nonatomic, strong, nullable) NSData *sps;
/// pps
@property(nonatomic, strong, nullable) NSData *pps;

@end

NS_ASSUME_NONNULL_END
