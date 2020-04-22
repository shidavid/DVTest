//
//  DVAudioQueue.h
//  iOS_Test
//
//  Created by DV on 2019/1/10.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVAudioStreamBaseDesc.h"
#import "DVAudioPacket.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(NSUInteger, DVAudioQueueStatus) {
    DVAudioQueueStatusStart,
    DVAudioQueueStatusStop,
    DVAudioQueueStatusPause,
};

#pragma mark - <-------------------- Protocol -------------------->
@class DVAudioQueue;
@protocol DVAudioQueueDelegate <NSObject>

- (void)DVAudioQueue:(DVAudioQueue *)audioQueue
          recordData:(uint8_t *)data
                size:(UInt32)size;

- (void)DVAudioQueue:(DVAudioQueue *)audioQueue
        playbackData:(uint8_t *)data
                size:(UInt32)size
            userInfo:(nullable void *)userInfo;

@end


#pragma mark - <-------------------- Class -------------------->
@interface DVAudioQueue : NSObject

#pragma mark - <-- Property -->
@property(nonatomic, weak) id<DVAudioQueueDelegate> delegate;

@property(nonatomic, assign, readonly) DVAudioQueueStatus status;
@property(nonatomic, assign, readonly) BOOL isInput;

@property(nonatomic, strong) NSMutableArray<DVAudioPacket *> *packetBuffer;


#pragma mark - <-- Initializer -->
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initInputQueueWithBasic:(AudioStreamBasicDescription)basicDesc
                     sampleTimeInterval:(Float64)sampleTimeInterval;

- (instancetype)initOutputQueueWithBasic:(AudioStreamBasicDescription)basicDesc
                              bufferSize:(UInt32)bufferSize;


#pragma mark - <-- Method -->
- (BOOL)start;
- (BOOL)stop;
- (BOOL)pause;

- (void)playAudioData:(uint8_t *)data size:(UInt32)size userInfo:(nullable void *)userInfo;


@end

NS_ASSUME_NONNULL_END
