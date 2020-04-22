//
//  LiveViewModel.m
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/4/10.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import "LiveListViewModel.h"

@implementation LiveListViewModel

- (NSDictionary<NSString *,NSString *> *)tableItems {
    return @{
        @"H264推流" : @"H264LiveViewController",
        @"HEVC推流" : @"HEVCLiveViewController",
        @"H264 HEVC拉流" : @"H264HEVCLivePlayerViewController",
    };
}

@end
