//
//  DVNoticeAlertView.h
//  MM
//
//  Created by DV on 2016/9/9.
//  Copyright © 2016 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVNoticeAlertView : UIView

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *content;

@property(nonatomic, copy) void(^confirmBlock)(void);
@property(nonatomic, copy) void(^cancelBlock)(void);


- (instancetype)initWithTitle:(NSString *)title
                      content:(NSString *)content
                      confirm:(void(^)(void))confirmBlock
                       cancel:(void(^)(void))cancelBlock;

- (void)present;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
