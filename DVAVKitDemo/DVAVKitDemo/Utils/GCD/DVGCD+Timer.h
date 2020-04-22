//
//  DVGCD+Timer.h
//  DVKit
//
//  Created by mlgPro on 2017/1/10.
//  Copyright © 2017 DVKit. All rights reserved.
//

#import "DVGCD.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVGCD (Timer)

/**
 定时器 (suspend 暂停, resume 恢复)
 @param timeInterval 时间间隔
 @param block 每经过一个时间间隔回调一次, return YES 继续, return NO 结束
 */
- (void)timerWithTimeInterval:(NSTimeInterval)timeInterval block:(void(^)(void))block;

/// 恢复定时器
- (BOOL)resumeTimer;

/// 暂停定时器
- (BOOL)pauseTimer;

/// 立即触发定时器闭包
- (BOOL)fireTimer;

/// 重新开始定时器
- (BOOL)restartTimer;

/// 立即取消定时器, 想开始再次调用 timerWithTimeInterval:block:
- (BOOL)cancelTimer;

@end

NS_ASSUME_NONNULL_END
