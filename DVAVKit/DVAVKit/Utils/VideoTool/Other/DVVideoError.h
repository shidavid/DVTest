//
//  DVVideoError.h
//  iOS_Test
//
//  Created by DV on 2019/9/27.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DVVideoErrorType) {
    DVVideoError_notErr         = 0,
    DVVideoError_DropSample     = 20000,
};


void VideoCheckStatus(OSStatus status, NSString *message);


@interface DVVideoError : NSError

@property(nonatomic, assign, readonly) DVVideoErrorType errorType;

- (instancetype)initWithType:(DVVideoErrorType)errorType;

+ (instancetype)errorWithType:(DVVideoErrorType)errorType;

@end

NS_ASSUME_NONNULL_END
