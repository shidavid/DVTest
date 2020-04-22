//
//  DVAudioIOUnit.h
//  iOS_Test
//
//  Created by DV on 2019/1/11.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVAudioStreamBaseDesc.h"
#import "DVAudioPacket.h"


NS_ASSUME_NONNULL_BEGIN

@interface DVAudioIOUnit : NSObject

#pragma mark - <-- Property -->
/// 音频格式  默认: 空 (可调用 DVAudioConfig 转换为 DVAudioStreamBaseDesc)
@property(nonatomic, assign) AudioStreamBasicDescription audioFormat;

/// 麦克风状态 默认:关闭 NO
@property(nonatomic, assign) BOOL inputPortStatus;

/// 扬声器状态 默认:关闭 NO
@property(nonatomic, assign) BOOL outputPortStatus;

/// 麦克风数据回调开关 默认:关闭 NO
@property(nonatomic, assign) BOOL inputCallBackSwitch;

/// 扬声器数据回调开关 默认:关闭 NO
@property(nonatomic, assign) BOOL outputCallBackSwitch;

/// 麦克风数据反馈回扬声器, 默认: 关闭 NO ('outputPortStatus'=YES 和 'outputCallBackSwitch'=YES 才能使用)
@property(nonatomic, assign) BOOL feedbackSwitch;

/// 回声消除开关 默认:开启 YES (必须设置 'outputPortStatus'=YES 和 'kComponentDesc_Output_VPIO' 才能使用与设置)
@property(nonatomic, assign) BOOL bypassVoiceProcessingStatus;

/// 麦克风数据回调 自动分配缓存 默认:开启 YES
@property(nonatomic, assign) BOOL shouldAllocateBufferStatus;


#pragma mark - <-- Method -->
- (void)playAudioData:(uint8_t *)data size:(UInt32)size;

@end

NS_ASSUME_NONNULL_END
