//
//  DVGCD+CountDown.h
//  DVKit
//
//  Created by mlgPro on 2017/1/10.
//  Copyright © 2017 DVKit. All rights reserved.
//

#import "DVGCD.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVGCD (CountDown)

/**
 倒计时器
 @param duration 倒计时总时长
 @param timeInterval 时间间隔
 @param block 每经过一个时间间隔回调一次, return YES 继续, return NO 结束
 @param endBlock 倒计时结束回调
 */
- (void)countDownWithDuration:(NSTimeInterval)duration
                 timeInterval:(NSTimeInterval)timeInterval
                        block:(void(^)(NSTimeInterval timeLeft))block
                          end:(void(^)(void))endBlock;

- (void)cancelCountDown;

@end

NS_ASSUME_NONNULL_END
