//
//  NSString+DVAMF.m
//  iOS_Test
//
//  Created by DV on 2019/10/25.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "NSString+DVAMF.h"

@implementation NSString (DVAMF)

- (DVAMFType)amfType {
    return self.length > 0xFFFF ? DVAMFTypeLongString : DVAMFTypeString;
}

- (NSData *)amfData {
    NSMutableData *mData = [NSMutableData data];
    
    DVAMFType amfType = self.amfType;
    [mData appendBytes:&amfType length:1];
    
    if (amfType == DVAMFTypeString) {
        uint16_t len = CFSwapInt16HostToBig(self.length);
        [mData appendBytes:&len length:2];
    } else if (amfType == DVAMFTypeLongString) {
        uint32_t len = CFSwapInt32HostToBig((uint32_t)self.length);
        [mData appendBytes:&len length:4];
    }
    
    NSData *strData = [self dataUsingEncoding:NSASCIIStringEncoding];
    [mData appendData:strData];
    
    return [mData copy];
}

@end
