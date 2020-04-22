//
//  GCD.h
//  MeiBike
//
//  Created by mlgair on 2016/11/21.
//  Copyright © 2016年 Meitrack. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
/// 线程类型
typedef NS_ENUM(NSUInteger, DVQueueType) {
    DVQueueType_Serial,    //串行
    DVQueueType_Concurrent //并行
};

/// 线程优先级
typedef NS_ENUM(long, DVQueuePriority) {
    DVQueuePriority_Default    = 0,
    DVQueuePriority_High       = 2,
    DVQueuePriority_Low        = (-2),
    DVQueuePriority_Background = INT16_MIN
};

typedef void (^DispatchGroupBlock)(dispatch_group_t group);




#pragma mark - <-------------------- DVGCD 多线程工具 -------------------->
/**
 多线程 工具类
 */
@interface DVGCD : NSObject

#pragma mark - <-- Readonly -->
/// 线程
@property(nonatomic, strong, readonly) dispatch_queue_t queue;
/// 线程名字
@property(nonatomic, copy,   readonly) NSString *name;
/// 线程类型
@property(nonatomic, assign, readonly) DVQueueType type;
/// 线程是否运行中
@property(nonatomic, assign, readonly) BOOL isWorking;
/// 优先级
@property(nonatomic, assign) DVQueuePriority priority;



#pragma mark - <-- Instance -->
/// 创建新线程
- (instancetype)initWithName:(NSString *)name type:(DVQueueType)type;

/// 创建新线程
+ (instancetype)queueWithName:(NSString *)name type:(DVQueueType)type;

/// 主线程
+ (instancetype)mainQueue;

/// 后台线程
+ (instancetype)globalQueue;

/// 后台线程 优先级
+ (instancetype)globalQueue:(DVQueuePriority)priority;



#pragma mark - <-- Method -->
/// 异步执行
- (void)async:(dispatch_block_t)block;

/// 同步执行
- (void)sync:(dispatch_block_t)block;

/// 延迟
- (void)delay:(NSTimeInterval)delay block:(dispatch_block_t)block;

/// 闹钟
- (void)alarmClock:(NSDate *)date block:(dispatch_block_t)block;

/**
 线程群 异步并行处理, 全部 block 执行完才会执行 notify (注意: 线程为串行不可用!!!)
 @param notify 全部 block 执行完才会执行
 @param blocks 并行处理block (可多个,最后必须以nil结尾)
 */
- (void)group:(dispatch_block_t)notify async:(dispatch_block_t)blocks,... NS_REQUIRES_NIL_TERMINATION;

/**
 线程群 异步并行处理, 全部 block 执行完才会执行 notify (注意: 线程为串行不可用!!!)
 @param notify 全部 block 执行完才会执行
 @param blocks 并行处理block (可多个,最后必须以nil结尾),每个闭包执行完 必须手动调用 dispatch_group_leave(group),否则 notify将无法执行
 */
- (void)group:(dispatch_block_t)notify asyncs:(DispatchGroupBlock)blocks,... NS_REQUIRES_NIL_TERMINATION;

/// 读取文件
- (void)io_readFile:(NSString *)path completion:(void(^)(NSData *data))block;

/// 挂起
- (BOOL)suspend;

/// 恢复
- (BOOL)resume;

@end

NS_ASSUME_NONNULL_END
