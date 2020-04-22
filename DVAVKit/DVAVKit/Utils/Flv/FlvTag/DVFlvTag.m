//
//  DVFlvTag.m
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVFlvTag.h"

@interface DVFlvTag ()

@property(nonatomic, strong, readwrite) DVFlvTagHeader *tagHeader;
@property(nonatomic, strong, readwrite) id<DVFlvTagData> tagData;

@end

@implementation DVFlvTag

#pragma mark - <-- Initializer -->
- (instancetype)initWithType:(DVFlvTagType)tagType
                     tagData:(id<DVFlvTagData>)tagData {
    return [self initWithType:tagType timeStamp:0 tagData:tagData];
}

- (instancetype)initWithType:(DVFlvTagType)tagType
                   timeStamp:(UInt32)timeStamp
                     tagData:(id<DVFlvTagData>)tagData {
    self = [super init];
    if (self) {
        self.tagHeader = [[DVFlvTagHeader alloc] initWithTagType:tagType];
        self.tagHeader.timeStamp = timeStamp;
        [self.tagHeader setValue:@((UInt32)(tagData.fullData.length)) forKey:@"_dataSize"];
        self.tagData = tagData;
    }
    return self;
}



#pragma mark - <-- Property -->
- (NSData *)fullData {
    NSMutableData *mData = [NSMutableData data];
    [mData appendData:self.tagHeader.fullData];
    [mData appendData:self.tagData.fullData];
    return [mData copy];
}

@end
