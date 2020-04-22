//
//  DVAudioDecoder.h
//  iOS_Test
//
//  Created by DV on 2019/9/25.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- DVAudioDecoderDelegate -------------------->
@protocol DVAudioDecoder;
@protocol DVAudioDecoderDelegate <NSObject>

- (void)DVAudioDecoder:(id<DVAudioDecoder>)decoder
           decodedData:(NSData *)data
              userInfo:(nullable void *)userInfo;

@end


#pragma mark - <-------------------- DVAudioDecoder -------------------->
@protocol DVAudioDecoder <NSObject>
@optional

#pragma mark - <-- Property -->
@property(nonatomic, weak) id<DVAudioDecoderDelegate> delegate;


#pragma mark - <-- Method -->
- (instancetype)initWithInputBasicDesc:(AudioStreamBasicDescription)inputBasicDesc
                       outputBasicDesc:(AudioStreamBasicDescription)outputBasicDesc
                              delegate:(id<DVAudioDecoderDelegate>)delegate;

- (void)decodeAudioData:(nullable NSData *)data
               userInfo:(nullable void *)userInfo;

- (void)decodeAudioData:(nullable void *)data
                   size:(UInt32)size
               userInfo:(nullable void *)userInfo;

- (void)closeDecoder;

@end

NS_ASSUME_NONNULL_END
