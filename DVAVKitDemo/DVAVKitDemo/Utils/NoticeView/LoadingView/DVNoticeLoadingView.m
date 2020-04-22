//
//  DVNoticeLoadingView.m
//  MM
//
//  Created by DV on 2016/9/9.
//  Copyright © 2016 iOS. All rights reserved.
//

#import "DVNoticeLoadingView.h"
#import "CALayer+DVNotice.h"

@interface DVNoticeLoadingView () <CAAnimationDelegate>

@property(nonatomic, strong) UIView *mainView;
@property(nonatomic, strong) UIVisualEffectView *ballContainer;
@property(nonatomic, strong) UIView *ball1;
@property(nonatomic, strong) UIView *ball2;
@property(nonatomic, strong) UIView *ball3;
@property(nonatomic, assign) BOOL stopAnimationByUser;


@end

@implementation DVNoticeLoadingView

- (instancetype)initWithFrame:(CGRect)frame duration:(NSTimeInterval)duration complete:(void (^)(void))completeBlock {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        self.duration = duration;
        self.completeBlock = completeBlock;
        [self initViews];
        [self initPathAnimate];
    }
    return self;
}

- (void)dealloc {
    
}

- (void)initViews {
    __weak __typeof(self)weakSelf = self;
    
    self.mainView = ({
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = [UIColor whiteColor];
        v.frame = CGRectMake(0, 0, 120, 120);
        v.center = CGPointMake(weakSelf.bounds.size.width/2.0f, weakSelf.bounds.size.height/2.0f);
        v.layer.cornerRadius = 20.0f;
        v.layer.masksToBounds = true;
        v;
    });
    
    self.ballContainer = ({
        UIVisualEffectView *v = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        v.frame = CGRectMake(0, 0, 70, 70);
        v.center = CGPointMake(weakSelf.bounds.size.width/2.0f, weakSelf.bounds.size.height/2.0f);
        v;
    });
    

    CGFloat ballWidth = 14.0f;
    CGFloat margin = 3.0f;
    
    self.ball1 = ({
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ballWidth, ballWidth)];
        v.center = CGPointMake(ballWidth/2.0f + margin, weakSelf.ballContainer.height/2.0f);
        v.layer.cornerRadius = ballWidth/2.0f;
        v.backgroundColor = [UIColor colorWithRed:54/255.0 green:136/255.0 blue:250/255.0 alpha:1];
        v;
    });
    
    self.ball2 = ({
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ballWidth, ballWidth)];
        v.center = CGPointMake(weakSelf.ballContainer.width/2.0f, weakSelf.ballContainer.height/2.0f);
        v.layer.cornerRadius = ballWidth/2.0f;
        v.backgroundColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1];
        v;
    });
    
    self.ball3 = ({
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ballWidth, ballWidth)];
        v.center = CGPointMake(weakSelf.ballContainer.width - ballWidth/2.0f - margin, weakSelf.ballContainer.height/2.0f);
        v.layer.cornerRadius = ballWidth/2.0f;
        v.backgroundColor = [UIColor colorWithRed:234/255.0 green:67/255.0 blue:69/255.0 alpha:1];
        v;
    });
    
    
    [self.ballContainer.contentView addSubview:self.ball1];
    [self.ballContainer.contentView addSubview:self.ball2];
    [self.ballContainer.contentView addSubview:self.ball3];
    [self addSubview:self.mainView];
    [self addSubview:self.ballContainer];
}

- (void)initPathAnimate {
    
    //-------第一个球的动画
    CGFloat width = _ballContainer.bounds.size.width;
    //小圆半径
    CGFloat r = (_ball1.bounds.size.width)*self.ballScale/2.0f;
    //大圆半径
    CGFloat R = (width/2 + r)/2.0;
    
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [path1 moveToPoint:self.ball1.center];
    //画大圆
    [path1 addArcWithCenter:CGPointMake(R + r, width/2) radius:R startAngle:M_PI endAngle:M_PI*2 clockwise:NO];
    //画小圆
    UIBezierPath *path1_1 = [UIBezierPath bezierPath];
    [path1_1 addArcWithCenter:CGPointMake(width/2, width/2) radius:r*2 startAngle:M_PI*2 endAngle:M_PI clockwise:NO];
    [path1 appendPath:path1_1];
    //回到原处
    [path1 addLineToPoint:self.ball1.center];
    //执行动画
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation1.path = path1.CGPath;
    animation1.removedOnCompletion = YES;
    animation1.duration = [self animationDuration];
    animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.ball1.layer addAnimation:animation1 forKey:@"animation1"];
    
    
    //-------第三个球的动画
    UIBezierPath *path3 = [UIBezierPath bezierPath];
    [path3 moveToPoint:self.ball3.center];
    //画大圆
    [path3 addArcWithCenter:CGPointMake(width - (R + r), width/2) radius:R startAngle:2*M_PI endAngle:M_PI clockwise:NO];
    //画小圆
    UIBezierPath *path3_1 = [UIBezierPath bezierPath];
    [path3_1 addArcWithCenter:CGPointMake(width/2, width/2) radius:r*2 startAngle:M_PI endAngle:M_PI*2 clockwise:NO];
    [path3 appendPath:path3_1];
    //回到原处
    [path3 addLineToPoint:self.ball3.center];
    //执行动画
    CAKeyframeAnimation *animation3 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation3.path = path3.CGPath;
    animation3.removedOnCompletion = YES;
    animation3.duration = [self animationDuration];
    animation3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation3.delegate = self;
    [self.ball3.layer addAnimation:animation3 forKey:@"animation3"];
}

//放大缩小动画
- (void)animationDidStart:(CAAnimation *)anim {
    
    CGFloat delay = 0.3f;
    CGFloat duration = [self animationDuration]/2 - delay;
    
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseOut| UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.ball1.transform = CGAffineTransformMakeScale(self.ballScale, self.ballScale);
        self.ball2.transform = CGAffineTransformMakeScale(self.ballScale, self.ballScale);
        self.ball3.transform = CGAffineTransformMakeScale(self.ballScale, self.ballScale);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut| UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.ball1.transform = CGAffineTransformIdentity;
            self.ball2.transform = CGAffineTransformIdentity;
            self.ball3.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (_stopAnimationByUser) {return;}
    [self initPathAnimate];
}


#pragma mark - <-- Property -->
- (CGFloat)ballScale {
    return 1.5f;
}

- (CGFloat)animationDuration {
    return 1.6f;
}


#pragma mark - <-- Method -->
- (void)start {
    [self.ball1.layer dv_beginAnimation];
    [self.ball2.layer dv_beginAnimation];
    [self.ball3.layer dv_beginAnimation];
}

- (void)pause {
    [self.ball1.layer dv_beginAnimation];
    [self.ball2.layer dv_beginAnimation];
    [self.ball3.layer dv_beginAnimation];
}

- (void)stop {
    [self.ball1.layer removeAllAnimations];
    [self.ball2.layer removeAllAnimations];
    [self.ball3.layer removeAllAnimations];
    [self removeFromSuperview];
    
    self.ball1 = nil;
    self.ball2 = nil;
    self.ball3 = nil;
    self.ballContainer = nil;
}

- (void)present {
    [self start];
    
    if (self.duration > 0) {
        __weak __typeof(self)weakSelf = self;
        [[DVGCD mainQueue] delay:self.duration block:^{
            [weakSelf dismiss];
        }];
    }
}

- (void)dismiss {
    if (self.completeBlock) {
        self.completeBlock();
        _completeBlock = nil;
    }
    [self pause];
    [self stop];
}

@end
