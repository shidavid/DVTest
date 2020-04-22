//
//  DVHEVCVideoPacket.m
//  DVAVKit
//
//  Created by 施达威 on 2019/3/22.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVHEVCVideoPacket.h"

@interface DVHEVCVideoPacket ()

@property(nonatomic, assign, readwrite) DVHEVCVideoPacketType packetType;
@property(nonatomic, assign, readwrite) UInt32 timeStamp;
@property(nonatomic, strong, readwrite) NSData *videoData;

@end

@implementation DVHEVCVideoPacket

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeStamp = 0;
    }
    return self;
}

+ (instancetype)headerPacketWithVps:(NSData *)vps sps:(NSData *)sps pps:(NSData *)pps {
    DVHEVCVideoPacket *packet = [[DVHEVCVideoPacket alloc] init];
    packet.packetType = DVHEVCVideoPacketType_Header;
    packet.videoData = [packet getHEVCDecoderConfigRecordWithVps:vps sps:sps pps:pps];
    return packet;
}

+ (instancetype)packetWithHEVC:(NSData *)hevcData timeStamp:(UInt32)timeStamp {
    DVHEVCVideoPacket *packet = [[DVHEVCVideoPacket alloc] init];
    packet.packetType = DVHEVCVideoPacketType_HEVC;
    packet.timeStamp = timeStamp;
    packet.videoData = hevcData;
    return packet;
}

+ (instancetype)endPacket {
    DVHEVCVideoPacket *packet = [[DVHEVCVideoPacket alloc] init];
    packet.packetType = DVHEVCVideoPacketType_End;
    packet.videoData = [NSData data];
    return packet;
}


#pragma mark - <-- Property -->
- (NSData *)fullData {
    NSMutableData *mData = [NSMutableData data];
    
    UInt8 type = _packetType;
    UInt32 timeStamp = (_timeStamp & 0x00ffffff) << 8;
    
    [mData appendBytes:&type length:1];
    [mData appendBytes:&timeStamp length:3];
    [mData appendData:_videoData];

    return [mData copy];
}


#pragma mark - <-- Method -->
- (NSData *)getHEVCDecoderConfigRecordWithVps:(NSData *)vps sps:(NSData *)sps pps:(NSData *)pps {
    
    const UInt8 *vpsBytes = vps.bytes;
    const UInt8 *spsBytes = sps.bytes;
    const UInt8 *ppsBytes = pps.bytes;
    const NSUInteger vpsLen = vps.length;
    const NSUInteger spsLen = sps.length;
    const NSUInteger ppsLen = pps.length;
    
    int index = 0;
    int len = 38 + (int)vpsLen + (int)spsLen + (int)ppsLen;
    
    UInt8 *body = (UInt8 *)malloc(len);
    memset(body, 0, len);
    
    
    body[index++] = 0x01; // configurationVersion-8
    body[index++] = 0x01; // general_profile_space-2 | general_tier_flag-1 | general_profile_idc-5
    body[index++] = 0x60; // general_profile_compatibility_flags-32
    body[index++] = 0x00;
    body[index++] = 0x00;
    body[index++] = 0x00;
    body[index++] = 0x90; // general_constraint_indicator_flags-48
    body[index++] = 0x00;
    body[index++] = 0x00;
    body[index++] = 0x00;
    body[index++] = 0x00;
    body[index++] = 0x00;
    body[index++] = 0x5A; // general_level_idc-8
    body[index++] = 0xF0; // 1111 + min_spatial_segmentation_idc-12
    body[index++] = 0x00;
    body[index++] = 0xFC; // 111111 | parallelismType-2
    body[index++] = 0xFD; // 111111 | chromaFormat-2
    body[index++] = 0xF8; // 11111  | bitDepthLumaMinus-3
    body[index++] = 0xF8; // 11111  | bitDepthChromaMinus-3
    body[index++] = 0x00; // avgFrameRate-16
    body[index++] = 0x00;
    body[index++] = 0x0F; // constantFrameRate-2 | numTemporalLayers-3 | temporalIdNested-1 | lengthSizeMinusOne-2
    body[index++] = 0x03; // numOfArrays-8
    
    
    #pragma mark - <-------------------- vps -------------------->
    body[index++] = 0x20; // vps类型
    body[index++] = 0x00; // vps数量
    body[index++] = 0x01;
    body[index++] = (vpsLen >> 8) & 0xff;  // vps长度
    body[index++] = vpsLen & 0xff;
    memcpy(&body[index], vpsBytes, vpsLen); // vps内容
    index += vpsLen;
    
    #pragma mark - <-------------------- sps -------------------->
    body[index++] = 0x21; // sps类型
    body[index++] = 0x00; // sps数量
    body[index++] = 0x01;
    body[index++] = (spsLen >> 8) & 0xff;  // sps长度
    body[index++] = spsLen & 0xff;
    memcpy(&body[index], spsBytes, spsLen); // sps内容
    index += spsLen;
    
    #pragma mark - <-------------------- pps -------------------->
    body[index++] = 0x22; // pps类型
    body[index++] = 0x00; // pps数量
    body[index++] = 0x01;
    body[index++] = (ppsLen >> 8) & 0xff;  // pps长度
    body[index++] = ppsLen & 0xff;
    memcpy(&body[index], ppsBytes, ppsLen); // pps内容
    index += ppsLen;
    
    
    NSData *data = [NSData dataWithBytes:body length:index];
    free(body);
    
    return data;
}

@end
