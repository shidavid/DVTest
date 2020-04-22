//
//  NSMutableDictionary+DVAMF.h
//  iOS_Test
//
//  Created by DV on 2019/10/25.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVAMF.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (DVAMF) <DVAMF>

- (void)setAMFObject:(id<DVAMF>)anObject forAMFKey:(NSString<DVAMF> *)aKey;

@end

NS_ASSUME_NONNULL_END
