//
//  DVNotice.m
//  MM
//
//  Created by DV on 2016/9/9.
//  Copyright © 2016 iOS. All rights reserved.
//

#import "DVNotice.h"
#import "DVNoticeAlertView.h"
#import "DVNoticeMessageView.h"
#import "DVNoticeLoadingView.h"

@interface DVNotice ()

@property(nonatomic, weak) DVNoticeMessageView *lastMessageView;
@property(nonatomic, weak) DVNoticeAlertView *lastAlertView;
@property(nonatomic, weak) DVNoticeLoadingView *lastLoadingView;

@end

@implementation DVNotice

#pragma mark - <-- SharedInstance -->
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DVNotice *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    self = [super init];
    if (self) {
       
    }
    return self;
}


#pragma mark - <-------------------- MessageView -------------------->
+ (void)presentMessageToRootView:(NSString *)message type:(DVNoticeMessageType)type {
    
    DVNotice *notice = [DVNotice sharedInstance];
    if (notice.lastMessageView
        && [notice.lastMessageView.message isEqualToString:message]
        && notice.lastMessageView.type == type) {
        return;
    }
    
    DVNoticeMessageView *messageView = [[DVNoticeMessageView alloc] initWithMessage:message type:type];
    notice.lastMessageView = messageView;
    
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    [rootView addSubview:messageView];
    
    [messageView present];
}

+ (void)presentMessageToRootViewForSuccess:(NSString *)message {
    [self presentMessageToRootView:message type:DVNoticeMessageType_Success];
}

+ (void)presentMessageToRootViewForInfo:(NSString *)message {
    [self presentMessageToRootView:message type:DVNoticeMessageType_Info];
}

+ (void)presentMessageToRootViewForWarn:(NSString *)message {
    [self presentMessageToRootView:message type:DVNoticeMessageType_Warn];
}

+ (void)presentMessageToRootViewForError:(NSString *)message {
    [self presentMessageToRootView:message type:DVNoticeMessageType_Error];
}


#pragma mark - <-------------------- AlertView -------------------->
+ (void)presentAlertToRootView:(NSString *)title
                       content:(NSString *)content
                       confirm:(void (^)(void))confirmBlock
                        cancel:(void (^)(void))cancelBlock {
    
    DVNotice *notice = [DVNotice sharedInstance];
    if (notice.lastAlertView) {
        return;
    }
    
    DVNoticeAlertView *alertView = [[DVNoticeAlertView alloc] initWithTitle:title
                                                                      content:content
                                                                      confirm:confirmBlock
                                                                       cancel:cancelBlock];
    notice.lastAlertView = alertView;
    
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    [rootView addSubview:alertView];
    
    [alertView present];
}

+ (void)dismissAlertToRootView {
    DVNotice *notice = [DVNotice sharedInstance];
    if (notice.lastAlertView) {
        [notice.lastAlertView dismiss];
        notice.lastAlertView = nil;
    }
}


#pragma mark - <-------------------- LoadingView -------------------->
+ (void)presentLoadingToRootView:(NSTimeInterval)duration complete:(void (^)(void))completeBlock {
 
    DVNotice *notice = [DVNotice sharedInstance];
    if (notice.lastLoadingView) {
        return;
    }
    
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    
    DVNoticeLoadingView *loadingView = [[DVNoticeLoadingView alloc] initWithFrame:rootView.bounds
                                                                         duration:duration
                                                                         complete:completeBlock];
    notice.lastLoadingView = loadingView;
    [rootView addSubview:loadingView];
    
    [loadingView present];
}

+ (void)dismissLoadingToRootView {
    DVNotice *notice = [DVNotice sharedInstance];
    if (notice.lastLoadingView) {
        [notice.lastLoadingView dismiss];
        notice.lastLoadingView = nil;
    }
}

@end
