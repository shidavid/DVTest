//
//  FFPacket.m
//  DVAVKit
//
//  Created by 施达威 on 2019/3/30.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "FFPacket.h"
#import "libFFmpeg.hpp"

@interface FFPacket () {
    @public
    AVPacket *_pkt;
}
@end


@implementation FFPacket

- (void)dealloc
{
    if (_pkt != NULL) {
        av_packet_unref(_pkt);
        av_packet_free(&_pkt);
    }
}

- (NSData *)datas {
    // 不复制 data内存，只存指针地址
    return [NSData dataWithBytesNoCopy:_pkt->data length:_pkt->size freeWhenDone:NO];
}

- (uint8_t *)data {
    return _pkt->data;
}

- (void)setData:(uint8_t *)data {
    _pkt->data = data;
}

- (int)size {
    return _pkt->size;
}

- (void)setSize:(int)size {
    _pkt->size = size;
}

- (int64_t)pts {
    return _pkt->pts;
}

- (void)setPts:(int64_t)pts {
    _pkt->pts = pts;
}

- (int64_t)dts {
    return _pkt->dts;
}

- (void)setDts:(int64_t)dts {
    _pkt->dts = dts;
}

@end
