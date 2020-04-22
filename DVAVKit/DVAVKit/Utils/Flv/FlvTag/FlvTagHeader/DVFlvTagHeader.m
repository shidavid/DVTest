//
//  DVFlvTagHeader.m
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVFlvTagHeader.h"

@interface DVFlvTagHeader ()

@property(nonatomic, assign, readwrite) DVFlvTagType tagType;
@property(nonatomic, assign, readwrite) UInt32 dataSize;

@end


@implementation DVFlvTagHeader

#pragma mark - <-- Initializer -->
- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeStamp = 0;
        self.streamsID = 0;
    }
    return self;
}

- (instancetype)initWithTagType:(DVFlvTagType)tagType {
    self = [self init];
    if (self) {
        self.tagType = tagType;
    }
    return self;
}



#pragma mark - <-- Property -->
- (NSData *)fullData {
    NSMutableData *mData = [NSMutableData data];
    
    DVFlvTagType tagType = _tagType;
    [mData appendBytes:&(tagType) length:1];
    
    UInt32 dataSize  = (_dataSize & 0x00ffffff) << 8;
    [mData appendBytes:&dataSize length:3];
    
    UInt32 timeStamp = (_timeStamp & 0x00ffffff) << 8;
    [mData appendBytes:&timeStamp length:3];
    
    UInt32 timeStampEx = (_timeStamp & 0xff000000);
    [mData appendBytes:&timeStampEx length:1];
    
    UInt32 streamsID = (_streamsID & 0x00ffffff) << 8;
    [mData appendBytes:&streamsID length:3];
    
    return [mData copy];
}

@end
