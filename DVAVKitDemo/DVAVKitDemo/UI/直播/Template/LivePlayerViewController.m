//
//  LivePlayerViewController.m
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/4/10.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import "LivePlayerViewController.h"

@interface LivePlayerViewController ()

@end

@implementation LivePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.isHiddenNavBar = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.isHiddenNavBar = NO;
}

- (void)initBtnRecord {
    self.btnRecord = ({
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 20 - 100,
                                                                 self.view.height - 80,
                                                                 100,
                                                                 40)];
        [b setTitle:@"录制" forState:UIControlStateNormal];
        [b setTitle:@"录制中.." forState:UIControlStateSelected];
        b.titleColor = [UIColor whiteColor];
        b.titleColorForHighlighted = [UIColor grayColor];
        [b addTarget:self action:@selector(onClickForRecord:) forControlEvents:UIControlEventTouchUpInside];
        b;
    });
    [self.view addSubview:self.btnRecord];
}

- (void)initBtnScreenShot {
    self.btnScreenShot = ({
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(20,
                                                                 self.view.height - 80,
                                                                 100,
                                                                 40)];
        [b setTitle:@"截图" forState:UIControlStateNormal];
        b.titleColor = [UIColor whiteColor];
        b.titleColorForHighlighted = [UIColor grayColor];
        [b addTarget:self action:@selector(onClickForScreenShot:) forControlEvents:UIControlEventTouchUpInside];
        b;
    });
    [self.view addSubview:self.btnScreenShot];
}

- (void)onClickForRecord:(UIButton *)sender {
    
}

- (void)onClickForScreenShot:(UIButton *)sender {
    
}

@end
