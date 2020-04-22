//
//  DVAudioAACHardwareDecoder.m
//  DVAVKit
//
//  Created by 施达威 on 2019/4/7.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVAudioAACHardwareDecoder.h"
#import "DVAudioError.h"


@interface DVAudioAACHardwareDecoder () {
    AudioConverterRef _converterRef;
    AudioStreamBasicDescription _inputBasicDesc;
    AudioStreamBasicDescription _outputBasicDesc;
    
    @public
    AudioBufferList _inputBufferList;
    AudioStreamPacketDescription _packetDesc;
}

@end


@implementation DVAudioAACHardwareDecoder

@synthesize delegate = _delegate;

#pragma mark - <-- Initializer -->
- (instancetype)initWithInputBasicDesc:(AudioStreamBasicDescription)inputBasicDesc
                       outputBasicDesc:(AudioStreamBasicDescription)outputBasicDesc
                              delegate:(id<DVAudioDecoderDelegate>)delegate {
    self = [super init];
    if (self) {
        self.outputDataPacketSize = 1024;
        self.delegate = delegate;
        _inputBasicDesc = inputBasicDesc;
        _outputBasicDesc = outputBasicDesc;
        [self initAudioConverter];
    }
    return self;
}

- (void)dealloc {
    [self uninitAudioConverter];
    _delegate = nil;
}


#pragma mark - <-- Init -->
- (void)initAudioConverter {
    
    OSStatus status;
    AudioClassDescription classDesc = {
        .mType = kAudioDecoderComponentType,
        .mSubType = _outputBasicDesc.mFormatID,
        .mManufacturer = 0,
    };
    
    
    // 1.获取硬解码器
    classDesc.mManufacturer = kAppleHardwareAudioCodecManufacturer;
    status = AudioConverterNewSpecific(&_inputBasicDesc,
                                       &_outputBasicDesc,
                                       1,
                                       &classDesc,
                                       &_converterRef);
    if (status == noErr) {
        NSLog(@"[DVAudioAACHardwareDecoder LOG]: 创建硬解码器成功 -> %u",(unsigned int)_outputBasicDesc.mFormatID);
        return;
    } else {
        AudioCheckStatus(status, @"创建硬解码器失败");
    }
    
    
    // 2.获取软解码器
    classDesc.mManufacturer = kAppleSoftwareAudioCodecManufacturer;
    status = AudioConverterNewSpecific(&_inputBasicDesc,
                                       &_outputBasicDesc,
                                       1,
                                       &classDesc,
                                       &_converterRef);
    if (status == noErr) {
        NSLog(@"[DVAudioAACHardwareDecoder LOG]: 创建软解码器成功 -> %u",(unsigned int)_outputBasicDesc.mFormatID);
        return;
    } else {
        AudioCheckStatus(status, @"创建软解码器失败");
    }
    
    _converterRef = nil;
}

- (void)uninitAudioConverter {
    if (!_converterRef) return;
    
    OSStatus status = AudioConverterDispose(_converterRef);
    AudioCheckStatus(status, @"注销解码器失败");
    _converterRef = NULL;
    
    NSLog(@"[DVAudioAACHardwareDecoder LOG]: 解码器关闭");
}


#pragma mark - <-- Method -->
- (void)decodeAudioData:(NSData *)data userInfo:(void *)userInfo {
    if (!data || data.length == 0) return;
    [self decodeAudioData:(void *)data.bytes size:(UInt32)data.length userInfo:userInfo];
}

- (void)decodeAudioData:(void *)data size:(UInt32)size userInfo:(void *)userInfo {
    if (!_converterRef || size == 0) return;
    if (!self.delegate) return;

    void *inUserData = (__bridge void *)self;
    _inputBufferList.mNumberBuffers              = 1;
    _inputBufferList.mBuffers[0].mNumberChannels = _inputBasicDesc.mChannelsPerFrame;
    _inputBufferList.mBuffers[0].mDataByteSize   = size;
    _inputBufferList.mBuffers[0].mData           = data;
    _packetDesc.mStartOffset = 0;
    _packetDesc.mVariableFramesInPacket = 0;
    _packetDesc.mDataByteSize = size;
    
    // 初始化一个输出缓冲列表
    UInt32 outputDataPacketSize = self.outputDataPacketSize;
    UInt32 outputSize = outputDataPacketSize * _outputBasicDesc.mChannelsPerFrame * _outputBasicDesc.mBytesPerFrame;
    char *outputBuf = (char *)malloc(outputSize * sizeof(char));

    AudioBufferList outputBufferList = {
        .mNumberBuffers              = 1,
        .mBuffers[0].mNumberChannels = _outputBasicDesc.mChannelsPerFrame,
        .mBuffers[0].mDataByteSize   = outputSize,      //设置缓冲区大小
        .mBuffers[0].mData           = outputBuf, //设置缓冲区
    };
    
    AudioStreamPacketDescription outputPacketDesc;
    
    OSStatus status = AudioConverterFillComplexBuffer(_converterRef,                // 转码器
                                                      deconverterComplexCallBack,   // 回调函数
                                                      inUserData,                   // 用户自定义数据指针
                                                      &outputDataPacketSize,        // 输出数据包大小
                                                      &outputBufferList,            // 输出数据 AudioBufferList 指针。
                                                      &outputPacketDesc);           // 输出包描述符

    if (status == noErr){
        NSData *outputData = [NSData dataWithBytesNoCopy:outputBufferList.mBuffers[0].mData
                                                  length:outputBufferList.mBuffers[0].mDataByteSize
                                            freeWhenDone:NO];
//        NSData *outputData = [NSData dataWithBytes:outputBufferList.mBuffers[0].mData
//                                            length:outputBufferList.mBuffers[0].mDataByteSize];
        [self.delegate DVAudioDecoder:self decodedData:outputData userInfo:userInfo];
    } else {
        AudioCheckStatus(status, @"音频解码失败");
    }
  
    free(outputBuf);
}

- (void)closeDecoder {
    [self uninitAudioConverter];
}


#pragma mark - <-- CallBack -->
OSStatus deconverterComplexCallBack(AudioConverterRef inAudioConverter,
                                    UInt32 *ioNumberDataPackets,
                                    AudioBufferList *ioData,
                                    AudioStreamPacketDescription **outDataPacketDescription,
                                    void *inUserData) {
    
    DVAudioAACHardwareDecoder *weakSelf = (__bridge DVAudioAACHardwareDecoder *)inUserData;
    
    AudioBufferList inputBufferList = weakSelf->_inputBufferList;
    
    *outDataPacketDescription = &(weakSelf->_packetDesc);
    (*outDataPacketDescription)[0].mStartOffset = 0;
    (*outDataPacketDescription)[0].mVariableFramesInPacket = 0;
    (*outDataPacketDescription)[0].mDataByteSize = inputBufferList.mBuffers[0].mDataByteSize;
    
    //填充AAC到缓冲区
    ioData->mNumberBuffers              = 1;
    ioData->mBuffers[0].mNumberChannels = inputBufferList.mBuffers[0].mNumberChannels;
    ioData->mBuffers[0].mDataByteSize   = inputBufferList.mBuffers[0].mDataByteSize;
    ioData->mBuffers[0].mData           = inputBufferList.mBuffers[0].mData;
    
    return noErr;
}

@end
