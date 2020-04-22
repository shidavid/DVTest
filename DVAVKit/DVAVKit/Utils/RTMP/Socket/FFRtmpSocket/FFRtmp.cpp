//
//  FFRtmp.cpp
//  iOS_Test
//
//  Created by DV on 2019/11/4.
//  Copyright © 2019 iOS. All rights reserved.
//

#include "FFRtmp.hpp"



//MARK: - <-- Initializer -->
FFRtmp::FFRtmp() {
    av_register_all();
    avformat_network_init();
    

    
    this->formatCtx = avformat_alloc_context();
}

FFRtmp::~FFRtmp() {
    avformat_network_deinit();
}


//MARK: - <-- Public -->
int FFRtmp::connectToUrl(char* url) {
    return this->openSocket(url);
}

int FFRtmp::disconnect() {
    return this->closeSocket();
}


int FFRtmp::sendData(char *bytes, size_t size) {
    
    AVPacket pkt;
    
    memcpy(&pkt, bytes, size);
    pkt.size = (int)size;
    
    
    av_write_frame(this->formatCtx, &pkt);
    
    
    
    return 1;
}


//MARK: - <-- Private -->
int FFRtmp::openSocket(char* url) {
    int ret = 0;
    
    ret = avformat_open_input(&this->formatCtx, NULL, NULL, NULL);
    ret = avformat_alloc_output_context2(&this->formatCtx, NULL, "flv", url);
    
    ret = avformat_write_header(this->formatCtx, NULL);
    
    return 0;
}

int FFRtmp::closeSocket() {
    
    av_write_trailer(this->formatCtx);
    
    
    return 0;
}
