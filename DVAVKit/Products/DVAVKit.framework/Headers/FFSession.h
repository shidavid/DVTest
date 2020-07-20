//
//  FFSession.h
//  DVAVKit
//
//  Created by DV on 2019/3/31.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFSession : NSObject

+ (void)enableSession;

+ (void)enableNetWork;
+ (void)disableNetWork;

@end

NS_ASSUME_NONNULL_END
