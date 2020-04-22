//
//  DVAACAudioPacket.m
//  iOS_Test
//
//  Created by DV on 2019/10/21.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVAACAudioPacket.h"

@interface DVAACAudioPacket ()

@property(nonatomic, assign, readwrite) DVAACAudioPacketType packetType;
@property(nonatomic, strong, readwrite, nullable) NSData *sequenceHeader;
@property(nonatomic, strong, readwrite, nullable) NSData *audioData;

@end


@implementation DVAACAudioPacket

#pragma mark - <-- Initializer -->
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)headerPacketWithSampleRate:(NSUInteger)sampleRate channels:(UInt32)channels {
    DVAACAudioPacket *packet = [[DVAACAudioPacket alloc] init];
    packet.packetType = DVAACAudioPacketType_Header;
    packet.sequenceHeader = [packet aacSequenceHeaderWithSampleRate:sampleRate channels:channels];
    return packet;
}

+ (instancetype)packetWithAAC:(NSData *)aacData {
    DVAACAudioPacket *packet = [[DVAACAudioPacket alloc] init];
    packet.packetType = DVAACAudioPacketType_AAC;
    packet.audioData = aacData;
    return packet;
}


#pragma mark - <-- Property -->
- (NSData *)fullData {
    NSMutableData *mData = [NSMutableData data];
    
    DVAACAudioPacketType packetType = self.packetType;
    [mData appendBytes:&packetType length:1];
    
    if (self.sequenceHeader) {
        [mData appendData:self.sequenceHeader];
    }
    
    if (self.audioData) {
        [mData appendData:self.audioData];
    }
    
    return [mData copy];
}


#pragma mark - <-- Method -->
- (NSData *)aacSequenceHeaderWithSampleRate:(NSUInteger)sampleRate
                                   channels:(UInt32)channels {
    UInt8 bytes[2] = {0,0};
    
    UInt8 audioObjectType = 2;
    UInt8 sampleRateIndex = [self sampleRateIndex:sampleRate];
    UInt8 channel = (UInt8)channels;
    UInt8 frameLengthFlag = 0;
    UInt8 dependOnCoreCoder = 0;
    UInt8 extensionFlag = 0;
    
    bytes[0] = (audioObjectType << 3) | (sampleRateIndex >> 1);
    bytes[1] = (sampleRateIndex & 0x01 << 7)
                | (channel << 3)
                | (frameLengthFlag << 2)
                | (dependOnCoreCoder << 1)
                | extensionFlag;
    
    return [NSData dataWithBytes:bytes length:2];
}


- (UInt8)sampleRateIndex:(NSUInteger)sampleRate {
    UInt8 sampleRateIndex = 0;
    switch (sampleRate) {
        case 96000:
            sampleRateIndex = 0x00;
            break;
        case 88200:
            sampleRateIndex = 0x01;
            break;
        case 64000:
            sampleRateIndex = 0x02;
            break;
        case 48000:
            sampleRateIndex = 0x03;
            break;
        case 44100:
            sampleRateIndex = 0x04;
            break;
        case 32000:
            sampleRateIndex = 0x05;
            break;
        case 24000:
            sampleRateIndex = 0x06;
            break;
        case 22050:
            sampleRateIndex = 0x07;
            break;
        case 16000:
            sampleRateIndex = 0x08;
            break;
        case 12000:
            sampleRateIndex = 0x09;
            break;
        case 11025:
            sampleRateIndex = 0x0A;
            break;
        case 8000:
            sampleRateIndex = 0x0B;
            break;
        case 7350:
            sampleRateIndex = 0x0C;
            break;
        default:
            sampleRateIndex = 0x0F;
    }
    return sampleRateIndex;
}

@end
