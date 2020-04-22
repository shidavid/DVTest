//
//  DVFlvTagData.h
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVFlvTagData <NSObject>

@property(nonatomic, strong, readonly) NSData *fullData;

@end

NS_ASSUME_NONNULL_END
