//
//  DVRtmpError.h
//  iOS_Test
//
//  Created by DV on 2019/10/24.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DVRtmpErrorType) {
    DVRtmpErrorNotErr                  = 0,
    DVRtmpErrorFailToSendPacket        = -30000,
    DVRtmpErrorFailToSendMetaHeader    = -30001,
    DVRtmpErrorFailToSendVideoHeader   = -30002,
    DVRtmpErrorFailToSendAudioHeader   = -30003,
    DVRtmpErrorURLFormatIncorrect      = -30004,
    DVRtmpErrorFailToSetURL            = -30005,
    DVRtmpErrorFailToConnectServer     = -30006,
    DVRtmpErrorFailToConnectStream     = -30007,
};

void RtmpCheckStatus(int status, NSString *message);


@interface DVRtmpError : NSError

@property(nonatomic, assign, readonly) DVRtmpErrorType errorType;

- (instancetype)initWithType:(DVRtmpErrorType)errorType;

+ (instancetype)errorWithType:(DVRtmpErrorType)errorType;

@end

NS_ASSUME_NONNULL_END
