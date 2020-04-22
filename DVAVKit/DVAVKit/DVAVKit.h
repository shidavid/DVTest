//
//  DVAVKit.h
//  DVAVKit
//
//  Created by DV on 2019/1/6.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import <Foundation/Foundation.h>


#if __has_include(<DVAVKit/DVAVKit.h>)
FOUNDATION_EXPORT double DVAVKitVersionNumber;
FOUNDATION_EXPORT const unsigned char DVAVKitVersionString[];

#import <DVAVKit/DVFFmpegKit.h>
#import <DVAVKit/DVVideoToolKit.h>
#import <DVAVKit/DVAudioToolKit.h>
#import <DVAVKit/DVFlvKit.h>
#import <DVAVKit/DVRtmpKit.h>
#import <DVAVKit/DVLiveKit.h>
#import <DVAVKit/DVOpenGLKit.h>
#import <DVAVKit/DVGLKits.h>

#else

#import "DVFFmpegKit.h"
#import "DVVideoToolKit.h"
#import "DVAudioToolKit.h"
#import "DVFlvKit.h"
#import "DVRtmpKit.h"
#import "DVLiveKit.h"
#import "DVOpenGLKit.h"
#import "DVGLKits.h"

#endif
