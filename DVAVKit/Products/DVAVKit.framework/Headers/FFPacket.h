//
//  FFPacket.h
//  DVAVKit
//
//  Created by 施达威 on 2019/3/30.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(NSUInteger, FFPacketType) {
    FFPacketTypeVideo = 0,
    FFPacketTypeAudio = 1,
};


#pragma mark - <-------------------- Class -------------------->
@interface FFPacket : NSObject

@property(nonatomic, assign) FFPacketType type;

@property(nonatomic, weak, readonly) NSData *datas;

@property(nonatomic, assign) uint8_t *data;
@property(nonatomic, assign) int size;

@property(nonatomic, assign) int64_t pts;
@property(nonatomic, assign) int64_t dts;

@end

NS_ASSUME_NONNULL_END
