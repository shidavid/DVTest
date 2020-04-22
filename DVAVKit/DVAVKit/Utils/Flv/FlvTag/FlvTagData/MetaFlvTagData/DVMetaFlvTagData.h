//
//  DVMetaFlvTagData.h
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVFlvTagData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVMetaFlvTagData : NSObject <DVFlvTagData>

#pragma mark - <-- Base -->
/// 时长, 默认: 0
@property(nonatomic, assign) float duration;
/// 文件大小, 默认: 0
@property(nonatomic, assign) float fileSize;


#pragma mark - <-- Video -->
/// 宽度
@property(nonatomic, assign) CGFloat videoWidth;
/// 高度
@property(nonatomic, assign) CGFloat videoHeight;
/// 帧率
@property(nonatomic, assign) NSUInteger videoFps;
/// 码率，单位是 bps
@property(nonatomic, assign) NSUInteger videoBitRate;
/// 视频编码器ID,默认: avc1
@property(nonatomic, copy) NSString *videoCodecID;


#pragma mark - <-- Audio -->
/// 采样率
@property(nonatomic, assign) NSUInteger audioSampleRate;
/// 位数
@property(nonatomic, assign) UInt32 audioBits;
/// 通道
@property(nonatomic, assign) UInt32 audioChannels;
/// 音频编码器ID,默认: mp4a
@property(nonatomic, copy) NSString *audioCodecID;

@end

NS_ASSUME_NONNULL_END
