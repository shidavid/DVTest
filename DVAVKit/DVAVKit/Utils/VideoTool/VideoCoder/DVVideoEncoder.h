//
//  DVVideoEncoder.h
//  iOS_Test
//
//  Created by DV on 2019/10/9.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "DVVideoConfig.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- DVVideoEncoderDelegate -------------------->
@protocol DVVideoEncoder;
@protocol DVVideoEncoderDelegate <NSObject>

- (void)DVVideoEncoder:(id<DVVideoEncoder>)encoder
                   vps:(nullable NSData *)vps
                   sps:(nullable NSData *)sps
                   pps:(nullable NSData *)pps;

- (void)DVVideoEncoder:(id<DVVideoEncoder>)encoder
             codedData:(nullable NSData *)data
            isKeyFrame:(BOOL)isKeyFrame
              userInfo:(nullable void *)userInfo;

@end



#pragma mark - <-------------------- DVVideoEncoder -------------------->
@protocol DVVideoEncoder <NSObject>
@optional

#pragma mark - <-- Property -->
/// 是否实时, 默认:YES
@property(nonatomic, assign) BOOL isRealTime;
/* 压缩等级, 默认:kVTProfileLevel_H264_Main_AutoLevel
    kVTProfileLevel_H264_Baseline_AutoLevel
    kVTProfileLevel_H264_High_AutoLevel
    kVTProfileLevel_H264_Main_AutoLevel
 */
@property(nonatomic, assign) CFStringRef profileLevel;
/// 帧率, 默认:DVVideoConfig -> fps
@property (nonatomic, assign) NSUInteger fps;
/// gop, 默认:DVVideoConfig -> gop
@property (nonatomic, assign) NSUInteger gop;
/// 码率, 默认:DVVideoConfig -> bitRate
@property (nonatomic, assign) NSUInteger bitRate;
/// 是否产生B帧, 默认:DVVideoConfig -> isEnableBFrame
@property(nonatomic, assign) BOOL isEnableBFrame;
/// 熵模式, 默认:kVTH264EntropyMode_CABAC
@property(nonatomic, assign) CFStringRef entropyMode;

@property(nonatomic, weak) id<DVVideoEncoderDelegate> delegate;


#pragma mark - <-- Initializer -->
- (instancetype)initWithConfig:(DVVideoConfig *)config
                      delegate:(id<DVVideoEncoderDelegate>)delegate;


#pragma mark - <-- Method -->
- (void)encodeVideoBuffer:(nullable CMSampleBufferRef)buffer
                 userInfo:(nullable void *)userInfo;

- (void)closeEncoder;

- (nullable NSData *)convertToNALUWithData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame;
- (nullable NSData *)convertToNALUWithSpsOrPps:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
