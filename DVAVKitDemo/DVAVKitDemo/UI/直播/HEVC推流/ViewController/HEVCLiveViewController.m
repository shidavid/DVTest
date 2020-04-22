//
//  HEVCLiveViewController.m
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/4/10.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import "HEVCLiveViewController.h"

@interface HEVCLiveViewController () <DVLiveDelegate>

@property(nonatomic, strong) DVLive *live;

@end


@implementation HEVCLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self initLive];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.live startLive];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.live stopLive];
}


#pragma mark - <-- Init -->
- (void)initLive {
    
    DVVideoConfig *videoConfig = [DVVideoConfig kConfig_720P_24fps];
    videoConfig.position = AVCaptureDevicePositionFront;
    videoConfig.gop = videoConfig.fps;
    videoConfig.encoderType = DVVideoEncoderType_HEVC_Hardware;
    
    DVAudioConfig *audioConfig = [DVAudioConfig kConfig_44k_16bit_1ch];
    
    self.live = [[DVLive alloc] init];
    self.live.delegate = self;
    self.live.isEnableLog = YES;
    [self.live setVideoConfig:videoConfig];
    [self.live setAudioConfig:audioConfig];
    [self.live connectToURL:self.url];
    
    
    if (self.live.preView) {
        self.live.preView.frame = [DVFrame frame_full];
        [self.view insertSubview:self.live.preView atIndex:0];
    }
    
    [self initBtnChangeCamera];
}


#pragma mark - <-- ACTION -->
- (void)onClickForChangeCamera:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self.live.camera changeToBackCamera];
    } else {
        [self.live.camera changeToFrontCamera];
    }
}

#pragma mark - <-- Delegate -->
- (void)DVLive:(DVLive *)live status:(DVLiveStatus)status {
    switch (status) {
        case DVLiveStatus_Disconnected:
            self.barBtn.title = @"未连接";
            break;
        case DVLiveStatus_Connecting:
            self.barBtn.title = @"连接中";
            break;
        case DVLiveStatus_Connected:
            self.barBtn.title = @"已连接";
            break;
        case DVLiveStatus_Reconnecting:
            self.barBtn.title = @"重新连接中";
            break;
        default:
            break;
    }
}

@end
