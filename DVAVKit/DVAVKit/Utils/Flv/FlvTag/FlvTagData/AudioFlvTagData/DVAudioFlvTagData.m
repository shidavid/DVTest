//
//  DVAudioFlvTagData.m
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVAudioFlvTagData.h"

@interface DVAudioFlvTagData ()

@property(nonatomic, assign, readwrite) DVAudioPacketFormatType formatType;
@property(nonatomic, assign, readwrite) DVAudioPacketSampleRateType sampleRateType;
@property(nonatomic, assign, readwrite) DVAudioPackeBitsType bitsType;
@property(nonatomic, assign, readwrite) DVAudioPacketAudioType audioType;
@property(nonatomic, strong, readwrite) NSData *packetData;

@end


@implementation DVAudioFlvTagData

#pragma mark - <-- Initializer -->
+ (instancetype)tagDataWithAACPacket:(DVAACAudioPacket *)packet {
    DVAudioFlvTagData *tagData = [[DVAudioFlvTagData alloc] init];
    tagData.formatType = DVAudioPacketFormatType_AAC;
    tagData.sampleRateType = DVAudioPacketSampleRateType_44Khz;
    tagData.bitsType = DVAudioPackeBitsType_16Bit;
    tagData.audioType = DVAudioPacketAudioType_Stereo;
    tagData.packetData = packet.fullData;
    return tagData;
}


#pragma mark - <-- Property -->
- (NSData *)fullData {
    NSMutableData *mData = [NSMutableData data];
    
    UInt8 header = (self.formatType << 4)
                 | (self.sampleRateType << 2)
                 | (self.bitsType << 1)
                 | self.audioType;
    [mData appendBytes:&header length:1];
    [mData appendData:self.packetData];
    
    return [mData copy];
}

@end
