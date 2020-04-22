//
//  NSMutableArray+DVRtmpBuffer.h
//  iOS_Test
//
//  Created by DV on 2019/10/23.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray<ObjectType> (DVRtmpBuffer)

- (nullable ObjectType)popFirstBuffer;

@end

NS_ASSUME_NONNULL_END
