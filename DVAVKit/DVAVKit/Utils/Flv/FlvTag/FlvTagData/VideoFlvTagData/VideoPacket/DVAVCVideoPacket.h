//
//  DVAVCVideoPacket.h
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(UInt8, DVAVCVideoPacketType) {
    DVAVCVideoPacketType_Header = 0x00,
    DVAVCVideoPacketType_AVC = 0x01,
    DVAVCVideoPacketType_End = 0x02,
};



#pragma mark - <-------------------- Class -------------------->
@interface DVAVCVideoPacket : NSObject

#pragma mark - <-- Property -->
@property(nonatomic, assign, readonly) DVAVCVideoPacketType packetType;
@property(nonatomic, assign, readonly) UInt32 timeStamp;
@property(nonatomic, strong, readonly) NSData *videoData;

@property(nonatomic, strong, readonly) NSData *fullData;


#pragma mark - <-- Initializer -->
+ (instancetype)headerPacketWithSps:(NSData *)sps pps:(NSData *)pps;
+ (instancetype)packetWithAVC:(NSData *)avcData timeStamp:(UInt32)timeStamp;
+ (instancetype)endPacket;

@end

NS_ASSUME_NONNULL_END
