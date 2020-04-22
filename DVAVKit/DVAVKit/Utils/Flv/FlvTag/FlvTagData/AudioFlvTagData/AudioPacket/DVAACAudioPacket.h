//
//  DVAACAudioPacket.h
//  iOS_Test
//
//  Created by DV on 2019/10/21.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(UInt8,DVAACAudioPacketType) {
    DVAACAudioPacketType_Header = 0x00,
    DVAACAudioPacketType_AAC    = 0x01,
};



#pragma mark - <-------------------- Class -------------------->
@interface DVAACAudioPacket : NSObject

#pragma mark - <-- Property -->
@property(nonatomic, assign, readonly) DVAACAudioPacketType packetType;
@property(nonatomic, strong, readonly, nullable) NSData *sequenceHeader;
@property(nonatomic, strong, readonly, nullable) NSData *audioData;

@property(nonatomic, strong, readonly) NSData *fullData;


#pragma mark - <-- Initializer -->
+ (instancetype)headerPacketWithSampleRate:(NSUInteger)sampleRate channels:(UInt32)channels;
+ (instancetype)packetWithAAC:(NSData *)aacData;

@end

NS_ASSUME_NONNULL_END
