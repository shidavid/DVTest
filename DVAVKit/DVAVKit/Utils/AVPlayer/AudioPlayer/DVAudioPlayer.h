//
//  DVAudioPlayer.h
//  French
//
//  Created by 施达威 on 2019/5/3.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DVAudioPlayerStatus) {
    DVAudioPlayerStatusPlay,
    DVAudioPlayerStatusPause,
    DVAudioPlayerStatusStop,
};

@class DVAudioPlayer;
@protocol DVAudioPlayerDelegate <NSObject>

- (void)DVAudioPlayer:(DVAudioPlayer *)player status:(DVAudioPlayerStatus)status;

@end


@interface DVAudioPlayer : NSObject

@property(nonatomic, weak) id<DVAudioPlayerDelegate> mDelegate;

@property(nonatomic, assign, readonly) DVAudioPlayerStatus playerStatus;



- (instancetype)initWithDelegate:(id<DVAudioPlayerDelegate>)mDelegate;

- (void)playWithURL:(NSString *)url;
- (void)playWithURLs:(NSArray<NSString *> *)urls;

- (void)addURL:(NSString *)url;
- (void)addURLs:(NSArray<NSString *> *)urls;

//- (void)removeURL:(NSString *)url;
//- (void)removeURLs:(NSArray<NSString *> *)urls;
//- (void)removeAllURLs;

- (void)play;
- (void)pause;
- (void)stop;

- (void)seekToTime:(NSUInteger)time;

//- (void)

//- (void)pre;
//- (void)next;

//- (void)forward:(NSTimeInterval)interval;
//- (void)back:(NSTimeInterval)interval;

@end

NS_ASSUME_NONNULL_END
