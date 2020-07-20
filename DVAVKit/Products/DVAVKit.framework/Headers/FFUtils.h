//
//  FFUtils.h
//  DVAVKit
//
//  Created by 施达威 on 2019/3/30.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFInFormatContext.h"
#import "FFOutFormatContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface FFUtils : NSObject

+ (int)convertCodecparFromInFmtCtx:(FFInFormatContext *)inFmtCtx
                       toOutFmtCtx:(FFOutFormatContext *)outFmtCtx;

+ (void)convertTimeBaseWithPacket:(FFPacket *)packet
                     fromInFmtCtx:(FFInFormatContext *)inFmtCtx
                      toOutFmtCtx:(FFOutFormatContext *)outFmtCtx;

+ (NSArray<NSData *> *)analyH264SpsPpsWithExtradata:(const uint8_t *)extradata size:(int)size;

+ (NSArray<NSData *> *)analyHEVCVpsSpsPpsWithExtradata:(const uint8_t *)extradata size:(int)size;

@end

NS_ASSUME_NONNULL_END
