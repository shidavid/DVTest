//
//  DVAudioPacket.m
//  DVAVKit
//
//  Created by DV on 2019/4/7.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVAudioPacket.h"

@implementation DVAudioPacket

- (instancetype)initWithData:(uint8_t *)mData size:(UInt32)mSize {
    self = [super init];
    if (self) {
        _mData = (uint8_t *)malloc(mSize * sizeof(uint8_t));
        memcpy(_mData, mData, mSize);
        _mSize = mSize;
        _readIndex = 0;
    }
    return self;
}

- (void)dealloc {
    _userInfo = nil;
    
    free(_mData);
    _mData = nil;
}

@end
