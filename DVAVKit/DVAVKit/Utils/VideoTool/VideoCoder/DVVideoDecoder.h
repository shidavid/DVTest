//
//  DVVideoDecoder.h
//  iOS_Test
//
//  Created by DV on 2019/10/9.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import "DVVideoConfig.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- DVVideoEncoderDelegate -------------------->
@protocol DVVideoDecoder;
@protocol DVVideoDecoderDelegate <NSObject>

- (void)DVVideoDecoder:(id<DVVideoDecoder>)decoder
         decodecBuffer:(nullable CMSampleBufferRef)buffer
          isFirstFrame:(BOOL)isFirstFrame
              userInfo:(nullable void *)userInfo;

@end


#pragma mark - <-------------------- DVVideoEncoder -------------------->
@protocol DVVideoDecoder <NSObject>
@optional

@property(nonatomic, weak) id<DVVideoDecoderDelegate> delegate;

- (void)decodeVideoData:(NSData *)data
                    pts:(int64_t)pts
                    dts:(int64_t)dts
                    fps:(int)fps
               userInfo:(nullable void *)userInfo;

- (void)closeDecoder;

@end

NS_ASSUME_NONNULL_END
