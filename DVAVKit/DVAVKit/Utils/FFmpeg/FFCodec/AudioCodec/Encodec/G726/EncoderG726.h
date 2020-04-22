//
//  EncoderG726.h
//  TalkDemo_G711_AAC
//
//  Created by DV on 2018/11/6.
//  Copyright © 2018年 aipu. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface EncoderG726 : NSObject

- (instancetype)init;

- (NSData*)encoder:(NSData*)pcm;

- (NSData *)encoder:(uint8_t *)data size:(int)size;

@end

NS_ASSUME_NONNULL_END
