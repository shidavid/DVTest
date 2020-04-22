//
//  DVNoticeMessageView.h
//  MM
//
//  Created by DV on 2016/9/9.
//  Copyright © 2016 iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVNoticeMessageView : UIView

@property(nonatomic, assign) DVNoticeMessageType type;
@property(nonatomic, copy) NSString *message;

- (instancetype)initWithMessage:(NSString *)message type:(DVNoticeMessageType)type;

- (void)present;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
