
//
//  NSMutableArray+DVRtmpBuffer.m
//  iOS_Test
//
//  Created by DV on 2019/10/23.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "NSMutableArray+DVRtmpBuffer.h"

@implementation NSMutableArray (DVRtmpBuffer)

- (id)popFirstBuffer {
    id buffer = nil;
    if (self.count > 0) {
        buffer = self.firstObject;
        [self removeObjectAtIndex:0];
    }
    return buffer;
}


@end
