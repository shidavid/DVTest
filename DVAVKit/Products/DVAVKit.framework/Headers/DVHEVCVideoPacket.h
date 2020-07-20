//
//  DVHEVCVideoPacket.h
//  DVAVKit
//
//  Created by 施达威 on 2019/3/22.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(UInt8, DVHEVCVideoPacketType) {
    DVHEVCVideoPacketType_Header = 0x00,
    DVHEVCVideoPacketType_HEVC = 0x01,
    DVHEVCVideoPacketType_End = 0x02,
};


#pragma mark - <-------------------- Class -------------------->
@interface DVHEVCVideoPacket : NSObject

#pragma mark - <-- Property -->
@property(nonatomic, assign, readonly) DVHEVCVideoPacketType packetType;
@property(nonatomic, assign, readonly) UInt32 timeStamp;
@property(nonatomic, strong, readonly) NSData *videoData;

@property(nonatomic, strong, readonly) NSData *fullData;


#pragma mark - <-- Initializer -->
+ (instancetype)headerPacketWithVps:(NSData *)vps sps:(NSData *)sps pps:(NSData *)pps;
+ (instancetype)packetWithHEVC:(NSData *)hevcData timeStamp:(UInt32)timeStamp;
+ (instancetype)endPacket;


@end

NS_ASSUME_NONNULL_END
