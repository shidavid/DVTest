//
//  DVNoticeLoadingView.h
//  MM
//
//  Created by DV on 2016/9/9.
//  Copyright © 2016 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVNoticeLoadingView : UIView

@property(nonatomic, copy, nullable) void(^completeBlock)(void);
@property(nonatomic, assign) NSTimeInterval duration;

- (instancetype)initWithFrame:(CGRect)frame
                     duration:(NSTimeInterval)duration
                     complete:(void(^_Nullable)(void))completeBlock;

- (void)present;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
