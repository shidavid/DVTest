//
//  NSNumber+DVAMF.m
//  iOS_Test
//
//  Created by DV on 2019/10/25.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "NSNumber+DVAMF.h"

@implementation NSNumber (DVAMF)

- (DVAMFType)amfType {
    return strcmp(self.objCType, "c") == 0 ? DVAMFTypeBool : DVAMFTypeNumber;
}

- (NSData *)amfData {
    NSMutableData *mData = [NSMutableData data];
    
    DVAMFType amfType = self.amfType;
    [mData appendBytes:&amfType length:1];
    
    if (amfType == DVAMFTypeBool) {
        uint8_t num = (uint8_t)[self boolValue];
        [mData appendBytes:&num length:1];
    } else if (amfType == DVAMFTypeNumber) {
        double value = [self doubleValue];
        uint8_t *pIn = (uint8_t *)&value;
        uint8_t pOut[8] = {0};
        
        pOut[0] = pIn[7];
        pOut[1] = pIn[6];
        pOut[2] = pIn[5];
        pOut[3] = pIn[4];
        pOut[4] = pIn[3];
        pOut[5] = pIn[2];
        pOut[6] = pIn[1];
        pOut[7] = pIn[0];

        [mData appendBytes:&pOut length:8];
    }
    
    return [mData copy];
}

@end
