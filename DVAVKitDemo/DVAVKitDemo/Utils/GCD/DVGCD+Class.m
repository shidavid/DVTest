//
//  DVGCD+Class.m
//  DVKit
//
//  Created by mlgPro on 2017/3/6.
//  Copyright © 2017 DVKit. All rights reserved.
//

#import "DVGCD+Class.h"

@implementation DVGCD (Class)

+ (void)once:(dispatch_block_t)block {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, block);
}

+ (void)main_async_delay:(NSTimeInterval)timeInterval block:(dispatch_block_t)block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   block);
}

+ (void)main_async:(dispatch_block_t)block {
    dispatch_async(dispatch_get_main_queue(), block);
}

+ (void)global_async:(dispatch_block_t)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

+ (void)global_high_async:(dispatch_block_t)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}

+ (void)global_low_async:(dispatch_block_t)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block);
}

+ (void)global_background_async:(dispatch_block_t)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}


@end
