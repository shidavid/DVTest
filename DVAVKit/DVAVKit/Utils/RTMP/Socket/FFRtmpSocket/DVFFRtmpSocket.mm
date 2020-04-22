//
//  DVFFRtmpSocket.m
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVFFRtmpSocket.h"
#import "FFRtmp.hpp"


@interface DVFFRtmpSocket ()

@property(nonatomic, assign) DVRtmpErrorType rtmpErrType;
@property(nonatomic, assign, readwrite) DVRtmpStatus rtmpStatus;
@property(nonatomic, copy,   readwrite, nullable) NSString *url;

@property(nonatomic, strong) dispatch_semaphore_t lock;
@property(nonatomic, strong) dispatch_queue_t rtmpQueue;
@property(nonatomic, strong) DVRtmpBuffer *buffer;

@property(nonatomic, strong) DVMetaFlvTagData *metaHeader;
@property(nonatomic, strong) DVVideoFlvTagData *videoHeader;
@property(nonatomic, strong) DVAudioFlvTagData *audioHeader;

@property(nonatomic, assign) BOOL isSendMetaHeader;
@property(nonatomic, assign) BOOL isSendVideoHeader;
@property(nonatomic, assign) BOOL isSendAudioHeader;
@property(nonatomic, assign) __block BOOL isSending;

@property(nonatomic, assign) NSUInteger tempReconnCount;

@end


@implementation DVFFRtmpSocket

@synthesize url = _url;
@synthesize delegate = _delegate;
@synthesize isSending = _isSending;
@synthesize rtmpStatus = _rtmpStatus;
@synthesize bufferDelegate = _bufferDelegate;
@synthesize beginTimeStamp = _beginTimeStamp;
@synthesize reconnectCount = _reconnectCount;


- (instancetype)initWithDelegate:(id<DVRtmpDelegate>)delegate {
    self = [super init];
    if (self) {
        
//        FFRtmp *ffRtmp = new FFRtmp();
//        ffRtmp->connectToUrl("sdfsadf");
    }
    return self;
}


//#pragma mark - <-- Initializer -->
//- (instancetype)initWithDelegate:(id<DVRtmpDelegate>)delegate {
//    self = [super init];
//    if (self) {
//        self.delegate = delegate;
//        self.buffer = [[DVRtmpBuffer alloc] init];
//
//        self.lock = dispatch_semaphore_create(1);
//        self.rtmpQueue = dispatch_queue_create("com.DVRtmp.RtmpSocket", nil);
//
//        self.rtmpStatus = DVRtmpStatus_Disconnected;
//        self.beginTimeStamp = 0;
//        self.reconnectCount = 5;
//        _isSending = NO;
//    }
//    return self;
//}
//
//- (void)dealloc {
//    _delegate = nil;
//    _rtmpStatus = DVRtmpStatus_Disconnected;
//    [self RTMP_Uninit];
//
//    _rtmpQueue = nil;
//    _lock = nil;
//    _buffer = nil;
//}
//
//
//#pragma mark - <-- Property -->
//- (void)setReconnectCount:(NSUInteger)reconnectCount {
//    _reconnectCount = reconnectCount;
//    self.tempReconnCount = reconnectCount;
//}
//
//- (void)setBufferDelegate:(id<DVRtmpBufferDelegate>)bufferDelegate {
//    if (self.buffer) self.buffer.delegate = bufferDelegate;
//}
//
//- (BOOL)isSending {
//    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
//    BOOL flag = _isSending;
//    dispatch_semaphore_signal(self.lock);
//    return flag;
//}
//
//- (void)setIsSending:(BOOL)isSending {
//    dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
//    _isSending = isSending;
//    dispatch_semaphore_signal(self.lock);
//    if (_isSending == NO) [self sendingPacket];
//}
//
//- (void)setRtmpStatus:(DVRtmpStatus)rtmpStatus {
//    if (_rtmpStatus != rtmpStatus && self.delegate) {
//        __weak __typeof(self)weakSelf = self;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf.delegate DVRtmp:weakSelf status:rtmpStatus];
//        });
//    }
//    _rtmpStatus = rtmpStatus;
//}
//
//- (void)setRtmpErrType:(DVRtmpErrorType)rtmpErrType {
//    if (self.delegate) {
//        __weak __typeof(self)weakSelf = self;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf.delegate DVRtmp:weakSelf error:[DVRtmpError errorWithType:rtmpErrType]];
//        });
//    }
//}
//
//
//#pragma mark - <-- Private Method -->
//- (void)sendingPacket {
//    if (self.isSending
//        || self.buffer.bufferCount == 0
//        || self.rtmpStatus != DVRtmpStatus_Connected) {
//        return;
//    }
//
//    __weak __typeof(self)weakSelf = self;
//    dispatch_async(self.rtmpQueue, ^{
//        if (weakSelf.isSending
//            || weakSelf.buffer.bufferCount == 0
//            || weakSelf.rtmpStatus != DVRtmpStatus_Connected) {
//            return;
//        }
//
//        weakSelf.isSending = YES;
//
//        DVRtmpPacket * packet = [weakSelf.buffer popFirstBuffer];
//
//        int ret = 0;
//        if (packet.videoData) {
//            if (!weakSelf.isSendVideoHeader) [weakSelf sendVideoHeader];
//            NSData *packetData = packet.videoData.fullData;
//            ret = [weakSelf RTMP_SendVideoPacket:(u_char *)packetData.bytes
//                                            size:(uint32_t)packetData.length
//                                       timeStamp:packet.timeStamp];
//        }
//        else if (packet.audioData){
//            if (!weakSelf.isSendAudioHeader) [weakSelf sendAudioHeader];
//            NSData *packetData = packet.audioData.fullData;
//            ret = [weakSelf RTMP_SendAudioPacket:(u_char *)packetData.bytes
//                                            size:(uint32_t)packetData.length
//                                       timeStamp:packet.timeStamp];
//        }
//
//        if (ret != 1) {
//            weakSelf.rtmpErrType = DVRtmpErrorFailToSendPacket;
//        }
//
//        dispatch_async(self.rtmpQueue, ^{
//            weakSelf.isSending = NO;
//        });
//    });
//}
//
//- (void)sendMetaHeader {
//    if (!self.metaHeader || self.isSendMetaHeader) return;
//
//    NSData *packet = self.metaHeader.fullData;
//    int ret = [self RTMP_SendMetaPacket:(u_char *)packet.bytes
//                                   size:(uint32_t)packet.length];
//
//    if (ret != 1) {
//        self.rtmpErrType = DVRtmpErrorFailToSendMetaHeader;
//    } else {
//        self.isSendMetaHeader = YES;
//    }
//}
//
//- (void)sendVideoHeader {
//    if (!self.videoHeader || self.isSendVideoHeader) return;
//
//    NSData *packet = self.videoHeader.fullData;
//    int ret = [self RTMP_SendVideoPacket:(u_char *)packet.bytes
//                                    size:(uint32_t)packet.length
//                                timeStamp:0];
//
//    if (ret != 1) {
//        self.rtmpErrType = DVRtmpErrorFailToSendVideoHeader;
//    } else {
//        self.isSendVideoHeader = YES;
//    }
//}
//
//- (void)sendAudioHeader {
//    if (!self.audioHeader || self.isSendAudioHeader) return;
//
//    NSData *packet = self.audioHeader.fullData;
//    int ret = [self RTMP_SendAudioPacket:(u_char *)packet.bytes
//                                    size:(uint32_t)packet.length
//                               timeStamp:0];
//
//    if (ret != 1) {
//        self.rtmpErrType = DVRtmpErrorFailToSendAudioHeader;
//    } else {
//        self.isSendAudioHeader = YES;
//    }
//}
//
//
//
//#pragma mark - <-- Public Method -->
//- (void)connectToURL:(NSString *)url {
//    __weak __typeof(self)weakSelf = self;
//    dispatch_async(self.rtmpQueue, ^{
//        if (!url || ![url hasPrefix:@"rtmp://"]) {
//            weakSelf.rtmpStatus = DVRtmpStatus_Disconnected;
//            weakSelf.rtmpErrType = DVRtmpErrorURLFormatIncorrect;
//            return;
//        }
//
//        weakSelf.url = url;
//        weakSelf.isSendMetaHeader = NO;
//        weakSelf.isSendVideoHeader = NO;
//        weakSelf.isSendAudioHeader = NO;
//        if (weakSelf.rtmpStatus != DVRtmpStatus_Reconnecting) {
//            weakSelf.rtmpStatus = DVRtmpStatus_Connecting;
//        }
//
//
//        [weakSelf RTMP_Init];
//        int ret = [weakSelf RTMP_Connect:(char *)[url cStringUsingEncoding:NSASCIIStringEncoding]];
//        if (ret == 1) {
//            [weakSelf sendMetaHeader];
//            weakSelf.rtmpStatus = DVRtmpStatus_Connected;
//            weakSelf.tempReconnCount = weakSelf.reconnectCount;
//        } else {
//            switch (ret) {
//                case -1:
//                    weakSelf.rtmpErrType = DVRtmpErrorFailToSetURL;
//                    break;
//                case -2:
//                    weakSelf.rtmpErrType = DVRtmpErrorFailToConnectServer;
//                    break;
//                case -3:
//                    weakSelf.rtmpErrType = DVRtmpErrorFailToConnectStream;
//                    break;
//                default:
//                    break;
//            }
//
//            [weakSelf reconnect];
//        }
//    });
//}
//
//- (void)reconnect {
//    if (self.rtmpStatus == DVRtmpStatus_Reconnecting) return;
//    __weak __typeof(self)weakSelf = self;
//    dispatch_async(self.rtmpQueue, ^{
//        if (weakSelf.url && weakSelf.tempReconnCount > 0) {
//            weakSelf.tempReconnCount -= 1;
//            weakSelf.rtmpStatus = DVRtmpStatus_Reconnecting;
//            [weakSelf connectToURL:weakSelf.url];
//        } else {
//            weakSelf.tempReconnCount = weakSelf.reconnectCount;
//            [weakSelf disconnect];
//        }
//    });
//}
//
//- (void)disconnect {
//    __weak __typeof(self)weakSelf = self;
//    dispatch_async(self.rtmpQueue, ^{
//        [weakSelf RTMP_Uninit];
//        weakSelf.rtmpStatus = DVRtmpStatus_Disconnected;
//    });
//}
//
//- (void)setMetaHeader:(DVMetaFlvTagData *)metaHeader {
//    _metaHeader = metaHeader;
//}
//
//- (void)setVideoHeader:(DVVideoFlvTagData *)videoHeader {
//    _videoHeader = videoHeader;
//}
//
//- (void)setAudioHeader:(DVAudioFlvTagData *)audioHeader {
//    _audioHeader = audioHeader;
//}
//
//- (void)sendPacket:(DVRtmpPacket *)packet {
//    [self.buffer pushBuffer:packet];
//    [self sendingPacket];
//}
//
//
//#pragma mark - <-- RTMP -->
//- (void)RTMP_Init {
//    if (_rtmp != NULL) {
//        [self RTMP_Uninit];
//    }
//
//    //由于摄像头的timestamp是一直在累加，需要每次得到相对时间戳
//    //分配与初始化
//    _rtmp = PILI_RTMP_Alloc();
//    PILI_RTMP_Init(_rtmp);
//}
//
//- (void)RTMP_Uninit {
//    if (_rtmp != NULL) {
//        PILI_RTMP_Close(_rtmp, &_error);
//        PILI_RTMP_Free(_rtmp);
//        _rtmp = NULL;
//    }
//}
//
//- (int)RTMP_Connect:(char *)url {
//    int ret = 1;
//
//    do {
//        //设置URL
//        if (PILI_RTMP_SetupURL(_rtmp, url, &_error) == FALSE) {
//            ret = -1;
//            break;
//        }
//
//        _rtmp->m_errorCallback = RTMP_Error_CallBack;
//        _rtmp->m_connCallback = RTMP_ConnectTime_CallBack;
//        _rtmp->m_userData = (__bridge void *)self;
//        _rtmp->m_msgCounter = 1;
//        _rtmp->Link.timeout = 5; // rtmp连接超时(s)
//
//        //设置可写，即发布流，这个函数必须在连接前使用，否则无效
//        PILI_RTMP_EnableWrite(_rtmp);
//
//        //连接服务器
//        if (PILI_RTMP_Connect(_rtmp, NULL, &_error) == FALSE) {
//            ret = -2;
//            break;
//        }
//
//        //连接流
//        if (PILI_RTMP_ConnectStream(_rtmp, 0, &_error) == FALSE) {
//            ret = -3;
//            break;
//        }
//
//    } while (NO);
//
//    return ret;
//}
//
//- (int)RTMP_SendMetaPacket:(u_char *)data size:(uint32_t)size {
//    PILI_RTMPPacket rtmp_packet;
//    PILI_RTMPPacket_Reset(&rtmp_packet);
//    PILI_RTMPPacket_Alloc(&rtmp_packet, size);
//
//    rtmp_packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
//    rtmp_packet.m_packetType = RTMP_PACKET_TYPE_INFO;
//    rtmp_packet.m_hasAbsTimestamp = TRUE;
//    rtmp_packet.m_nTimeStamp = 0;
//    rtmp_packet.m_nChannel = 0x03;
//    if (_rtmp) rtmp_packet.m_nInfoField2 = _rtmp->m_stream_id;
//    rtmp_packet.m_nBodySize = size;
//    memcpy(rtmp_packet.m_body, data, size);
//
//    int ret = -1;
//    if (_rtmp && PILI_RTMP_IsConnected(_rtmp)) {
//        ret = PILI_RTMP_SendPacket(_rtmp, &rtmp_packet, 0, &_error);
//    }
//    PILI_RTMPPacket_Free(&rtmp_packet);
//
//    return ret;
//}
//
//- (int)RTMP_SendVideoPacket:(u_char *)data size:(uint32_t)size timeStamp:(uint32_t)timeStamp {
//    PILI_RTMPPacket rtmp_packet;
//    PILI_RTMPPacket_Reset(&rtmp_packet);
//    PILI_RTMPPacket_Alloc(&rtmp_packet, size);
//
//    if (self.beginTimeStamp == 0) self.beginTimeStamp = timeStamp;
//    timeStamp = timeStamp - self.beginTimeStamp;
//
//    rtmp_packet.m_headerType = RTMP_PACKET_SIZE_LARGE;
//    rtmp_packet.m_packetType = RTMP_PACKET_TYPE_VIDEO;
//    rtmp_packet.m_hasAbsTimestamp = 0;
//    rtmp_packet.m_nTimeStamp = timeStamp;
//    rtmp_packet.m_nChannel = 0x04;
//    if (_rtmp) rtmp_packet.m_nInfoField2 = _rtmp->m_stream_id;
//    rtmp_packet.m_nBodySize = size;
//    memcpy(rtmp_packet.m_body, data, size);
//
//    int ret = -1;
//    if (_rtmp && PILI_RTMP_IsConnected(_rtmp)) {
//        ret = PILI_RTMP_SendPacket(_rtmp, &rtmp_packet, 0, &_error);
//    }
//    PILI_RTMPPacket_Free(&rtmp_packet);
//
//    return ret;
//}
//
//- (int)RTMP_SendAudioPacket:(u_char *)data size:(uint32_t)size timeStamp:(uint32_t)timeStamp {
//    PILI_RTMPPacket rtmp_packet;
//    PILI_RTMPPacket_Reset(&rtmp_packet);
//    PILI_RTMPPacket_Alloc(&rtmp_packet, size);
//
//    if (self.beginTimeStamp == 0) self.beginTimeStamp = timeStamp;
//    timeStamp = timeStamp - self.beginTimeStamp;
//
//    rtmp_packet.m_headerType = (size != 4 ? RTMP_PACKET_SIZE_MEDIUM : RTMP_PACKET_SIZE_LARGE);
//    rtmp_packet.m_packetType = RTMP_PACKET_TYPE_AUDIO;
//    rtmp_packet.m_hasAbsTimestamp = 0;
//    rtmp_packet.m_nTimeStamp = timeStamp;
//    rtmp_packet.m_nChannel = 0x05;
//    if (_rtmp) rtmp_packet.m_nInfoField2 = _rtmp->m_stream_id;
//    rtmp_packet.m_nBodySize = size;
//    memcpy(rtmp_packet.m_body, data, size);
//
//    int ret = -1;
//    if (_rtmp && PILI_RTMP_IsConnected(_rtmp)) {
//        ret = PILI_RTMP_SendPacket(_rtmp, &rtmp_packet, 0, &_error);
//    }
//    PILI_RTMPPacket_Free(&rtmp_packet);
//
//    return ret;
//}
//
//
//
//#pragma mark - <-- CallBack -->
//void RTMP_Error_CallBack(RTMPError *error, void *userData) {
//    DVRtmpSocket *socket = (__bridge DVRtmpSocket *)userData;
//    if (error->code < 0) {
//        NSLog(@"[DVRtmp ERROR]: code:%d message:%s",error->code,error->message);
//        [socket reconnect];
//    }
//}
//
//void RTMP_ConnectTime_CallBack(PILI_CONNECTION_TIME *conn_time, void *userData) {
//    NSLog(@"[DVRtmp LOG]: connect time -> %d, shake time -> %d",
//          conn_time->connect_time,
//          conn_time->handshake_time);
//
//    DVRtmpSocket *socket = (__bridge DVRtmpSocket *)userData;
//    socket.rtmpStatus = DVRtmpStatus_Connected;
//}

@end
