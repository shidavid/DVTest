//
//  DVRtmpPacket.m
//  iOS_Test
//
//  Created by DV on 2019/10/24.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVRtmpPacket.h"

@implementation DVRtmpPacket

- (void)dealloc {
    _videoData = nil;
    _audioData = nil;
}

@end
