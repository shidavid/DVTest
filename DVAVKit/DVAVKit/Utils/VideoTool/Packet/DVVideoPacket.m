//
//  DVVideoPacket.m
//  DVAVKit
//
//  Created by 施达威 on 2019/4/8.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVVideoPacket.h"

@implementation DVVideoPacket

- (instancetype)initWithData:(uint8_t *)mData size:(UInt32)mSize {
    self = [super init];
    if (self) {
        _mData = (uint8_t *)malloc(mSize * sizeof(uint8_t));
        memcpy(_mData, mData, mSize);
        _mSize = mSize;
    }
    return self;
}

- (void)dealloc
{
    free(_mData);
    _mData = nil;
}

- (NSData *)data {
    // 不复制 data内存，只存指针地址
    return [NSData dataWithBytesNoCopy:_mData length:_mSize freeWhenDone:NO];
}

@end
