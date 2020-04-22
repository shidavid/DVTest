//
//  DVNotice.h
//  MM
//
//  Created by DV on 2016/9/9.
//  Copyright © 2016 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVNotice : NSObject

#pragma mark - <-------------------- MessageView -------------------->
+ (void)presentMessageToRootView:(NSString *)message type:(DVNoticeMessageType)type;
+ (void)presentMessageToRootViewForSuccess:(NSString *)message;
+ (void)presentMessageToRootViewForInfo:(NSString *)message;
+ (void)presentMessageToRootViewForWarn:(NSString *)message;
+ (void)presentMessageToRootViewForError:(NSString *)message;


#pragma mark - <-------------------- AlertView -------------------->
+ (void)presentAlertToRootView:(NSString *)title
                       content:(NSString *)content
                       confirm:(void(^_Nullable)(void))confirmBlock
                        cancel:(void(^_Nullable)(void))cancelBlock;
+ (void)dismissAlertToRootView;

#pragma mark - <-------------------- LoadingView -------------------->
+ (void)presentLoadingToRootView:(NSTimeInterval)duration complete:(void(^_Nullable)(void))completeBlock;
+ (void)dismissLoadingToRootView;

@end

NS_ASSUME_NONNULL_END
