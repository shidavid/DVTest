//
//  DVVideoFlvTagData.h
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVFlvTagData.h"
#import "DVAVCVideoPacket.h"
#import "DVHEVCVideoPacket.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(UInt8, DVVideoFlvTagFrameType) {
    DVVideoFlvTagFrameType_Key          = 0x01,
    DVVideoFlvTagFrameType_NotKey       = 0x02,
    DVVideoFlvTagFrameType_H263_NotKey  = 0x03,
    DVVideoFlvTagFrameType_Server_Key   = 0x04,
    DVVideoFlvTagFrameType_Info         = 0x05,
};

typedef NS_ENUM(UInt8, DVVideoFlvTagCodecIDType) {
    DVVideoFlvTagCodecIDType_JPEG           = 0x01,
    DVVideoFlvTagCodecIDType_H263           = 0x02,
    DVVideoFlvTagCodecIDType_Screen         = 0x03,
    DVVideoFlvTagCodecIDType_On2_VP6        = 0x04,
    DVVideoFlvTagCodecIDType_On2_VP6_Alpha  = 0x05,
    DVVideoFlvTagCodecIDType_Screen_V2      = 0x06,
    DVVideoFlvTagCodecIDType_AVC            = 0x07, // DVAVCVideoPacket
    DVVideoFlvTagCodecIDType_HEVC           = 0x0C, // DVHEVCVideoPacket
};



#pragma mark - <-------------------- Class -------------------->
@interface DVVideoFlvTagData : NSObject <DVFlvTagData>

#pragma mark - <-- Property -->
@property(nonatomic, assign, readonly) DVVideoFlvTagFrameType frameType;
@property(nonatomic, assign, readonly) DVVideoFlvTagCodecIDType codecIDType;
@property(nonatomic, strong, readonly) NSData *packetData;


#pragma mark - <-- Initializer -->
+ (instancetype)tagDataWithFrameType:(DVVideoFlvTagFrameType)frameType
                           avcPacket:(DVAVCVideoPacket *)packet;

+ (instancetype)tagDataWithFrameType:(DVVideoFlvTagFrameType)frameType
                          hevcPacket:(DVHEVCVideoPacket *)packet;

@end

NS_ASSUME_NONNULL_END
