//
//  NSMutableDictionary+DVAMF.m
//  iOS_Test
//
//  Created by DV on 2019/10/25.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "NSMutableDictionary+DVAMF.h"

@implementation NSMutableDictionary (DVAMF)

- (DVAMFType)amfType {
    return DVAMFTypeObject;
}

- (NSData *)amfData {
    NSMutableData *mData = [NSMutableData data];
    
    DVAMFType amfType = self.amfType;
    [mData appendBytes:&amfType length:1];
    
    for (NSString<DVAMF> *key in self.allKeys) {
        NSData *keyData = key.amfData;
        [mData appendData:[keyData subdataWithRange:NSMakeRange(1, keyData.length - 1)]];
        [mData appendData:((id<DVAMF>)self[key]).amfData];
    }
    
    uint16_t end1 = 0x0000;
    [mData appendBytes:&end1 length:2];
    uint8_t end2 = DVAMFTypeObjectEnd;
    [mData appendBytes:&end2 length:1];
    
    return [mData copy];
}

- (void)setAMFObject:(id<DVAMF>)anObject forAMFKey:(NSString<DVAMF> *)aKey {
    self[aKey] = anObject;
}

@end
