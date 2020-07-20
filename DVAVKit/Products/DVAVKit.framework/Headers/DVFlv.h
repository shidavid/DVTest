//
//  DVFlv.h
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVFlvTag.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVFlv : NSObject

- (void)addTag:(DVFlvTag *)flvTag;

@end

NS_ASSUME_NONNULL_END
