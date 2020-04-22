//
//  DVAudioPlayer.m
//  French
//
//  Created by 施达威 on 2019/5/3.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface DVAudioPlayer ()

@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) NSMutableArray<NSURL *>* urls;
@property(nonatomic, assign, readwrite) DVAudioPlayerStatus playerStatus;
//@property(nonatomic, strong) DVGCD *queue;
@property(nonatomic, assign) NSUInteger index;

@end


@implementation DVAudioPlayer

- (instancetype)initWithDelegate:(id<DVAudioPlayerDelegate>)mDelegate {
    self = [super init];
    if (self) {
        self.mDelegate = mDelegate;
        
        self.urls = [NSMutableArray array];
        self.player = [[AVPlayer alloc] init];
        self.player.rate = 2;
        
//        self.queue = [DVGCD queueWithName:@"com.avplayer.queue" type:DVQueueType_Serial];
        self.playerStatus = DVAudioPlayerStatusStop;
        self.index = 0;
        
        [self addKVO];
    }
    return self;
}

- (void)addKVO {
//    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
//    [self.player removeObserver:self forKeyPath:@"status"];
    [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
    
    if (_mDelegate) {
        _mDelegate = nil;
    }
    if (_player) {
        [_player pause];
        _player = nil;
    }
}


#pragma mark - <-- Method -->
- (void)playWithURL:(NSString *)url {
    NSURL *tmpURL = [NSURL URLWithString:url];
    [self.urls removeAllObjects];
    [self.urls addObject:tmpURL];
    self.index = 0;
    [self stop];
    [self play];
}

- (void)playWithURLs:(NSArray<NSString *> *)urls {
    
}

- (void)addURL:(NSString *)url {
    NSURL *tmpURL = [NSURL URLWithString:url];
    [self.urls addObject:tmpURL];
}

- (void)addURLs:(NSArray<NSString *> *)urls {
    
}


- (void)play {
    if (self.playerStatus == DVAudioPlayerStatusPause) {
        [self.player play];
    } else if (self.playerStatus == DVAudioPlayerStatusStop){
        self.playerStatus = DVAudioPlayerStatusPlay;
        NSURL *tmpURL = self.urls[self.index];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:tmpURL];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        [self.player play];
    }

//    __weak __typeof(self)weakSelf = self;
//    [self.queue async:^{
//        [weakSelf.player play];
//    }];
}

- (void)pause {
    self.playerStatus = DVAudioPlayerStatusPause;
    [self.player pause];
//    __weak __typeof(self)weakSelf = self;
//    [self.queue async:^{
//        [weakSelf.player pause];
//    }];
}

- (void)stop {
    self.playerStatus = DVAudioPlayerStatusStop;
    [self.player pause];
//    __weak __typeof(self)weakSelf = self;
//    [self.queue async:^{
//        [weakSelf.player pause];
//    }];
}

- (void)pre {
    
    
}

- (void)next {
    
}

- (void)seekToTime:(NSUInteger)time {
    [self.player seekToTime:CMTimeMake(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


#pragma mark - <-- KVO -->
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
}

@end
