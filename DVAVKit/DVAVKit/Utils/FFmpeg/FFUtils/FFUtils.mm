//
//  FFUtils.m
//  DVAVKit
//
//  Created by 施达威 on 2019/3/30.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "FFUtils.h"
#import "libFFmpeg.hpp"

@interface FFPacket () {
    @public
    AVPacket *_pkt;
}
@end

@interface FFInFormatContext () {
    @public
    AVFormatContext *_inFmtCtx;
    AVIOContext *_inIOCtx;
    unsigned char *_inBuffer;
}
@end

@interface FFOutFormatContext () {
    @public
    AVFormatContext *_outFmtCtx;
    AVIOContext *_outIOCtx;
    unsigned char *_outBuffer;
}
@end


@implementation FFUtils

+ (int)convertCodecparFromInFmtCtx:(FFInFormatContext *)inFmtCtx
                       toOutFmtCtx:(FFOutFormatContext *)outFmtCtx {
    
    AVFormatContext *ffInFmtCtx = inFmtCtx->_inFmtCtx;
    AVFormatContext *ffOutFmtCtx = outFmtCtx->_outFmtCtx;
    
    int ret = -1;
    if (ffInFmtCtx == NULL || ffOutFmtCtx == NULL) return ret;
    
    int nb = ffInFmtCtx->nb_streams;
    for (int i = 0; i < nb; ++i) {
        
        AVStream *inStream = ffInFmtCtx->streams[i];
        AVCodec *encodec = avcodec_find_encoder(inStream->codecpar->codec_id);
       
        if (!encodec) {
            encodec = avcodec_find_encoder(inStream->codec->codec_id);
        }
        
        if (!encodec) {
            av_log(NULL, AV_LOG_ERROR, "寻找不到 inStream->codec: %u", inStream->codecpar->codec_id);
            continue;
        }
        
        AVStream *outStream = avformat_new_stream(ffOutFmtCtx, encodec);
        avcodec_parameters_copy(outStream->codecpar, inStream->codecpar);
        avcodec_parameters_to_context(outStream->codec, outStream->codecpar);
        outStream->codecpar->codec_tag = 0;
        outStream->codec->codec_tag = 0;
        
        if (ffOutFmtCtx->oformat->flags & AVFMT_GLOBALHEADER) {
            outStream->codec->flags |= CODEC_FLAG_GLOBAL_HEADER;
        }
    }
    
    return ret;
}

+ (void)convertTimeBaseWithPacket:(FFPacket *)packet
                     fromInFmtCtx:(FFInFormatContext *)inFmtCtx
                      toOutFmtCtx:(FFOutFormatContext *)outFmtCtx {
    
    AVPacket *pkt = packet->_pkt;
    AVFormatContext *ffInFmtCtx = inFmtCtx->_inFmtCtx;
    AVFormatContext *ffOutFmtCtx = outFmtCtx->_outFmtCtx;
    
    int nb = ffOutFmtCtx->nb_streams;
    if (pkt->stream_index >= nb) return;
    
    AVStream *inStream = ffInFmtCtx->streams[pkt->stream_index];
    AVStream *outStream = ffOutFmtCtx->streams[pkt->stream_index];

    AVRounding rounding = (AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX);
    pkt->pts = av_rescale_q_rnd(pkt->pts, inStream->time_base, outStream->time_base, rounding);
    pkt->dts = av_rescale_q_rnd(pkt->dts, inStream->time_base, outStream->time_base, rounding);
    pkt->duration = av_rescale_q(pkt->duration, inStream->time_base, outStream->time_base);
    pkt->pos = -1;
}

+ (NSArray<NSData *> *)analyH264SpsPpsWithExtradata:(const uint8_t *)extradata size:(int)size {
    NSMutableArray<NSData *> *datas = [NSMutableArray array];
    
    /*
    body[index++] = 0x01;        // configuration
    body[index++] = spsBytes[1]; // AVCProfileIndication:  sps[1]
    body[index++] = spsBytes[2]; // profile_compatibility: sps[2]
    body[index++] = spsBytes[3]; // AVCLevelIndication:    sps[3]
    body[index++] = 0xff;        // lengthSizeMinusOne:  1111 1xxx -> xxx = lengthSizeMinusOne & 0x03 + 1
    
    body[index++] = 0xe1; // numOfSequenceParameterSets: sps个数 -> 111x xxxx
                          // x xxxx = numOfSequenceParameterSets & 0x1f
    body[index++] = (spsLen >> 8) & 0xff;  // sequenceParameterSetLength 2Bytes
    body[index++] = spsLen & 0xff;
    memcpy(&body[index], spsBytes, spsLen); // sequenceParameterSetNALUnits : sps内容
    index += spsLen;
    
    body[index++] = 0x01; // numOfPictureParameterSets : pps个数
    body[index++] = (ppsLen >> 8) & 0xff; // pictureParameterSetLength 2Bytes
    body[index++] = ppsLen & 0xff;
    memcpy(&body[index], ppsBytes, ppsLen); // pictureParameterSetNALUnits : pps内容
    index += ppsLen;
     */
    
    int index = 5;
    
    // 获取sps
    uint8_t spsCount = extradata[index++];
    spsCount &= 0x1f;
    
    if (spsCount > 0) {
        uint16_t spsLen = extradata[index] << 8 | extradata[index+1];
        index += 2;
        
        if (spsLen > 0) {
            UInt8 *sps = (UInt8 *)malloc(spsLen);
            memcpy(sps, extradata+index, spsLen);
            index += spsLen;
            
            NSData *spsData = [NSData dataWithBytes:sps length:spsLen];
            [datas addObject:spsData];
            
            free(sps);
        }
    }
    
    
    // 获取pps
    uint8_t ppsCount = extradata[index++];

    if (ppsCount > 0) {
        uint16_t ppsLen = extradata[index] << 8 | extradata[index+1];
        index += 2;

        if (ppsLen > 0) {
            UInt8 *pps = (UInt8 *)malloc(ppsLen);
            memcpy(pps, extradata+index, ppsLen);
            index += ppsLen;

            NSData *ppsData = [NSData dataWithBytes:pps length:ppsLen];
            [datas addObject:ppsData];

            free(pps);
        }
    }
    
    return [datas copy];
}

+ (NSArray<NSData *> *)analyHEVCVpsSpsPpsWithExtradata:(const uint8_t *)extradata size:(int)size {
    NSMutableArray *datas = [NSMutableArray array];
    
    
    
//    body[index++] = 0x03; // numOfArrays-8
//
//
//    #pragma mark - <-------------------- vps -------------------->
//    body[index++] = 0x20; // vps类型
//    body[index++] = 0x00; // vps数量
//    body[index++] = 0x01;
//    body[index++] = (vpsLen >> 8) & 0xff;  // vps长度
//    body[index++] = vpsLen & 0xff;
//    memcpy(&body[index], vpsBytes, vpsLen); // vps内容
//    index += vpsLen;
//
//    #pragma mark - <-------------------- sps -------------------->
//    body[index++] = 0x21; // sps类型
//    body[index++] = 0x00; // sps数量
//    body[index++] = 0x01;
//    body[index++] = (spsLen >> 8) & 0xff;  // sps长度
//    body[index++] = spsLen & 0xff;
//    memcpy(&body[index], spsBytes, spsLen); // sps内容
//    index += spsLen;
//
//    #pragma mark - <-------------------- pps -------------------->
//    body[index++] = 0x22; // pps类型
//    body[index++] = 0x00; // pps数量
//    body[index++] = 0x01;
//    body[index++] = (ppsLen >> 8) & 0xff;  // pps长度
//    body[index++] = ppsLen & 0xff;
//    memcpy(&body[index], ppsBytes, ppsLen); // pps内容
//    index += ppsLen;
    
    
    int index = 22;
    
    uint8_t paramCount = extradata[index++];
    
    while (paramCount > 0) {
        paramCount -= 1;
        
        uint8_t type = extradata[index++];
        
        uint16_t count = extradata[index] << 8 | extradata[index+1];
        index += 2;
        
        if (count == 0) continue;
        
        uint16_t len = extradata[index] << 8 | extradata[index+1];
        index += 2;
        
        UInt8 *param = (UInt8 *)malloc(len);
        memcpy(param, extradata+index, len);
        index += len;

        NSData *data = [NSData dataWithBytes:param length:len];
        [datas addObject:data];

        free(param);
    }

    return [datas copy];
}

@end
