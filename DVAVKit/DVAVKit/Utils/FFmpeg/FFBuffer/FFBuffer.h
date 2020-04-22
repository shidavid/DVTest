//
//  FFBuffer.h
//  DVAVKit
//
//  Created by DV on 2019/3/31.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFPacket.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(UInt8, FFBufferStatus) {
    FFBufferStatus_Steady = 0,   // 缓冲稳定
    FFBufferStatus_Increase = 1, // 缓冲增加中
    FFBufferStatus_Decrease = 2, // 缓冲减少中
};


#pragma mark - <-------------------- Protocol -------------------->
@class FFBuffer;
@protocol FFBufferDelegate <NSObject>

- (void)FFBuffer:(FFBuffer *)rtmpBuffer bufferStatus:(FFBufferStatus)bufferStatus;

- (void)FFBuffer:(FFBuffer *)rtmpBuffer bufferOverMaxCount:(NSArray<FFPacket *> *)bufferList
    deleteBuffer:(void(^)(NSArray<FFPacket *> *))deleteBlock;

@end


#pragma mark - <-------------------- Class -------------------->
@interface FFBuffer : NSObject

#pragma mark - <-- Property -->
/// 监听缓冲变化状态
@property(nonatomic, weak, nullable) id<FFBufferDelegate> delegate;
/// 最大缓冲数量, 默认: 25 FPS x 60s = 1500
@property(nonatomic, assign) NSUInteger bufferMaxCount;

/// 缓冲区
@property(nonatomic, strong, readonly) NSArray<FFPacket *> *bufferList;
/// 缓冲数量
@property(nonatomic, assign, readonly) NSUInteger bufferCount;


#pragma mark - <-- Method -->
- (void)pushBuffer:(FFPacket *)buffer;
- (nullable FFPacket *)popBuffer;
- (void)removeAllBuffer;

@end

NS_ASSUME_NONNULL_END
