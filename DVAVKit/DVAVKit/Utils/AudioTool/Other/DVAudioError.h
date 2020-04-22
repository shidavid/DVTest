//
//  DVAudioError.h
//  iOS_Test
//
//  Created by DV on 2019/1/11.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DVAudioErrorType) {
    DVAudioError_notErr         = 0,
    DVAudioError_notRecord      = 10000,
    DVAudioError_notPlay        = 10001,
};


void AudioCheckStatus(OSStatus status, NSString *message);



@interface DVAudioError : NSError

@property(nonatomic, assign, readonly) DVAudioErrorType errorType;

- (instancetype)initWithType:(DVAudioErrorType)errorType;

+ (instancetype)errorWithType:(DVAudioErrorType)errorType;

@end

NS_ASSUME_NONNULL_END
