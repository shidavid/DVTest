//
//  FFInFormatContext+IO.h
//  DVAVKit
//
//  Created by DV on 2019/3/31.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "FFInFormatContext.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Class -------------------->
@interface FFInFormatContext (IO)

#pragma mark - <-- Initializer -->
+ (instancetype)IOWithBufferSize:(int)bufferSize;


#pragma mark - <-- Method -->
- (void)openIO;
- (void)closeIO;

- (void)startReadIO;
- (void)stopReadIO;

@end

NS_ASSUME_NONNULL_END
