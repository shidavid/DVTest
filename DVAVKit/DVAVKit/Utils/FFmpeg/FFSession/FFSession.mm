//
//  FFSession.m
//  DVAVKit
//
//  Created by DV on 2019/3/31.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "FFSession.h"
#import "libFFmpeg.hpp"

@implementation FFSession

+ (void)enableSession {
    av_register_all();
}

+ (void)enableNetWork {
    avformat_network_init();
}

+ (void)disableNetWork {
    avformat_network_deinit();
}

@end
