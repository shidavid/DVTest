//
//  DVAudioEncoder.h
//  iOS_Test
//
//  Created by DV on 2019/9/25.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DVAudioEncoder;
@protocol DVAudioEncoderDelegate <NSObject>

- (void)DVAudioEncoder:(nullable id<DVAudioEncoder>)encoder
             codedData:(nullable NSData *)data
              userInfo:(nullable void *)userInfo;
@end



@protocol DVAudioEncoder <NSObject>
@optional

#pragma mark - <-- Property -->
@property(nonatomic, weak) id<DVAudioEncoderDelegate> delegate;


#pragma mark - <-- Method -->
- (instancetype)initWithInputBasicDesc:(AudioStreamBasicDescription)inputBasicDesc
                       outputBasicDesc:(AudioStreamBasicDescription)outputBasicDesc
                              delegate:(id<DVAudioEncoderDelegate>)delegate;

- (void)encodeAudioData:(nullable NSData *)data
               userInfo:(nullable void *)userInfo;

- (void)encodeAudioData:(nullable void *)data
                   size:(UInt32)size
               userInfo:(nullable void *)userInfo;

- (void)closeEncoder;


- (NSData *)convertToADTSWithData:(NSData *)sourceData channel:(NSInteger)channel;

@end

NS_ASSUME_NONNULL_END
