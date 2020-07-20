//
//  DVVideoCamera.h
//  iOS_Test
//
//  Created by DV on 2019/9/29.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVVideoCamera : NSObject

/// 分辨率
@property(nonatomic, copy) AVCaptureSessionPreset sessionPreset;
/// 摄像头前后
@property(nonatomic, assign, readonly) AVCaptureDevicePosition position;
/// 显示方向
@property (nonatomic, assign) AVCaptureVideoOrientation orientation;
/// 帧率
@property (nonatomic, assign) NSUInteger fps;
/// gop 最大关键帧间隔，一般设定为 fps 的2倍
@property (nonatomic, assign) NSUInteger gop;
/// 码率，单位是 bps
@property (nonatomic, assign) NSUInteger bitRate;
/// 自适应码率开关
@property(nonatomic, assign) BOOL adaptiveBitRate;
/// 输出图像是否等比例,默认为NO
@property (nonatomic, assign) BOOL isAspectRatio;
/// 自动旋转(这里只支持 left 变 right  portrait 变 portraitUpsideDown)
@property (nonatomic, assign) BOOL isAutoRotate;

///< 是否是横屏
@property (nonatomic, assign, readonly) BOOL isLandscape;

@property(nonatomic, assign) BOOL alwaysDiscardsLateVideoFrames;

@property (nonatomic, assign) BOOL mirror;

@property(nonatomic, assign) AVCaptureVideoStabilizationMode stabilizationMode;

@property(nonatomic, assign) AVCaptureFlashMode flashMode;

@property(nonatomic, assign) AVCaptureTorchMode torchMode;

@property(nonatomic, assign) AVCaptureFocusMode focusMode;

@property(nonatomic, assign) AVCaptureWhiteBalanceMode whiteBalanceMode;

@property(nonatomic, assign) CGFloat videoZoomFactor;

@property(nonatomic, assign) BOOL adjustHDR;
@property(nonatomic, assign) BOOL videoHDREnabled;

@end

NS_ASSUME_NONNULL_END
