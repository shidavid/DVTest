//
//  EncoderG726.m
//  TalkDemo_G711_AAC
//
//  Created by DV on 2018/11/6.
//  Copyright © 2018年 aipu. All rights reserved.
//

#import "EncoderG726.h"
#import "G726Encodec.hpp"

@implementation EncoderG726 {
    G726 *g726;
}


- (instancetype)init{
    self = [super init];
    if (self) {
        g726 = new G726();
    }
    return self;
}

- (void)dealloc
{
    if (g726 != NULL) {
        delete g726;
    }
}

//- (void)initConfig{
//    g726 = new G726();
////    g726->init();
//}


//- (NSData *)encoder:(NSData *)pcm{
//
//    uint8_t *cdata = (uint8_t*)[pcm bytes];
//    G726AudioPacket packet =  g726->encoder(cdata);
//
//    if (packet.flag == 1) {
//        NSData *result = [NSData dataWithBytes:packet.data length:packet.dataSize];
//        return result;
//    }
//
//    return [NSData new];
//}


- (NSData *)encoder:(uint8_t *)data size:(int)size {
    G726AudioPacket packet = g726->encoder((uint8_t*)data, size);
    
    if (packet.flag == 1) {
        NSData *result = [NSData dataWithBytes:packet.data length:packet.dataSize];
        return result;
    }
    return [NSData new];
}

@end
