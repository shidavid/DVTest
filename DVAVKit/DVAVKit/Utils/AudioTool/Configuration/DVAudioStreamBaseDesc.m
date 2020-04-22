//
//  DVAudioStreamBaseDesc.m
//  iOS_Test
//
//  Created by DV on 2019/1/11.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import "DVAudioStreamBaseDesc.h"

@implementation DVAudioStreamBaseDesc

#pragma mark - <-- Initializer -->
+ (AudioStreamBasicDescription)pcmBasicDescWithConfig:(DVAudioConfig *)config {
 
    AudioStreamBasicDescription basicDesc = {0};
    
    basicDesc.mSampleRate = config.sampleRate;
    basicDesc.mFormatID = kAudioFormatLinearPCM;
    basicDesc.mFormatFlags = kAudioFormatFlagIsSignedInteger
                            |kAudioFormatFlagIsPacked;
                            //|kAudioFormatFlagsNativeEndian;
    
    basicDesc.mBitsPerChannel = config.bitsPerChannel;
    basicDesc.mChannelsPerFrame = config.numberOfChannels;
    
    basicDesc.mFramesPerPacket = 1;
    basicDesc.mBytesPerFrame = basicDesc.mBitsPerChannel / 8 * basicDesc.mChannelsPerFrame;
    basicDesc.mBytesPerPacket = basicDesc.mBytesPerFrame * basicDesc.mFramesPerPacket;
    
    return basicDesc;
}

+ (AudioStreamBasicDescription)aacBasicDescWithConfig:(DVAudioConfig *)config {
    
    AudioStreamBasicDescription basicDesc = {0};
    
    // 1.音频流，在正常播放情况下的帧率。如果是压缩的格式，这个属性表示解压缩后的帧率。帧率不能为0。
    basicDesc.mSampleRate       = config.sampleRate;
    // 2.AAC编码 kAudioFormatMPEG4AAC kAudioFormatMPEG4AAC_HE_V2
    basicDesc.mFormatID         = kAudioFormatMPEG4AAC;
    // 3.无损编码，0则无
    basicDesc.mFormatFlags      = kMPEG4Object_AAC_LC;
    // 4.语音每采样点占用位数 压缩格式设置为0
    basicDesc.mBitsPerChannel = 0;
    // 5.每帧的声道数
    basicDesc.mChannelsPerFrame = config.numberOfChannels;
    /* 6.每个packet的帧数。如果是未压缩的音频数据，值是1。动态帧率格式，这个值是一个较大的固定数字，
         比如说AAC的1024。如果是动态大小帧数（比如Ogg格式）设置为0。
     */
    basicDesc.mFramesPerPacket  = 1024;
    // 7.每帧的bytes数，每帧的大小。每一帧的起始点到下一帧的起始点。如果是压缩格式，设置为0 。
    basicDesc.mBytesPerFrame = 0;
    // 8.每一个packet的音频数据大小。如果的动态大小设置为0。动态大小的格式需要用AudioStreamPacketDescription来确定每个packet的大小。
    basicDesc.mBytesPerPacket = 0;
    // 9.字节对齐，填0.
    basicDesc.mReserved = 0;
    
    return basicDesc;
}

@end
