//
//  DVAVCVideoPacket.m
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVAVCVideoPacket.h"

@interface DVAVCVideoPacket ()

@property(nonatomic, assign, readwrite) DVAVCVideoPacketType packetType;
@property(nonatomic, assign, readwrite) UInt32 timeStamp;
@property(nonatomic, strong, readwrite) NSData *videoData;

@end

@implementation DVAVCVideoPacket

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeStamp = 0;
    }
    return self;
}

+ (instancetype)headerPacketWithSps:(NSData *)sps pps:(NSData *)pps {
    DVAVCVideoPacket *packet = [[DVAVCVideoPacket alloc] init];
    packet.packetType = DVAVCVideoPacketType_Header;
    packet.videoData = [packet getAVCDecoderConfigRecordWithSps:sps pps:pps];
    return packet;
}

+ (instancetype)packetWithAVC:(NSData *)avcData timeStamp:(UInt32)timeStamp {
    DVAVCVideoPacket *packet = [[DVAVCVideoPacket alloc] init];
    packet.packetType = DVAVCVideoPacketType_AVC;
    packet.timeStamp = timeStamp;
    packet.videoData = avcData;
    return packet;
}

+ (instancetype)endPacket {
    DVAVCVideoPacket *packet = [[DVAVCVideoPacket alloc] init];
    packet.packetType = DVAVCVideoPacketType_End;
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
- (NSData *)getAVCDecoderConfigRecordWithSps:(NSData *)sps pps:(NSData *)pps {

    const UInt8 *spsBytes = sps.bytes;
    const UInt8 *ppsBytes = pps.bytes;
    const NSUInteger spsLen = sps.length;
    const NSUInteger ppsLen = pps.length;
    
    int index = 0;
    int len = 11 + (int)spsLen + (int)ppsLen;
    
    UInt8 *body = (UInt8 *)malloc(len);
    memset(body, 0, len);
    
    body[index++] = 0x01;        // configuration
    body[index++] = spsBytes[1]; // AVCProfileIndication:  sps[1]
    body[index++] = spsBytes[2]; // profile_compatibility: sps[2]
    body[index++] = spsBytes[3]; // AVCLevelIndication:    sps[3]
    body[index++] = 0xff;        // lengthSizeMinusOne:  1111 1xxx -> xxx = lengthSizeMinusOne & 0x03 + 1
    
    body[index++] = 0xe1; // numOfSequenceParameterSets: sps个数 -> 111x xxxx
                          // x xxxx = numOfSequenceParameterSets & 0x1f
    body[index++] = (spsLen >> 8) & 0xff;  // sequenceParameterSetLength 2Bytes
    body[index++] = spsLen & 0xff;
    memcpy(&body[index], spsBytes, spsLen); // sequenceParameterSetNALUnits : sps内容
    index += spsLen;
    
    body[index++] = 0x01; // numOfPictureParameterSets : pps个数
    body[index++] = (ppsLen >> 8) & 0xff; // pictureParameterSetLength 2Bytes
    body[index++] = ppsLen & 0xff;
    memcpy(&body[index], ppsBytes, ppsLen); // pictureParameterSetNALUnits : pps内容
    index += ppsLen;
    
    NSData *data = [NSData dataWithBytes:body length:index];
    free(body);
    
    return data;
}

@end
