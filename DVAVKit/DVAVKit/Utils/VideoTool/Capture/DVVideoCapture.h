//
//  DVVideoCapture.h
//  iOS_Test
//
//  Created by DV on 2019/9/27.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVVideoConfig.h"
#import "DVVideoCamera.h"
#import "DVVideoError.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Delegate -------------------->
@class DVVideoCapture;
@protocol DVVideoCaptureDelegate <NSObject>

- (void)DVVideoCapture:(DVVideoCapture *)capture
    outputSampleBuffer:(CMSampleBufferRef)sampleBuffer
                 error:(nullable DVVideoError *)error;

@end


#pragma mark - <-------------------- Class -------------------->
@interface DVVideoCapture : NSObject

#pragma mark - <-- Property -->
@property(nonatomic, assign, readonly) BOOL isRunning;
@property(nonatomic, strong, readonly) UIView *preView;
@property(nonatomic, strong, readonly) DVVideoCamera *camera;

@property(nonatomic, weak) id<DVVideoCaptureDelegate> delegate;



#pragma mark - <-- Initializer -->
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithConfig:(DVVideoConfig *)config delegate:(id<DVVideoCaptureDelegate>)delegate;



#pragma mark - <-- Method -->
- (void)start;
- (void)stop;

- (void)updateConfig:(DVVideoConfig *)config;
- (void)updateCamera:(void(^ _Nullable)(DVVideoCamera *camera)) block;

- (void)changeToFrontCamera;
- (void)changeToBackCamera;

@end

NS_ASSUME_NONNULL_END
