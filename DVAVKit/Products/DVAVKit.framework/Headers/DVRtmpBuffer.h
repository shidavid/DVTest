//
//  DVRtmpBuffer.h
//  iOS_Test
//
//  Created by DV on 2019/10/22.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVRtmpPacket.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(UInt8, DVRtmpBufferStatus) {
    DVRtmpBufferStatus_Steady = 0,   // 缓冲稳定
    DVRtmpBufferStatus_Increase = 1, // 缓冲增加中
    DVRtmpBufferStatus_Decrease = 2, // 缓冲减少中
};



#pragma mark - <-------------------- Delegate -------------------->
@class DVRtmpBuffer;
@protocol DVRtmpBufferDelegate <NSObject>

- (void)DVRtmpBuffer:(DVRtmpBuffer *)rtmpBuffer bufferStatus:(DVRtmpBufferStatus)bufferStatus;

- (void)DVRtmpBuffer:(DVRtmpBuffer *)rtmpBuffer
  bufferOverMaxCount:(NSArray<DVRtmpPacket *> *)bufferList
        deleteBuffer:(void(^)(NSArray<DVRtmpPacket *> *))deleteBlock;

@end



#pragma mark - <-------------------- Class -------------------->
@interface DVRtmpBuffer : NSObject

#pragma mark - <-- Property -->
/// 监听缓冲变化状态
@property(nonatomic, weak, nullable) id<DVRtmpBufferDelegate> delegate;
/// 最大缓冲数量, 默认: 25 FPS x 60s = 1500
@property(nonatomic, assign) NSUInteger bufferMaxCount;

/// 缓冲区
@property(nonatomic, strong, readonly) NSArray<DVRtmpPacket *> *bufferList;
/// 缓冲数量
@property(nonatomic, assign, readonly) NSUInteger bufferCount;


#pragma mark - <-- Method -->
- (void)pushBuffer:(DVRtmpPacket *)buffer;
- (nullable DVRtmpPacket *)popBuffer;
- (void)removeAllBuffer;

@end

NS_ASSUME_NONNULL_END
