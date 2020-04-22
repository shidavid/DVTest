//
//  CALayer+DVNotice.m
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/4/14.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import "CALayer+DVNotice.h"

@implementation CALayer (DVNotice)

- (void)dv_beginAnimation {
    if (self.speed == 0.0) {
        CFTimeInterval pausedTime = [self timeOffset];
        self.speed = 1.0;
        self.timeOffset = 0.0;
        self.beginTime = 0.0;
        CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.beginTime = timeSincePause;
    }
}

@end
