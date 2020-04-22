//
//  DVGCD+CountDown.m
//  DVKit
//
//  Created by mlgPro on 2017/1/10.
//  Copyright © 2017 DVKit. All rights reserved.
//

#import "DVGCD+CountDown.h"

@interface DVGCD ()

@property(nonatomic, strong) __block dispatch_source_t countDownSource;

@end

@implementation DVGCD (CountDown)

- (void)countDownWithDuration:(NSTimeInterval)duration
                 timeInterval:(NSTimeInterval)timeInterval
                        block:(void (^)(NSTimeInterval))block
                          end:(void (^)(void))endBlock {
    
    if (duration <= 0 || timeInterval <= 0 || duration < timeInterval) {
        NSLog(@"[DVGCD ERROR]: 设置倒计时器失败-> duration:%f timeInterval:%f", duration, timeInterval);
        return;
    }
    
    if (self.countDownSource) {
        [self cancelCountDown];
    }
    
    __block NSTimeInterval tmpDuration = duration;
    NSTimeInterval tmpTimeInterval = timeInterval;
    
    __weak __typeof(self)weakSelf = self;
    self.countDownSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
    dispatch_source_set_timer(self.countDownSource, DISPATCH_TIME_NOW, tmpTimeInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.countDownSource , ^{
        tmpDuration -= tmpTimeInterval;
        if (tmpDuration < tmpTimeInterval) {
            dispatch_source_cancel(weakSelf.countDownSource);
            endBlock();
            weakSelf.countDownSource  = nil;
        }
    });
    dispatch_resume(self.countDownSource );
}

- (void)cancelCountDown {
    if (self.countDownSource) {
        dispatch_source_cancel(self.countDownSource);
        self.countDownSource = nil;
    }
}

@end
