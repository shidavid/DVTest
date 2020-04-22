//
//  DVAudioHardwareEncoder.m
//  iOS_Test
//
//  Created by DV on 2019/9/25.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVAudioAACHardwareEncoder.h"
#import "DVAudioError.h"

@interface DVAudioAACHardwareEncoder () {
    AudioConverterRef _converterRef;
    AudioStreamBasicDescription _inputBasicDesc;
    AudioStreamBasicDescription _outputBasicDesc;
}

@end


@implementation DVAudioAACHardwareEncoder

@synthesize delegate = _delegate;

#pragma mark - <-- Initializer -->
- (instancetype)initWithInputBasicDesc:(AudioStreamBasicDescription)inputBasicDesc
                       outputBasicDesc:(AudioStreamBasicDescription)outputBasicDesc
                              delegate:(id<DVAudioEncoderDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        _inputBasicDesc = inputBasicDesc;
        _outputBasicDesc = outputBasicDesc;
        
        [self initAudioConverter];
    }
    return self;
}

- (void)dealloc {
    [self closeEncoder];
    _delegate = nil;
}


#pragma mark - <-- Init -->
- (void)initAudioConverter {
    
    OSStatus status;
    AudioClassDescription classDesc = {
        .mType = kAudioEncoderComponentType,
        .mSubType = _outputBasicDesc.mFormatID,
        .mManufacturer = 0,
    };
    
    
    // 1.获取硬编码器
    classDesc.mManufacturer = kAppleHardwareAudioCodecManufacturer;
    status = AudioConverterNewSpecific(&_inputBasicDesc,
                                       &_outputBasicDesc,
                                       1,
                                       &classDesc,
                                       &_converterRef);
    if (status == noErr) {
        NSLog(@"[DVAudioAACHardwareEncoder LOG]: 创建硬编码器成功 -> %u",(unsigned int)_outputBasicDesc.mFormatID);
        return;
    } else {
        AudioCheckStatus(status, @"创建硬编码器失败");
    }
    
    
    // 2.获取软编码器
    classDesc.mManufacturer = kAppleSoftwareAudioCodecManufacturer;
    status = AudioConverterNewSpecific(&_inputBasicDesc,
                                       &_outputBasicDesc,
                                       1,
                                       &classDesc,
                                       &_converterRef);
    if (status == noErr) {
        NSLog(@"[DVAudioAACHardwareEncoder LOG]: 创建软编码器成功 -> %u",(unsigned int)_outputBasicDesc.mFormatID);
        return;
    } else {
        AudioCheckStatus(status, @"创建软编码器失败");
    }
    
    _converterRef = nil;
}

- (void)uninitAudioConverter {
    if (_converterRef) {
        OSStatus status = AudioConverterDispose(_converterRef);
        AudioCheckStatus(status, @"注销编码器失败");
    }
}


#pragma mark - <-- Method -->
- (void)encodeAudioData:(NSData *)data userInfo:(void *)userInfo {
    if (!data) return;
    [self encodeAudioData:(void *)data.bytes size:(UInt32)data.length userInfo:userInfo];
}

- (void)encodeAudioData:(void *)data size:(UInt32)size userInfo:(void *)userInfo {
    if (!_converterRef || size <= 0) return;
    if (!self.delegate) return;

    
    AudioBufferList inputBufferList = {
        .mNumberBuffers              = 1,
        .mBuffers[0].mNumberChannels = _inputBasicDesc.mChannelsPerFrame,
        .mBuffers[0].mDataByteSize   = size,
        .mBuffers[0].mData           = data,
    };

    // 初始化一个输出缓冲列表
    UInt32 outputDataPacketSize = 1;
    char *outputBuf = malloc(size);
    
    AudioBufferList outputBufferList = {
        .mNumberBuffers              = 1,
        .mBuffers[0].mNumberChannels = _outputBasicDesc.mChannelsPerFrame,
        .mBuffers[0].mDataByteSize   = size,      //设置缓冲区大小
        .mBuffers[0].mData           = outputBuf, //设置缓冲区
    };
    AudioStreamPacketDescription outputPacketDesc = {0};
    

    OSStatus status = AudioConverterFillComplexBuffer(_converterRef,
                                                      converterComplexCallBack,
                                                      &inputBufferList,
                                                      &outputDataPacketSize,
                                                      &outputBufferList,
                                                      &outputPacketDesc);

    if (status == noErr){
        NSData *outputData = [NSData dataWithBytes:outputBufferList.mBuffers[0].mData
                                            length:outputBufferList.mBuffers[0].mDataByteSize];
        [self.delegate DVAudioEncoder:self codedData:outputData userInfo:userInfo];
    } else {
        AudioCheckStatus(status, @"音频编码失败");
    }
  
    free(outputBuf);
}

- (void)closeEncoder {
    [self uninitAudioConverter];
}


//#pragma mark - <-- Method -->

/**
 *  获取编解码器
 *
 *  @param encodeType   编码格式
 *  @param manufacturer 软/硬编
 *  编解码器（codec）指的是一个能够对一个信号或者一个数据流进行变换的设备或者程序。这里指的变换既包括将 信号或者数据流进行编码（通常是为了传输、存储或者加密）或者提取得到一个编码流的操作，也包括为了观察或者处理从这个编码流中恢复适合观察或操作的形式的操作。编解码器经常用在视频会议和流媒体等应用中。
 *  @return 指定编码器
 */
- (AudioClassDescription *)getAudioClassDescWithEncodeType:(OSType)encodeType
                                              manufacturer:(OSType)manufacturer {
    
    static AudioClassDescription classDesc;
    memset(&classDesc, 0, sizeof(classDesc));
    OSStatus status = noErr;
    
    AudioFormatPropertyID inPropID = kAudioFormatProperty_Encoders;
    UInt32 inSpec = encodeType;
    UInt32 outPropDataSize;
    
    
    status = AudioFormatGetPropertyInfo(inPropID, sizeof(inSpec), &inSpec, &outPropDataSize);
    if (status != noErr) {
        AudioCheckStatus(status, @"error getting audio format propery info");
        return nil;
    }
    
    
    unsigned int count = outPropDataSize / sizeof(AudioClassDescription);
    AudioClassDescription tempClassDescs[count];
    
    
    status = AudioFormatGetProperty(inPropID, sizeof(inSpec), &inSpec, &outPropDataSize, tempClassDescs);
    if (status != noErr) {
        AudioCheckStatus(status, @"error getting audio format propery");
        return nil;
    }
    
    for (unsigned int i = 0; i < count; i++) {
        if ((tempClassDescs[i].mSubType == encodeType) && (tempClassDescs[i].mManufacturer == manufacturer)) {
            memcpy(&classDesc, &(tempClassDescs[i]), sizeof(classDesc));
            return &classDesc;
        }
    }
    
    return nil;
}


- (NSData *)convertToADTSWithData:(NSData *)sourceData channel:(NSInteger)channel {
    NSMutableData *mData = [NSMutableData data];
    [mData appendData:[self adtsData:sourceData.length audioDataLength:channel]];
    [mData appendData:sourceData];
    return [mData copy];
}

/**
*  Add ADTS header at the beginning of each and every AAC packet.
*  This is needed as MediaCodec encoder generates a packet of raw
*  AAC data.
*
*  Note the packetLen must count in the ADTS header itself.
*  See: http://wiki.multimedia.cx/index.php?title=ADTS
*  Also: http://wiki.multimedia.cx/index.php?title=MPEG-4_Audio#Channel_Configurations
**/
- (NSData *)adtsData:(NSInteger)channel audioDataLength:(NSInteger)audioDataLength {
    int adtsLength = 7;
    char *packet = malloc(sizeof(char) * adtsLength);
    
    // Variables Recycled by addADTStoPacket
    int profile = 2;  //AAC LC
    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
    NSInteger freqIdx = [self sampleRateIndex:_outputBasicDesc.mSampleRate];  //44.1KHz
    int chanCfg = (int)channel;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
    NSUInteger fullLength = adtsLength + audioDataLength;
    
    // fill in ADTS data
    packet[0] = (char)0xFF;     // 11111111     = syncword
    packet[1] = (char)0xF9;     // 1111 1 00 1  = syncword MPEG-2 Layer CRC
    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
    packet[4] = (char)((fullLength&0x7FF) >> 3);
    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
    packet[6] = (char)0xFC;
    
    NSData *data = [NSData dataWithBytes:packet length:adtsLength];
    free(packet);
//    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
    return data;
}

- (NSInteger)sampleRateIndex:(NSInteger)sampleRate {
    NSInteger sampleRateIndex = 0;
    switch (sampleRate) {
        case 96000:
            sampleRateIndex = 0;
            break;
        case 88200:
            sampleRateIndex = 1;
            break;
        case 64000:
            sampleRateIndex = 2;
            break;
        case 48000:
            sampleRateIndex = 3;
            break;
        case 44100:
            sampleRateIndex = 4;
            break;
        case 32000:
            sampleRateIndex = 5;
            break;
        case 24000:
            sampleRateIndex = 6;
            break;
        case 22050:
            sampleRateIndex = 7;
            break;
        case 16000:
            sampleRateIndex = 8;
            break;
        case 12000:
            sampleRateIndex = 9;
            break;
        case 11025:
            sampleRateIndex = 10;
            break;
        case 8000:
            sampleRateIndex = 11;
            break;
        case 7350:
            sampleRateIndex = 12;
            break;
        default:
            sampleRateIndex = 15;
    }
    return sampleRateIndex;
}


#pragma mark - <-- CallBack -->
OSStatus converterComplexCallBack(AudioConverterRef inAudioConverter,
                                  UInt32 *ioNumberDataPackets,
                                  AudioBufferList *ioData,
                                  AudioStreamPacketDescription **outDataPacketDescription,
                                  void *inUserData) {
    //填充PCM到缓冲区
    AudioBufferList inputBufferList = *(AudioBufferList *)inUserData;
    ioData->mNumberBuffers              = inputBufferList.mNumberBuffers;
    ioData->mBuffers[0].mNumberChannels = inputBufferList.mBuffers[0].mNumberChannels;
    ioData->mBuffers[0].mDataByteSize   = inputBufferList.mBuffers[0].mDataByteSize;
    ioData->mBuffers[0].mData           = inputBufferList.mBuffers[0].mData;
    return noErr;
}

@end
