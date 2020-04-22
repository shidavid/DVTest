//
//  DVAMF.h
//  iOS_Test
//
//  Created by DV on 2019/10/25.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(UInt8, DVAMFType) {
    DVAMFTypeNumber     = 0x00,
    DVAMFTypeBool       = 0x01,
    DVAMFTypeString     = 0x02,
    DVAMFTypeObject     = 0x03,
    DVAMFTypeObjectEnd  = 0x09,
    DVAMFTypeLongString = 0x0C,
};


#pragma mark - <-------------------- Protocol -------------------->
@protocol DVAMF <NSObject>

@property(nonatomic, assign, readonly) DVAMFType amfType;
@property(nonatomic, assign, readonly) NSData *amfData;

@end

NS_ASSUME_NONNULL_END
