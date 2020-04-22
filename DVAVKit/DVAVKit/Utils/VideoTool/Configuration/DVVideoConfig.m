//
//  DVVideoConfig.m
//  iOS_Test
//
//  Created by DV on 2019/9/27.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVVideoConfig.h"

@interface DVVideoConfig ()



@end


@implementation DVVideoConfig

#pragma mark - <-- Initializer -->
- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionPreset = AVCaptureSessionPreset1280x720;
        self.position = AVCaptureDevicePositionBack;
        self.orientation = AVCaptureVideoOrientationPortrait;
        self.fps = 24;
        self.gop = self.fps * 2;
        self.bitRate = 1200 * 1024;
        self.isEnableBFrame = NO;
        self.minBitRate = 600 * 1024;
        self.maxBitRate = 1800 * 1024;
        self.encoderType = DVVideoEncoderType_H264_Hardware;
        self.decoderType = DVVideoDecoderType_H264_Hardware;
    }
    return self;
}


#pragma mark - <-- Property -->
- (BOOL)isLandscape {
    return (self.orientation == AVCaptureVideoOrientationLandscapeLeft
            || self.orientation == AVCaptureVideoOrientationLandscapeRight) ? YES : NO;
}

- (CGSize)size {
    CGFloat width = 0;
    CGFloat height = 0;
    
    if ([self.sessionPreset isEqualToString:AVCaptureSessionPreset640x480]) {
        width = self.isLandscape ? 640 : 480;
        height = self.isLandscape ? 480 : 640;
    }
    else if ([self.sessionPreset isEqualToString:AVCaptureSessionPresetiFrame960x540]) {
        width = self.isLandscape ? 960 : 540;
        height = self.isLandscape ? 540 : 960;
    }
    else if ([self.sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
        width = self.isLandscape ? 1280 : 720;
        height = self.isLandscape ? 720 : 1280;
    }
    else if ([self.sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        width = self.isLandscape ? 1920 : 1080;
        height = self.isLandscape ? 1080 : 1920;
    }
    else if ([self.sessionPreset isEqualToString:AVCaptureSessionPreset3840x2160]) {
        width = self.isLandscape ? 3840 : 2160;
        height = self.isLandscape ? 2160 : 3840;
    }
  
    return CGSizeMake(width, height);
}



#pragma mark - <-- Default 480P -->
+ (DVVideoConfig *)kConfig_480P_15fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset640x480;
    config.fps = 15;
    config.gop = config.fps * 2;
    config.bitRate = 500 * 1024;
    config.minBitRate = 250 * 1024;
    config.maxBitRate = 750 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_480P_24fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset640x480;
    config.fps = 24;
    config.gop = config.fps * 2;
    config.bitRate = 600 * 1024;
    config.minBitRate = 300 * 1024;
    config.maxBitRate = 900 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_480P_30fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset640x480;
    config.fps = 30;
    config.gop = config.fps * 2;
    config.bitRate = 800 * 1024;
    config.minBitRate = 400 * 1024;
    config.maxBitRate = 1200 * 1024;
    return config;
}


#pragma mark - <-- Default 540P -->
+ (DVVideoConfig *)kConfig_540P_15fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPresetiFrame960x540;
    config.fps = 15;
    config.gop = config.fps * 2;
    config.bitRate = 800 * 1024;
    config.minBitRate = 400 * 1024;
    config.maxBitRate = 1200 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_540P_24fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPresetiFrame960x540;
    config.fps = 24;
    config.gop = config.fps * 2;
    config.bitRate = 900 * 1024;
    config.minBitRate = 450 * 1024;
    config.maxBitRate = 1350 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_540P_30fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPresetiFrame960x540;
    config.fps = 30;
    config.gop = config.fps * 2;
    config.bitRate = 1000 * 1024;
    config.minBitRate = 500 * 1024;
    config.maxBitRate = 1500 * 1024;
    return config;
}


#pragma mark - <-- Default 720P -->
+ (DVVideoConfig *)kConfig_720P_15fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset1280x720;
    config.fps = 15;
    config.gop = config.fps * 2;
    config.bitRate = 1000 * 1024;
    config.minBitRate = 500 * 1024;
    config.maxBitRate = 1500 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_720P_24fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset1280x720;
    config.fps = 24;
    config.gop = config.fps * 2;
    config.bitRate = 1100 * 1024;
    config.minBitRate = 550 * 1024;
    config.maxBitRate = 1650 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_720P_30fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset1280x720;
    config.fps = 30;
    config.gop = config.fps * 2;
    config.bitRate = 1200 * 1024;
    config.minBitRate = 600 * 1024;
    config.maxBitRate = 1800 * 1024;
    return config;
}


#pragma mark - <-- Default 1080P -->
+ (DVVideoConfig *)kConfig_1080P_15fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset1920x1080;
    config.fps = 15;
    config.gop = config.fps * 2;
    config.bitRate = 1200 * 1024;
    config.minBitRate = 600 * 1024;
    config.maxBitRate = 1800 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_1080P_24fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset1920x1080;
    config.fps = 24;
    config.gop = config.fps * 2;
    config.bitRate = 1300 * 1024;
    config.minBitRate = 650 * 1024;
    config.maxBitRate = 1950 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_1080P_30fps_2M {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset1920x1080;
    config.fps = 30;
    config.gop = config.fps * 2;
    config.bitRate = 2000 * 1024;
    config.minBitRate = 1000 * 1024;
    config.maxBitRate = 3000 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_1080P_30fps_4M {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset1920x1080;
    config.fps = 30;
    config.gop = config.fps * 2;
    config.bitRate = 4000 * 1024;
    config.minBitRate = 2000 * 1024;
    config.maxBitRate = 6000 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_1080P_60fps_10M {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset1920x1080;
    config.fps = 60;
    config.gop = config.fps * 2;
    config.bitRate = 10000 * 1024;
    config.minBitRate = 5000 * 1024;
    config.maxBitRate = 15000 * 1024;
    return config;
}


#pragma mark - <-- Default 4K -->
+ (DVVideoConfig *)kConfig_4K_15fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset3840x2160;
    config.fps = 15;
    config.gop = config.fps * 2;
    config.bitRate = 2400 * 1024;
    config.minBitRate = 1200 * 1024;
    config.maxBitRate = 3600 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_4K_24fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset3840x2160;
    config.fps = 24;
    config.gop = config.fps * 2;
    config.bitRate = 2500 * 1024;
    config.minBitRate = 1250 * 1024;
    config.maxBitRate = 3750 * 1024;
    return config;
}

+ (DVVideoConfig *)kConfig_4K_30fps {
    DVVideoConfig *config = [[DVVideoConfig alloc] init];
    config.sessionPreset = AVCaptureSessionPreset3840x2160;
    config.fps = 30;
    config.gop = config.fps * 2;
    config.bitRate = 3000 * 1024;
    config.minBitRate = 1500 * 1024;
    config.maxBitRate = 4500 * 1024;
    return config;
}

@end
