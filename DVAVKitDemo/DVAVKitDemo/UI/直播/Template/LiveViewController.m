//
//  LiveViewController.m
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/4/10.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import "LiveViewController.h"

@interface LiveViewController ()

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.barBtn = [[UIBarButtonItem alloc] initWithTitle:@"" style:(UIBarButtonItemStylePlain) target:nil action:nil];
    self.navigationItem.rightBarButtonItem = self.barBtn;
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


- (void)initBtnChangeCamera {
    self.btnChangeCamera = ({
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 20 - 100,
                                                                 self.view.height - 80,
                                                                 100,
                                                                 40)];
        b.title = @"翻转镜头";
        b.titleColor = [UIColor whiteColor];
        b.titleColorForHighlighted = [UIColor grayColor];
        [b addTarget:self action:@selector(onClickForChangeCamera:) forControlEvents:UIControlEventTouchUpInside];
        b;
    });
    [self.view addSubview:self.btnChangeCamera];
}

- (void)onClickForChangeCamera:(UIButton *)sender {
    
}

@end
