//
//  H264LivePlayerViewController.m
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/4/10.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import "H264HEVCLivePlayerViewController.h"

@interface H264HEVCLivePlayerViewController ()

@property(nonatomic, strong) DVLivePlayer *livePlayer;

@end

@implementation H264HEVCLivePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initLivePlayer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.livePlayer startPlay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.livePlayer stopPlay];
}


- (void)initLivePlayer {
    self.livePlayer = [[DVLivePlayer alloc] initWithPreViewFrame:DVFrame.frame_full];
    [self.livePlayer connectToURL:self.url];
    
    
    [self.view insertSubview:self.livePlayer.preView atIndex:0];
    [self initBtnRecord];
    [self initBtnScreenShot];
}


#pragma mark - <-- ACTION -->
- (void)onClickForRecord:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {

        [self.livePlayer startRecordToPhotoAlbumWithCompletion:^(BOOL finished) {
            if (finished) {
                [DVNotice presentMessageToRootViewForSuccess:@"录像成功,已保存到系统相册"];
            } else {
                [DVNotice presentMessageToRootViewForWarn:@"录像失败"];
            }
        }];
    }
    else {
        [self.livePlayer stopRecord];
    }
}

- (void)onClickForScreenShot:(UIButton *)sender {
    [self.livePlayer saveScreenshotToPhotoAlbumWithCompletion:^(BOOL finished) {
        if (finished) {
            [DVNotice presentMessageToRootViewForSuccess:@"截图成功,已保存至系统相册"];
        } else {
            [DVNotice presentMessageToRootViewForWarn:@"截图失败"];
        }
    }];
}

@end
