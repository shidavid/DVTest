//
//  DVRtmpBuffer.m
//  iOS_Test
//
//  Created by DV on 2019/10/22.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVRtmpBuffer.h"
#import "NSMutableArray+DVRtmpBuffer.h"

@interface DVRtmpBuffer ()

@property(nonatomic, strong) dispatch_semaphore_t threadLock;
@property(nonatomic, strong) dispatch_queue_t monitorQueue;
@property(nonatomic, strong) dispatch_source_t monitorSource;

@property(nonatomic, strong) NSMutableArray<DVRtmpPacket *> *packetList;
@property(nonatomic, strong) NSMutableArray<DVRtmpPacket *> *sortList;
@property(nonatomic, strong) NSMutableArray<NSNumber *> *monitorList;

@property(nonatomic, assign) NSInteger sortMaxCount;
@property(nonatomic, assign) NSInteger monitorCurrent;
@property(nonatomic, assign) NSInteger monitorInterval;
@property(nonatomic, assign) NSInteger monitorFeedBackInterval;

@end


@implementation DVRtmpBuffer

#pragma mark - <-- Initializer -->
- (instancetype)init {
    self = [super init];
    if (self) {
        self.threadLock = dispatch_semaphore_create(1);
        
        self.packetList = [NSMutableArray array];
        self.sortList = [NSMutableArray array];
        self.monitorList = [NSMutableArray array];
        
        self.sortMaxCount = 5;
        self.bufferMaxCount = 25 * 60; // 25 FPS x 60S
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    _threadLock = nil;
  
    if (_packetList) {
        [_packetList removeAllObjects];
        _packetList = nil;
    }
    if (_sortList) {
        [_sortList removeAllObjects];
        _sortList = nil;
    }
    if (_monitorList) {
        [_monitorList removeAllObjects];
        _monitorList = nil;
    }
}


#pragma mark - <-- Property -->
- (void)setDelegate:(id<DVRtmpBufferDelegate>)delegate {
    _delegate = delegate;
    delegate ? [self initMonitor] : [self uninitMonitor];
}

- (NSArray<DVRtmpPacket *> *)bufferList {
    [self lock];
    NSArray<DVRtmpPacket *> *bufferList = [self.packetList copy];
    [self unlock];
    return bufferList;
}

- (NSUInteger)bufferCount {
    [self lock];
    NSUInteger count = self.packetList.count;
    [self unlock];
    return count;
}


#pragma mark - <-- Method -->
- (void)pushBuffer:(DVRtmpPacket *)buffer {
    if (!buffer) return;
    
    [self lock];
    [self.sortList addObject:buffer];
    
    if (self.sortList.count >= self.sortMaxCount) {
        [self.sortList sortWithOptions:NSSortConcurrent
                        usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            DVRtmpPacket * buffer1 = (DVRtmpPacket *)obj1;
            DVRtmpPacket * buffer2 = (DVRtmpPacket *)obj2;
            
            if (buffer1.timeStamp < buffer2.timeStamp)
                return NSOrderedAscending;
            if (buffer1.timeStamp > buffer2.timeStamp)
                return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        if (self.packetList.count >= self.bufferMaxCount && self.delegate) {
            __weak __typeof(self)weakSelf = self;
            [self.delegate DVRtmpBuffer:weakSelf
                     bufferOverMaxCount:self.packetList
                           deleteBuffer:^(NSArray<DVRtmpPacket *> *deleteBuffer) {
                [weakSelf.packetList removeObjectsInArray:deleteBuffer];
            }];
        }
        
        DVRtmpPacket *pBuffer = [self.sortList popFirstBuffer];
        if (pBuffer) [self.packetList addObject:pBuffer];
    }
    [self unlock];
}

- (DVRtmpPacket *)popBuffer {
    [self lock];
    DVRtmpPacket * pBuffer = [self.packetList popFirstBuffer];
    [self unlock];
    return pBuffer;
}

- (void)removeAllBuffer {
    [self lock];
    [self.packetList removeAllObjects];
    [self unlock];
}


#pragma mark - <-- Private Method -->
- (void)lock {
    dispatch_semaphore_wait(self.threadLock, DISPATCH_TIME_FOREVER);
}

- (void)unlock {
    dispatch_semaphore_signal(self.threadLock);
}


#pragma mark - <-- 监控缓冲状态 -->
- (void)initMonitor {
    if (self.monitorSource) {
        [self uninitMonitor];
    }
    
    self.monitorCurrent = 0;
    self.monitorInterval = 1;
    self.monitorFeedBackInterval = 5;
    
    __weak __typeof(self)weakSelf = self;
    self.monitorQueue = dispatch_queue_create("com.DVRtmp.Buffer.Monitor", NULL);
    self.monitorSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.monitorQueue);
    dispatch_source_set_timer(self.monitorSource, DISPATCH_TIME_NOW, self.monitorInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.monitorSource, ^{
        [weakSelf monitorBufferStatus];
    });
    dispatch_resume(self.monitorSource);
}

- (void)uninitMonitor {
    if (self.monitorSource) {
        dispatch_source_cancel(self.monitorSource);
        self.monitorSource = nil;
        self.monitorQueue = nil;
    }
}

- (void)monitorBufferStatus {
    [self.monitorList addObject:@(self.bufferCount)];
    
    self.monitorCurrent += self.monitorInterval;
    
    if (self.monitorCurrent >= self.monitorFeedBackInterval) {
        
        if (self.delegate) {
            __weak __typeof(self)weakSelf = self;
            DVRtmpBufferStatus status = self.currentBufferStatus;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delegate DVRtmpBuffer:weakSelf bufferStatus:status];
            });
        }
        
        self.monitorCurrent = 0;
        [self.monitorList removeAllObjects];
    }
}

- (DVRtmpBufferStatus)currentBufferStatus {
    NSUInteger preCount = 0;
    NSUInteger increaseCount = 0;
    NSUInteger decreaseCount = 0;
    
    for (NSNumber *num in self.monitorList) {
        num.unsignedIntegerValue > preCount ? (increaseCount += self.monitorInterval) : (decreaseCount += self.monitorInterval);
        preCount = num.unsignedIntegerValue;
    }
    
    
    DVRtmpBufferStatus status = DVRtmpBufferStatus_Steady;
    if (increaseCount >= self.monitorFeedBackInterval) {
        status = DVRtmpBufferStatus_Increase;
    }
    else if (decreaseCount >= self.monitorFeedBackInterval) {
        status = DVRtmpBufferStatus_Decrease;
    }
    
    return status;
}

@end
