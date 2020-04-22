//
//  DVGCD+Timer.m
//  DVKit
//
//  Created by mlgPro on 2017/1/10.
//  Copyright © 2017 DVKit. All rights reserved.
//

#import "DVGCD+Timer.h"

@interface DVGCD ()

#pragma mark - <-- Timer -->
@property(nonatomic, strong) dispatch_source_t timer;
@property(nonatomic, assign) NSTimeInterval timerInterval;
@property(nonatomic, copy) void(^timerBlock)(void);
@property(nonatomic, assign) BOOL isTimerWorking;

@end

@implementation DVGCD (Timer)

- (void)timerWithTimeInterval:(NSTimeInterval)timeInterval block:(void (^)(void))block {
    if (timeInterval <= 0 || !block) {
        NSLog(@"[DVGCD ERROR]: 设置定时器失败-> timeInterval:%f", timeInterval);
        return;
    }
    
    if (self.timer) [self cancelTimer];
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, timeInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        block();
    });
    dispatch_resume(timer);
    self.timer = timer;
    self.timerInterval = timeInterval;
    self.timerBlock = block;
    self.isTimerWorking = YES;
}

- (BOOL)resumeTimer {
    if (!self.timer) return NO;
    if (self.isTimerWorking) return NO;
    
    self.isTimerWorking = YES;
    dispatch_resume(self.timer);
    
    return YES;
}

- (BOOL)pauseTimer {
    if (!self.timer) return NO;
    if (!self.isTimerWorking) return NO;
    
    self.isTimerWorking = NO;
    dispatch_suspend(self.timer);
    
    return YES;
}

- (BOOL)fireTimer {
    if (!self.timer) return NO;
    if (!self.timerBlock) return NO;
    
    self.timerBlock();
    [self restartTimer];
    return YES;
}

- (BOOL)restartTimer {
    if (self.timerInterval <= 0 || !self.timerBlock) return NO;
    
    NSTimeInterval tempTimerInterval = self.timerInterval;
    void(^tempTimerBlock)(void) = self.timerBlock;
    
    [self cancelTimer];
    [self timerWithTimeInterval:tempTimerInterval block:tempTimerBlock];
    return YES;
}

- (BOOL)cancelTimer {
    if (!self.timer) return NO;
    
    [self resumeTimer];
    
    dispatch_source_cancel(self.timer);
    self.timer = nil;
    self.timerInterval = 0;
    self.timerBlock = nil;
    self.isTimerWorking = NO;
    return YES;
}

@end

