//
//  LiveViewController.h
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/4/10.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveViewController : UIViewController

@property(nonatomic, copy) NSString *url;

@property(nonatomic, strong) UIBarButtonItem *barBtn;

@property(nonatomic, strong) UIButton *btnChangeCamera;
- (void)initBtnChangeCamera;
- (void)onClickForChangeCamera:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
