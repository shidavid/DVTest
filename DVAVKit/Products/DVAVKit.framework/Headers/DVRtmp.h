//
//  DVRtmp.h
//  iOS_Test
//
//  Created by DV on 2019/10/17.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVRtmpBuffer.h"
#import "DVFlvKit.h"
#import "DVRtmpError.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(UInt8, DVRtmpStatus) {
    DVRtmpStatus_Disconnected = 0,
    DVRtmpStatus_Connecting,
    DVRtmpStatus_Connected,
    DVRtmpStatus_Reconnecting,
};


#pragma mark - <-------------------- DVRtmpDelegate -------------------->
@protocol DVRtmp;
@protocol DVRtmpDelegate <NSObject>

- (void)DVRtmp:(id<DVRtmp>)rtmp status:(DVRtmpStatus)status;

- (void)DVRtmp:(id<DVRtmp>)rtmp error:(DVRtmpError *)error;

@end



#pragma mark - <-------------------- DVRtmp -------------------->
@protocol DVRtmp <NSObject>

#pragma mark - <-- Property -->
@property(nonatomic, weak) id<DVRtmpDelegate> delegate;
@property(nonatomic, weak) id<DVRtmpBufferDelegate> bufferDelegate;

@property(nonatomic, assign) uint32_t beginTimeStamp;

@property(nonatomic, assign) NSUInteger reconnectCount;

@property(nonatomic, assign, readonly) DVRtmpStatus rtmpStatus;
@property(nonatomic, copy,   readonly, nullable) NSString *url;



#pragma mark - <-- Initializer -->
- (instancetype)initWithDelegate:(id<DVRtmpDelegate>)delegate;


#pragma mark - <-- Method -->
- (void)connectToURL:(NSString *)url;
- (void)reconnect;
- (void)disconnect;

- (void)setMetaHeader:(DVMetaFlvTagData *)metaHeader;
- (void)setVideoHeader:(DVVideoFlvTagData *)videoHeader;
- (void)setAudioHeader:(DVAudioFlvTagData *)audioHeader;

- (void)sendPacket:(DVRtmpPacket *)packet;

@end

NS_ASSUME_NONNULL_END
