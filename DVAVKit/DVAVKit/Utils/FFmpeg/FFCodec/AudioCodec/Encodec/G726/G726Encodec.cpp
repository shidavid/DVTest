//
//  G726Encodec.cpp
//  LFLiveKit
//
//  Created by DV on 2018/10/26.
//  Copyright © 2018年 admin. All rights reserved.
//

#include "G726Encodec.hpp"


G726::G726() {
    this->init();
}

G726::~G726(){
    avcodec_close(c);
    avcodec_free_context(&c);
    av_free_packet(&avpkt);
    av_frame_free(&decoded_frame);
}

void G726::init(){
    /* register all the codecs */
//    avcodec_register_all();
    
    avformat_network_init();
    av_register_all();

    av_init_packet(&avpkt);
    avpkt.data = NULL;
    avpkt.size = 0;
    
    /* find the mpeg audio decoder */
    codec = avcodec_find_encoder(AV_CODEC_ID_ADPCM_G726);
    if (!codec) {
        fprintf(stderr, "codec not found\n");
        return;
    }
    
    //put sample parameters
    c = avcodec_alloc_context3(codec);
    c->bits_per_coded_sample = 4;
    c->bit_rate = 32000;                //码率
    c->sample_rate = 8000;              //采样率
    c->channels = 1;                    //通道数
    c->codec_type = AVMEDIA_TYPE_AUDIO;
    c->sample_fmt = AV_SAMPLE_FMT_S16;  //采样位数
    
    /* open it */
    int iRet = avcodec_open2(c, codec,NULL);
    if ( iRet < 0 ) {
        fprintf(stderr, "could not open codec\n");
        return;
    }
}

G726AudioPacket G726::encoder(uint8_t *buf, int buf_size) {
    
    G726AudioPacket g726AudioPacket;
    g726AudioPacket.flag = 0;

//    const int buf_size = 640*2;//512+128;
//    char szBuffer[buf_size] = {0};
    int ret = 0;
    int got_packet = 0;

    if (!decoded_frame) {
        if (!(decoded_frame = av_frame_alloc())) {
            return g726AudioPacket;
        }
    }

    decoded_frame->nb_samples = buf_size / (c->channels * av_get_bytes_per_sample(c->sample_fmt));
    ret = avcodec_fill_audio_frame(decoded_frame, c->channels, c->sample_fmt,(uint8_t*)buf, buf_size, 1);

    if (ret < 0) {
        return g726AudioPacket;
    }

    if (avcodec_encode_audio2(c, &avpkt, decoded_frame, &got_packet) < 0) {
        return g726AudioPacket;
    }

    if (got_packet) {
        g726AudioPacket.data = avpkt.data;
        g726AudioPacket.dataSize = avpkt.size;
        g726AudioPacket.flag = 1;
        return g726AudioPacket;
    }
    return g726AudioPacket;
}



