//
//  NSMutableArray+FFBuffer.m
//  DVAVKit
//
//  Created by DV on 2019/3/31.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "NSMutableArray+FFBuffer.h"

@implementation NSMutableArray (FFBuffer)

- (id)popFirstBuffer {
    id buffer = nil;
    if (self.count > 0) {
        buffer = self.firstObject;
        [self removeObjectAtIndex:0];
    }
    return buffer;
}

@end
