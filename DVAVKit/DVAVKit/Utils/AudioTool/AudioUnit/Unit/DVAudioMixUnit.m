//
//  DVAudioMixUnit.m
//  iOS_Test
//
//  Created by DV on 2019/1/12.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import "DVAudioMixUnit.h"
#import "DVAudioUnit.h"

@interface DVAudioMixUnit()

@property (nonatomic, weak)  DVAudioUnit* wAudioUnit;

@end

@implementation DVAudioMixUnit

- (void)dealloc {
    _wAudioUnit = nil;
}

@end
