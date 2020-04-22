//
//  DVAudioPacket.h
//  DVAVKit
//
//  Created by DV on 2019/4/7.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVAudioPacket : NSObject {
    @public
    void *_userInfo;
}

@property(nonatomic, assign) UInt32 mSize;
@property(nonatomic, assign) UInt32 readIndex;
@property(nonatomic, assign) uint8_t *mData;

- (instancetype)initWithData:(uint8_t *)mData size:(UInt32)mSize;

@end

NS_ASSUME_NONNULL_END
