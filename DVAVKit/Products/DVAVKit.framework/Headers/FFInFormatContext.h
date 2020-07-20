//
//  FFInFormatContext.h
//  DVAVKit
//
//  Created by 施达威 on 2019/3/30.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFPacket.h"
#import "FFVideoInfo.h"
#import "FFAudioInfo.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Protocol -------------------->
@class FFInFormatContext;
@protocol FFInFormatContextDelegate <NSObject>
@optional

// 读取音视频信息
- (void)FFInFormatContext:(FFInFormatContext *)context videoInfo:(FFVideoInfo *)videoInfo;
- (void)FFInFormatContext:(FFInFormatContext *)context audioInfo:(FFAudioInfo *)audioInfo;

// 读取音视频数据
- (void)FFInFormatContext:(FFInFormatContext *)context readVideoPacket:(FFPacket *)packet;
- (void)FFInFormatContext:(FFInFormatContext *)context readAudioPacket:(FFPacket *)packet;

// IO
- (void)FFInFormatContext:(FFInFormatContext *)context inIOPacket:(FFPacket **)packet;

@end


#pragma mark - <-------------------- Class -------------------->
@interface FFInFormatContext : NSObject

#pragma mark - <-- Property -->
@property(nonatomic, weak) id<FFInFormatContextDelegate> delegate;
@property(nonatomic, assign, readonly) BOOL isReading;
@property(nonatomic, assign, readonly) BOOL isOpening;

@property(nonatomic, strong, readonly, nullable) FFVideoInfo *videoInfo;
@property(nonatomic, strong, readonly, nullable) FFAudioInfo *audioInfo;


#pragma mark - <-- Initializer -->
+ (instancetype)context;


#pragma mark - <-- Method -->
- (void)openWithURL:(NSString *)url;
- (void)closeURL;

- (void)startReadPacket;
- (void)stopReadPacket;

@end

NS_ASSUME_NONNULL_END
