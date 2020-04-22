//
//  DVGCD+Class.h
//  DVKit
//
//  Created by mlgPro on 2017/3/6.
//  Copyright © 2017 DVKit. All rights reserved.
//

#import "DVGCD.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVGCD (Class)

///单次
+ (void)once:(dispatch_block_t)block;


+ (void)main_async_delay:(NSTimeInterval)timeInterval block:(dispatch_block_t)block;

///异步 主线程 串行
+ (void)main_async:(dispatch_block_t)block;

///异步 后台 并行 (优先级 DEFAULT)
+ (void)global_async:(dispatch_block_t)block;

///异步 后台 并行 (优先级 HIGH)
+ (void)global_high_async:(dispatch_block_t)block;

///异步 后台 并行 (优先级 LOW)
+ (void)global_low_async:(dispatch_block_t)block;

///异步 后台 并行 (优先级 BACKGROUND)
+ (void)global_background_async:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
