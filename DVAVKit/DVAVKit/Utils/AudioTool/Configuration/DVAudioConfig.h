//
//  DVAudioConfig.h
//  iOS_Test
//
//  Created by DV on 2019/1/10.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVAudioConfig : NSObject

/// 采样率
@property(nonatomic, assign) NSUInteger sampleRate;

/// 位数
@property(nonatomic, assign) UInt32 bitsPerChannel;

/// 通道
@property(nonatomic, assign) UInt32 numberOfChannels;

/// 码率 Kbps : ( 位数 / 8 * 通道数 ) * 采样率 = 每秒多少字节
@property(nonatomic, assign, readonly) NSUInteger bitRate;



#pragma mark - <-- Instance -->
- (instancetype)initWithSampleRate:(NSUInteger)sampleRate
                    bitsPerChannel:(UInt32)bits
                  numberOfChannels:(UInt32)channels;

+ (instancetype)configWithSampleRate:(NSUInteger)sampleRate
                      bitsPerChannel:(UInt32)bits
                    numberOfChannels:(UInt32)channels;



#pragma mark - <-- PCM Default -->
+ (DVAudioConfig *)kConfig_8k_16bit_1ch;
+ (DVAudioConfig *)kConfig_8k_16bit_2ch;

+ (DVAudioConfig *)kConfig_16k_16bit_1ch;
+ (DVAudioConfig *)kConfig_16k_16bit_2ch;

+ (DVAudioConfig *)kConfig_44k_16bit_1ch;
+ (DVAudioConfig *)kConfig_44k_16bit_2ch;

+ (DVAudioConfig *)kConfig_48k_16bit_1ch;
+ (DVAudioConfig *)kConfig_48k_16bit_2ch;

@end

NS_ASSUME_NONNULL_END
