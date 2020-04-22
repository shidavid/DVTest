//
//  DVFlvTagHeader.h
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Define -------------------->
typedef NS_ENUM(UInt8, DVFlvTagType) {
    DVFlvTagType_Mate = 0x12,
    DVFlvTagType_Video = 0x09,
    DVFlvTagType_Audio = 0x08,
};


#pragma mark - <-------------------- Class -------------------->
@interface DVFlvTagHeader : NSObject

#pragma mark - <-- Property -->
/// 类型, 1Bytes
@property(nonatomic, assign, readonly) DVFlvTagType tagType;
/// tagData长度, 3Bytes
@property(nonatomic, assign, readonly) UInt32 dataSize;
/// 时间戳, 4Bytes
@property(nonatomic, assign) UInt32 timeStamp;
/// 3Bytes, 默认:0
@property(nonatomic, assign) UInt32 streamsID;

@property(nonatomic, strong, readonly) NSData *fullData;


#pragma mark - <-- Initializer -->
- (instancetype)initWithTagType:(DVFlvTagType)tagType;

@end

NS_ASSUME_NONNULL_END
