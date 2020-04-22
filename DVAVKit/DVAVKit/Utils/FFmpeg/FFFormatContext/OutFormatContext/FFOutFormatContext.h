//
//  FFOutFormatContext.h
//  DVAVKit
//
//  Created by 施达威 on 2019/3/30.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFInFormatContext.h"
#import "FFPacket.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Protocol -------------------->
@class FFOutFormatContext;
@protocol FFOutFormatContextDelegate <NSObject>
@optional

- (void)FFOutFormatContextDidFinishedOutput:(FFOutFormatContext *)context;

- (void)FFOutFormatContext:(FFOutFormatContext *)context outIOPacket:(FFPacket *)packet;

@end


#pragma mark - <-------------------- Class -------------------->
@interface FFOutFormatContext : NSObject

#pragma mark - <-- Property -->
@property(nonatomic, weak) id<FFOutFormatContextDelegate> delegate;
@property(nonatomic, assign, readonly) BOOL isOpening;
@property(nonatomic, copy, readonly) NSString *url;


#pragma mark - <-- Initializer -->
+ (instancetype)contextFromInFmtCtx:(FFInFormatContext *)inFmtCtx;


#pragma mark - <-- Method -->
- (void)openWithURL:(NSString *)url format:(nullable NSString *)format;
- (void)closeURL;

- (void)writePacket:(FFPacket *)packet;

@end

NS_ASSUME_NONNULL_END
