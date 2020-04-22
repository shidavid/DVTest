//
//  DVFlvTag.h
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVFlvTagHeader.h"
#import "DVFlvTagData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVFlvTag : NSObject

@property(nonatomic, strong, readonly) DVFlvTagHeader *tagHeader;
@property(nonatomic, strong, readonly) id<DVFlvTagData> tagData;
@property(nonatomic, strong, readonly) NSData *fullData;


#pragma mark - <-- Initializer -->
- (instancetype)initWithType:(DVFlvTagType)tagType
                     tagData:(id<DVFlvTagData>)tagData;

- (instancetype)initWithType:(DVFlvTagType)tagType
                   timeStamp:(UInt32)timeStamp
                     tagData:(id<DVFlvTagData>)tagData;

@end

NS_ASSUME_NONNULL_END
