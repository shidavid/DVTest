
//
//  DVVideoCamera.m
//  iOS_Test
//
//  Created by DV on 2019/9/29.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVVideoCamera.h"
#import <AVFoundation/AVFoundation.h>

@interface DVVideoCamera ()

@property(nonatomic, weak) AVCaptureDevice *wDevice;
@property(nonatomic, weak) AVCaptureSession *wSession;
@property(nonatomic, weak) AVCaptureVideoDataOutput *wOutput;
@property(nonatomic, weak) AVCaptureConnection *wConnect;

@end

@implementation DVVideoCamera


- (AVCaptureSessionPreset)sessionPreset {
    return self.wSession.sessionPreset;
}

- (void)setSessionPreset:(AVCaptureSessionPreset)sessionPreset {

    NSInteger index = 0;
    AVCaptureSessionPreset currPresent;
    
    if ([sessionPreset isEqualToString:AVCaptureSessionPreset3840x2160]) {
        index = 1;
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        index = 2;
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
        index = 3;
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPresetiFrame960x540]) {
        index = 4;
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPreset640x480]) {
        index = 5;
    }
    
    while (1) {
        switch (index) {
            case 1:
                currPresent = AVCaptureSessionPreset3840x2160;
                break;
            case 2:
                currPresent = AVCaptureSessionPreset1920x1080;
                break;
            case 3:
                currPresent = AVCaptureSessionPreset1280x720;
                break;
            case 4:
                currPresent = AVCaptureSessionPresetiFrame960x540;
                break;
            case 5:
                currPresent = AVCaptureSessionPreset640x480;
                break;
            default:
                NSLog(@"[DVVideoCamera ERROR]: 设置分辨率失败");
                return;
                break;
        }
        
        
        if ([self.wSession canSetSessionPreset:currPresent]) {
            NSLog(@"[DVVideoCamera LOG]: 设置分辨率 -> %@",currPresent);
            [self.wSession beginConfiguration];
            [self.wSession setSessionPreset:currPresent];
            [self.wSession commitConfiguration];
            return;
        }
        index += 1;
    }
}

- (AVCaptureDevicePosition)position {
    return self.wDevice.position;
}

- (AVCaptureVideoOrientation)orientation {
    return self.wConnect.videoOrientation;
}

- (void)setOrientation:(AVCaptureVideoOrientation)orientation {
    self.wConnect.videoOrientation = orientation;
}

- (NSUInteger)fps {
    return (NSUInteger)(self.wDevice.activeVideoMaxFrameDuration.timescale
                        / self.wDevice.activeVideoMaxFrameDuration.value);
}

- (void)setFps:(NSUInteger)fps {
    AVFrameRateRange *range = self.wDevice.activeFormat.videoSupportedFrameRateRanges[0];
    if (fps < range.minFrameRate || fps > range.maxFrameRate) {
        NSLog(@"[DVVideoCamera ERROR]: 帧率设置错误:%lu, 有效帧率范围是 [%f %f]",
              (unsigned long)fps,
              range.minFrameRate,
              range.maxFrameRate);
        return;
    }
    
    self.wDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)fps);
    self.wDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)fps);
}

- (BOOL)alwaysDiscardsLateVideoFrames {
    return self.wOutput.alwaysDiscardsLateVideoFrames;
}

- (void)setAlwaysDiscardsLateVideoFrames:(BOOL)alwaysDiscardsLateVideoFrames {
    self.wOutput.alwaysDiscardsLateVideoFrames = alwaysDiscardsLateVideoFrames;
}

- (BOOL)mirror {
    return self.wConnect.videoMirrored;
}

- (void)setMirror:(BOOL)mirror {
    if ([self.wConnect isVideoMirroringSupported]) {
        self.wConnect.videoMirrored = mirror;
    }
}

- (AVCaptureVideoStabilizationMode)stabilizationMode {
    return self.wConnect.activeVideoStabilizationMode;
}

- (void)setStabilizationMode:(AVCaptureVideoStabilizationMode)stabilizationMode {
    if ([self.wConnect isVideoStabilizationSupported]) {
        self.wConnect.preferredVideoStabilizationMode = stabilizationMode;
    }
}

- (AVCaptureFlashMode)flashMode {
    return self.wDevice.flashMode;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    if (self.wDevice.hasFlash
        && self.wDevice.flashAvailable
        && [self.wDevice isFlashModeSupported:flashMode]) {
        self.wDevice.flashMode = flashMode;
    }
}

- (AVCaptureTorchMode)torchMode {
    return self.wDevice.torchMode;
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    if (self.wDevice.hasTorch
        && self.wDevice.torchAvailable
        && [self.wDevice isTorchModeSupported:torchMode]) {
        self.wDevice.torchMode = torchMode;
    }
}

- (AVCaptureFocusMode)focusMode {
    return self.wDevice.focusMode;
}

- (void)setFocusMode:(AVCaptureFocusMode)focusMode {
    self.wDevice.focusMode = focusMode;
}

- (AVCaptureWhiteBalanceMode)whiteBalanceMode {
    return self.wDevice.whiteBalanceMode;
}

- (void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode {
    self.wDevice.whiteBalanceMode = whiteBalanceMode;
}

- (CGFloat)videoZoomFactor {
    return self.wDevice.videoZoomFactor;
}

- (void)setVideoZoomFactor:(CGFloat)videoZoomFactor {
    self.wDevice.videoZoomFactor = videoZoomFactor;
}

@end
