//
//  FFOutFormatContext+IO.h
//  DVAVKit
//
//  Created by DV on 2019/3/31.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "FFOutFormatContext.h"

NS_ASSUME_NONNULL_BEGIN


#pragma mark - <-------------------- Class -------------------->
@interface FFOutFormatContext (IO)

#pragma mark - <-- Initializer -->
+ (instancetype)IOWithBufferSize:(int)bufferSize;


#pragma mark - <-- Method -->
- (void)openIOWithFormat:(NSString *)format;
- (void)closeIO;

@end

NS_ASSUME_NONNULL_END
