//
//  DVVideoPacket.h
//  DVAVKit
//
//  Created by 施达威 on 2019/4/8.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVVideoPacket : NSObject 

@property(nonatomic, weak, readonly) NSData *data;

@property(nonatomic, assign) uint8_t *mData;
@property(nonatomic, assign) int mSize;

@property(nonatomic, assign) int64_t pts;
@property(nonatomic, assign) int64_t dts;


- (instancetype)initWithData:(uint8_t *)mData size:(UInt32)mSize;

@end

NS_ASSUME_NONNULL_END
