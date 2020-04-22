//
//  DVNoticeAlertView.m
//  MM
//
//  Created by DV on 2016/9/9.
//  Copyright © 2016 iOS. All rights reserved.
//

#import "DVNoticeAlertView.h"

@interface DVNoticeAlertView ()

@property(nonatomic, strong) UIView *mainView;
@property(nonatomic, strong) UILabel *lblTitle;
@property(nonatomic, strong) UILabel *lblContent;
@property(nonatomic, strong) UIButton *btnConfirm;
@property(nonatomic, strong) UIButton *btnCancel;

@end


@implementation DVNoticeAlertView

#pragma mark - <-- Instance -->
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        self.alpha = 0;
        [self initViews];
        [self loadData];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                      content:(NSString *)content
                      confirm:(void (^)(void))confirmBlock
                       cancel:(void (^)(void))cancelBlock {
    self = [self init];
    if (self) {
        self.title = title;
        self.content = content;
        self.confirmBlock = confirmBlock;
        self.cancelBlock = cancelBlock;
    }
    return self;
}

- (void)dealloc {
    _confirmBlock = nil;
    _cancelBlock = nil;
}

#pragma mark - <-- Init -->
- (void)initViews {
    self.mainView = ({
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = [UIColor whiteColor];
        v.layer.cornerRadius = 10;
        v.alpha = 0;
        v;
    });
    
    self.lblTitle = ({
        UILabel *lbl = [[UILabel alloc] init];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont boldSystemFontOfSize:18];
        lbl;
    });
    
    self.lblContent = ({
        UILabel *lbl = [[UILabel alloc] init];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.fontSize = 16;
        lbl.textColor = [UIColor Gray];
        lbl.numberOfLines = 0;
        lbl;
    });
    
    self.btnConfirm = ({
        UIButton *btn =[[UIButton alloc] init];
        btn.titleColor = [UIColor whiteColor];
        btn.titleLabel.fontSize = 18;
        [btn setBackgroundImage:[UIImage imageWithColor:[DVColor Blue] size:(CGSizeMake(1, 1))]
                       forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithColor:[DVColor Blue].darkColor size:(CGSizeMake(1, 1))]
                       forState:UIControlStateHighlighted];
        btn.layer.cornerRadius = 8;
        btn.layer.masksToBounds = YES;
        [btn addTarget:self action:@selector(onResponseForConfirm:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.btnCancel = ({
        UIButton *btn =[[UIButton alloc] init];
        btn.titleColor = [UIColor Gray];
        btn.titleLabel.fontSize = 18;
        [btn setBackgroundImage:[UIImage imageWithColor:[DVColor Gray1] size:CGSizeMake(1, 1)]
                       forState:UIControlStateHighlighted];
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor Gray].CGColor;
        btn.layer.cornerRadius = 8;
        btn.layer.masksToBounds = YES;
        [btn addTarget:self action:@selector(onResponseForCancel:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    
    [self.mainView addSubview:self.lblTitle];
    [self.mainView addSubview:self.lblContent];
    [self.mainView addSubview:self.btnConfirm];
    [self.mainView addSubview:self.btnCancel];
    [self addSubview:self.mainView];
    
}

- (void)loadData {
    self.btnConfirm.title = @"Confirm";
    self.btnCancel.title = @"Cancel";
}

- (void)updateLayout {
    CGFloat W = [DVFrame width];
    CGFloat H = [DVFrame height];
    
    CGFloat mW = 280;
    CGFloat mH = 0;
    CGFloat mX = (W - mW) / 2;
    CGFloat mY = 0;
    
    
    CGFloat ltX = 0;
    CGFloat ltY = 0;
    CGFloat ltW = mW;
    CGFloat ltH = 40;
    
    CGFloat lcLRM = 16;
    CGFloat lcTBM = 8;
    CGFloat lcX = lcLRM;
    CGFloat lcY = ltH;
    CGFloat lcW = mW - lcLRM * 2;
    CGFloat lcH = [self.lblContent heightFromFitWidth:lcW] + lcTBM * 2;
    
    CGFloat bLRM = 16;
    CGFloat bTBM = 10;
    CGFloat bMidM = 10;
    CGFloat bW = (mW - bLRM * 2 - bMidM) / 2;
    CGFloat bH = 50;
    CGFloat bY = lcY + lcH + bTBM;
    CGFloat b1X = bLRM;
    CGFloat b2X = bLRM + bW + bMidM;
    
    mH = bY + bH + bTBM;
    mY = (H - mH) / 2;
    
    self.mainView.frame = CGRectMake(mX, mY, mW, mH);
    self.lblTitle.frame = CGRectMake(ltX, ltY, ltW, ltH);
    self.lblContent.frame = CGRectMake(lcX, lcY, lcW, lcH);
    self.btnCancel.frame = CGRectMake(b1X, bY, bW, bH);
    self.btnConfirm.frame = CGRectMake(b2X, bY, bW, bH);
    self.frame = CGRectMake(0, 0, W, H);
}



#pragma mark - <-- Property -->
- (void)setTitle:(NSString *)title {
    _title = title;
    self.lblTitle.text = title;
}

- (void)setContent:(NSString *)content {
    _content = content;
    self.lblContent.text = content;
    [self updateLayout];
}



#pragma mark - <-- Method -->
- (void)present {
    CGRect vFrame = self.mainView.frame;
    vFrame.origin.y -= vFrame.size.height;
    self.mainView.frame = vFrame;
    vFrame.origin.y += vFrame.size.height;
    
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        weakSelf.mainView.frame = vFrame;
        weakSelf.mainView.alpha = 1;
        weakSelf.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss {
    CGRect vFrame = self.mainView.frame;
    vFrame.origin.y -= vFrame.size.height;
 
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        weakSelf.mainView.frame = vFrame;
        weakSelf.mainView.alpha = 0;
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - <-- Response -->
- (void)onResponseForConfirm:(UIButton *)sender {
    if (self.confirmBlock) {
        self.confirmBlock();
    }
    [self dismiss];
}

- (void)onResponseForCancel:(UIButton *)sender {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self dismiss];
}


@end
