//
//  DVAudioFlvTagData.h
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVFlvTagData.h"
#import "DVAACAudioPacket.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(UInt8, DVAudioPacketFormatType) {
    DVAudioPacketFormatType_PCM_Platform_Endian = 0x00,
    DVAudioPacketFormatType_MP3                 = 0x02,
    DVAudioPacketFormatType_PCM_Little_Endian   = 0x03,
    DVAudioPacketFormatType_AAC                 = 0x0A,
};

typedef NS_ENUM(UInt8, DVAudioPacketSampleRateType) {
    DVAudioPacketSampleRateType_5_5Khz  = 0x00,
    DVAudioPacketSampleRateType_11Khz   = 0x01,
    DVAudioPacketSampleRateType_22Khz   = 0x02,
    DVAudioPacketSampleRateType_44Khz   = 0x03, // AAC总是这个
};

typedef NS_ENUM(UInt8, DVAudioPackeBitsType) {
    DVAudioPackeBitsType_8Bit  = 0x00,
    DVAudioPackeBitsType_16Bit = 0x01, // AAC总是这个
};

typedef NS_ENUM(UInt8, DVAudioPacketAudioType) {
    DVAudioPacketAudioType_Mono     = 0x00,
    DVAudioPacketAudioType_Stereo   = 0x01, // AAC总是这个
};



#pragma mark - <-------------------- Class -------------------->
@interface DVAudioFlvTagData : NSObject <DVFlvTagData>

#pragma mark - <-- Property -->
@property(nonatomic, assign, readonly) DVAudioPacketFormatType formatType;
@property(nonatomic, assign, readonly) DVAudioPacketSampleRateType sampleRateType;
@property(nonatomic, assign, readonly) DVAudioPackeBitsType bitsType;
@property(nonatomic, assign, readonly) DVAudioPacketAudioType audioType;
@property(nonatomic, strong, readonly) NSData *packetData;


#pragma mark - <-- Initializer -->
+ (instancetype)tagDataWithAACPacket:(DVAACAudioPacket *)packet;

@end

NS_ASSUME_NONNULL_END
