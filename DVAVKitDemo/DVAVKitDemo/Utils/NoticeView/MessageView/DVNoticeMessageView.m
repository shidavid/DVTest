//
//  DVNoticeMessageView.m
//  MM
//
//  Created by DV on 2016/9/9.
//  Copyright © 2016 iOS. All rights reserved.
//

#import "DVNoticeMessageView.h"


@interface DVNoticeMessageView ()

@property(nonatomic, strong) UIView *mainView;
@property(nonatomic, strong) UIImageView *imgView;
@property(nonatomic, strong) UILabel *lblMessage;

@end

@implementation DVNoticeMessageView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithMessage:(NSString *)message type:(DVNoticeMessageType)type {
    self = [self init];
    if (self) {
        self.type = type;
        self.message = message;
    }
    return self;
}


#pragma mark - <-- Init -->
- (void)initViews {
    self.mainView = ({
        UIView *v = [[UIView alloc] init];
        v.layer.cornerRadius = 8;
        v.layer.borderWidth = 0.5;
        v;
    });
    
    self.imgView = [[UIImageView alloc] init];
    
    self.lblMessage = ({
        UILabel *lbl = [[UILabel alloc] init];
        lbl.numberOfLines = 0;
        lbl.fontSize = 18;
        lbl;
    });
    
    [self.mainView addSubview:self.imgView];
    [self.mainView addSubview:self.lblMessage];
    [self addSubview:self.mainView];
}

- (void)updateType:(DVNoticeMessageType)type {
    UIImage *img = nil;
    UIColor *textColor = nil;
    UIColor *backColor = nil;
    
    switch (type) {
        case DVNoticeMessageType_Success:
            img = [UIImage imageNamed:@"icon_message_success"];
            textColor = [UIColor Green];
            backColor = [UIColor Green2];
            break;
        case DVNoticeMessageType_Info:
            img = [UIImage imageNamed:@"icon_message_info"];
            textColor = [UIColor Gray];
            backColor = [UIColor Gray2];
            break;
        case DVNoticeMessageType_Warn:
            img = [UIImage imageNamed:@"icon_message_warn"];
            textColor = [UIColor Orange];
            backColor = [UIColor Orange2];
            break;
        case DVNoticeMessageType_Error:
            img = [UIImage imageNamed:@"icon_message_error"];
            textColor = [UIColor Red];
            backColor = [UIColor Red2];
            break;
        default:
            textColor = [UIColor blackColor];
            backColor = [UIColor whiteColor];
            break;
    }
    
    self.imgView.image = img;
    self.lblMessage.textColor = textColor;
    self.mainView.backgroundColor = backColor;
    self.mainView.layer.borderColor = textColor.CGColor;
}

- (void)updateLayout {

    CGFloat W = DVFrame.width;
    CGFloat H = 0;
    
    CGFloat iphoneXM = DVInfo.isPhoneX_All ? 20 : 0;
    
    CGFloat mLRM = 10;
    CGFloat mTBM = 20;
    CGFloat mX = mLRM;
    CGFloat mY = mTBM + iphoneXM;
    CGFloat mW = W - mLRM * 2;
    CGFloat mH = 0;
 
    
    CGFloat iLRM = 12;
    CGFloat lRM = 12;
    CGFloat lTBM = 14;
    
    CGFloat iW = 24;
    CGFloat iH = iW;
    CGFloat iX = iLRM;
    CGFloat iY = 0;
    
    CGFloat lW = mW - iW - iLRM * 2 - lRM;
    CGFloat lH = [self.lblMessage heightFromFitWidth:lW] + lTBM * 2;
    CGFloat lX = iW + iLRM * 2;
    CGFloat lY = 0;

    mH = lH;
    iY = (mH - iH) / 2;
    H = mH + mTBM + iphoneXM;
    
    self.imgView.frame = CGRectMake(iX, iY, iW, iH);
    self.lblMessage.frame = CGRectMake(lX, lY, lW, lH);
    self.mainView.frame = CGRectMake(mX, mY, mW, mH);
    self.frame = CGRectMake(0, 0, W, H);
}



#pragma mark - <-- Property -->
- (void)setType:(DVNoticeMessageType)type {
    _type = type;
    [self updateType:type];
}

- (void)setMessage:(NSString *)message {
    _message = message;
    self.lblMessage.text = message;
    [self updateLayout];
}



#pragma mark - <-- Method -->
- (void)present {
    CGRect vFrame = self.frame;
    vFrame.origin.y = -vFrame.size.height;
    self.frame = vFrame;
    vFrame.origin.y = 0;
    
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        weakSelf.frame = vFrame;
    } completion:^(BOOL finished) {
        [weakSelf dismiss];
    }];
}

- (void)dismiss {
    CGRect vFrame = self.frame;
    vFrame.origin.y = -vFrame.size.height;
    
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.4
                          delay:1
         usingSpringWithDamping:0.7
          initialSpringVelocity:1
                        options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        weakSelf.frame = vFrame;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

@end
