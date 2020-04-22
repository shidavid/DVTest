//
//  GCD.m
//  MeiBike
//
//  Created by mlgair on 2016/11/21.
//  Copyright © 2016年 Meitrack. All rights reserved.
//

#import "DVGCD.h"

@interface DVGCD ()

@property(nonatomic, strong, readwrite) dispatch_queue_t queue;
@property(nonatomic, copy,   readwrite) NSString *name;
@property(nonatomic, assign, readwrite) DVQueueType type;
@property(nonatomic, assign, readwrite) BOOL isWorking;

#pragma mark - <-- CountDown -->
@property(nonatomic, strong) __block dispatch_source_t countDownSource;

#pragma mark - <-- Timer -->
@property(nonatomic, strong) dispatch_source_t timer;
@property(nonatomic, assign) NSTimeInterval timerInterval;
@property(nonatomic, copy) void(^timerBlock)(void);
@property(nonatomic, assign) BOOL isTimerWorking;

@end


@implementation DVGCD

#pragma mark - <-- Setter & Getter -->
- (void)setPriority:(DVQueuePriority)priority {
    if (_priority != priority) {
        dispatch_set_target_queue(self.queue, dispatch_get_global_queue(priority, 0));
        _priority = priority;
    }
}


#pragma mark - <-- Instance -->
- (instancetype)initWithName:(NSString *)name type:(DVQueueType)type {
    self = [super init];
    if (self) {
        dispatch_queue_attr_t attr = (type == DVQueueType_Serial ? DISPATCH_QUEUE_SERIAL : DISPATCH_QUEUE_CONCURRENT);
        _queue = dispatch_queue_create(name.UTF8String, attr);
        _name = name;
        _type = type;
        _isWorking = YES;
        _priority = DVQueuePriority_Default;
    }
    return self;
}

+ (instancetype)queueWithName:(NSString *)name type:(DVQueueType)type {
    return [[DVGCD alloc] initWithName:name type:type];
}

+ (instancetype)mainQueue {
    DVGCD *gcd = [[DVGCD alloc] init];
    gcd.queue = dispatch_get_main_queue();
    gcd.name = @"com.mygcd.main";
    gcd.type = DVQueueType_Serial;
    gcd.isWorking = YES;
    return gcd;
}

+ (instancetype)globalQueue {
    return [self globalQueue:DVQueuePriority_Default];
}

+ (instancetype)globalQueue:(DVQueuePriority)priority {
    DVGCD *gcd = [[DVGCD alloc] init];
    gcd.queue = dispatch_get_global_queue(priority, 0);
    gcd.name = @"com.mygcd.global";
    gcd.type = DVQueueType_Concurrent;
    gcd.isWorking = YES;
    gcd.priority = priority;
    return gcd;
}

- (void)dealloc {
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    if (_isWorking == NO) {
        dispatch_resume(_queue);
        _queue = nil;
    }
}



#pragma mark - <-- Method -->
- (void)async:(dispatch_block_t)block {
    dispatch_async(self.queue, block);
}

- (void)sync:(dispatch_block_t)block {
    dispatch_sync(self.queue, block);
}

- (void)delay:(NSTimeInterval)delay block:(dispatch_block_t)block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), self.queue, block);
}

- (void)alarmClock:(NSDate *)date block:(dispatch_block_t)block {
    dispatch_after([self getDispatchTimeByDate:date], self.queue, block);
}

//根据date 获取绝对时间
- (dispatch_time_t)getDispatchTimeByDate:(NSDate *)date {
    NSTimeInterval interval;
    double second, subsecond;
    struct timespec time;
    dispatch_time_t milestone;
    
    interval = [date timeIntervalSince1970];
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&time, 0);
    
    return milestone;
}

- (void)group:(dispatch_block_t)notify async:(dispatch_block_t)blocks, ... {
    if (self.type == DVQueueType_Serial) {
        NSLog(@"[DVGCD ERROR]: 线程->%@ 为串行, 无法调用 [group:async:]", self.name);
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    if (blocks) {
        dispatch_group_async(group, self.queue, blocks);
    
        va_list list;
        dispatch_block_t tmpBlock;
        
        va_start(list, blocks);
        while ((tmpBlock = va_arg(list, dispatch_block_t))) {
            dispatch_group_async(group, self.queue, blocks);
        }
        va_end(list);
    }
    
    dispatch_group_notify(group, self.queue, notify);
}

- (void)group:(dispatch_block_t)notify asyncs:(DispatchGroupBlock)blocks, ... {
    if (self.type == DVQueueType_Serial) {
        NSLog(@"[DVGCD ERROR]: 线程->%@ 为串行, 无法调用 [group:async:]", self.name);
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    if (blocks) {
        __weak __typeof(group)weakGroup = group;
        dispatch_group_enter(weakGroup);
        dispatch_async(self.queue, ^{
            blocks(weakGroup);
        });
        
        va_list list;
        DispatchGroupBlock tmpBlock;
        
        va_start(list, blocks);
        while ((tmpBlock = va_arg(list, DispatchGroupBlock))) {
            dispatch_group_enter(weakGroup);
            dispatch_async(self.queue, ^{
                tmpBlock(weakGroup);
            });
        }
        va_end(list);
    }
    
    dispatch_group_notify(group, self.queue, notify);
}

- (void)io_readFile:(NSString *)path completion:(void(^)(NSData *data))block {
    if (self.type == DVQueueType_Serial) {
        [self io_readFileBySerial:path completion:block];
    } else if (self.type == DVQueueType_Concurrent) {
        [self io_readFileByConcurrent:path completion:block];
    }
}

/*
 O_RDONLY 以只读方式打开文件
 O_WRONLY 以只写方式打开文件
 O_RDWR 以可读写方式打开文件. 上述三种旗标是互斥的, 也就是不可同时使用, 但可与下列的旗标利用OR(|)运算符组合.
 O_CREAT 若欲打开的文件不存在则自动建立该文件.
 O_EXCL 如果O_CREAT 也被设置, 此指令会去检查文件是否存在. 文件若不存在则建立该文件, 否则将导致打开文件错误. 此外, 若O_CREAT 与O_EXCL 同时设置, 并且欲打开的文件为符号连接, 则会打开文件失败.
 O_NOCTTY 如果欲打开的文件为终端机设备时, 则不会将该终端机当成进程控制终端机.
 O_TRUNC 若文件存在并且以可写的方式打开时, 此旗标会令文件长度清为0, 而原来存于该文件的资料也会消失.
 O_APPEND 当读写文件时会从文件尾开始移动, 也就是所写入的数据会以附加的方式加入到文件后面.
 O_NONBLOCK 以不可阻断的方式打开文件, 也就是无论有无数据读取或等待, 都会立即返回进程之中.
 O_NDELAY 同O_NONBLOCK.
 O_SYNC 以同步的方式打开文件.
 O_NOFOLLOW 如果参数pathname 所指的文件为一符号连接, 则会令打开文件失败.
 O_DIRECTORY 如果参数pathname 所指的文件并非为一目录, 则会令打开文件失败。注：此为Linux2. 2 以后特有的旗标, 以避免一些系统安全问题.
 */
/*
 S_IRWXU 00700 权限, 代表该文件所有者具有可读、可写及可执行的权限.
 S_IRUSR 或S_IREAD, 00400 权限, 代表该文件所有者具有可读取的权限.
 S_IWUSR 或S_IWRITE, 00200 权限, 代表该文件所有者具有可写入的权限.
 S_IXUSR 或S_IEXEC, 00100 权限, 代表该文件所有者具有可执行的权限.
 S_IRWXG 00070 权限, 代表该文件用户组具有可读、可写及可执行的权限.
 S_IRGRP 00040 权限, 代表该文件用户组具有可读的权限.
 S_IWGRP 00020 权限, 代表该文件用户组具有可写入的权限.
 S_IXGRP 00010 权限, 代表该文件用户组具有可执行的权限.
 S_IRWXO 00007 权限, 代表其他用户具有可读、可写及可执行的权限.
 S_IROTH 00004 权限, 代表其他用户具有可读的权限
 S_IWOTH 00002 权限, 代表其他用户具有可写入的权限.
 S_IXOTH 00001 权限, 代表其他用户具有可执行的权限.
 */
- (void)io_readFileBySerial:(NSString *)path completion:(void(^)(NSData *data))block {
    
    dispatch_fd_t fd = open((char *)[path UTF8String], O_RDWR | O_CREAT, S_IRWXU | S_IRWXG | S_IRWXO);
    
    dispatch_io_t io = dispatch_io_create(DISPATCH_IO_STREAM, fd, self.queue, ^(int error) {
        close(fd);
    });
    
    size_t water = 1024 * 1024;
    dispatch_io_set_low_water(io, water);
    dispatch_io_set_high_water(io, water);
    
    unsigned long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
    
    NSMutableData *mutableData = [NSMutableData data];
    
    dispatch_io_read(io, 0, (size_t)fileSize, self.queue, ^(bool done, dispatch_data_t  _Nullable data, int error) {
        
        if (error == 0) {
            size_t len = dispatch_data_get_size(data);
            if (len > 0) {
                [mutableData appendData:(NSData *)data];
            }
        }
        
        if (done) {
            block([mutableData copy]);
        }
    });
}

- (void)io_readFileByConcurrent:(NSString *)path completion:(void(^)(NSData *data))block {
    
    dispatch_fd_t fd = open([path UTF8String], O_RDWR | O_CREAT, S_IRWXU | S_IRWXG | S_IRWXO);
    
    dispatch_io_t io = dispatch_io_create(DISPATCH_IO_STREAM, fd, self.queue, ^(int error) {
        close(fd);
    });
    
    size_t water = 1024 * 1024;
    dispatch_io_set_low_water(io, water);
    dispatch_io_set_high_water(io, water);
    
    unsigned long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
    
    NSMutableData *mutableData = [NSMutableData dataWithLength:(NSUInteger)fileSize];
    
    dispatch_group_t group = dispatch_group_create();
    
    for (off_t currentSize = 0; currentSize <= fileSize; currentSize += water) {
        
        dispatch_group_enter(group);
        
        dispatch_io_read(io, currentSize, water, self.queue, ^(bool done, dispatch_data_t  _Nullable data, int error) {
            
            if (error == 0) {
                size_t len = dispatch_data_get_size(data);
                if (len > 0) {
                    const void *bytes = NULL;
                    (void)dispatch_data_create_map(data, (const void **)&bytes, &len);
                    [mutableData replaceBytesInRange:NSMakeRange((NSUInteger)currentSize, len) withBytes:bytes length:len];
                }
            }
            
            if (done) {
                dispatch_group_leave(group);
            }
        });
    }

    dispatch_group_notify(group, self.queue, ^{
        block([mutableData copy]);
    });
}

- (BOOL)suspend {
    if (self.isWorking == NO) {
        return NO;
    }
    
    dispatch_suspend(self.queue);
    self.isWorking = NO;
    return YES;
}

- (BOOL)resume {
    if (self.isWorking == YES) {
        return NO;
    }
    
    dispatch_resume(self.queue);
    self.isWorking = YES;
    return YES;
}

@end
