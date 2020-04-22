//
//  libFFmpeg.cpp
//  DVAVKit
//
//  Created by DV on 2019/1/6.
//  Copyright © 2019 DVKit. All rights reserved.
//

#include "libFFmpeg.hpp"


libFFmpeg::libFFmpeg() {
    
    av_register_all();
    avformat_network_init();
}

libFFmpeg::~libFFmpeg() {
    this->closeURL();
    
    avformat_network_deinit();
}


int libFFmpeg::openURL(const char *url) {
    if (this->formatCtx != NULL) this->closeURL();
    
    int ret = 0;
    AVFormatContext  *formatCtx = NULL;
    
    do {
        // 1.初始化上下文
        formatCtx = avformat_alloc_context();
        
        // 2.打开文件
        
        AVDictionary *opts = NULL;
        av_dict_set(&opts, "timeout", NULL, 0); // 设置超时5秒
        
        ret = avformat_open_input(&formatCtx, url, NULL, &opts);
//        ret = avformat_alloc_output_context2(&formatCtx, NULL, NULL, url);
        av_dict_free(&opts);
        if (ret < 0) {
            printf("[libFFmpeg LOG]: 无法打开 %s", url);
            break;
        }
        
        // 3.填充文件的meta信息
        ret = avformat_find_stream_info(formatCtx, NULL);
        if (ret < 0) {
            printf("[libFFmpeg LOG]: 无法打开 %s", url);
            break;
        }
        
        this->formatCtx = formatCtx;
        
    } while (false);
    
    if (ret < 0) {
        if (formatCtx) {
            avformat_close_input(&formatCtx);
            avformat_free_context(formatCtx);
        }
    }
    
    return ret;
}

int libFFmpeg::closeURL() {
    avformat_close_input(&this->formatCtx);
    avformat_free_context(this->formatCtx);
    this->formatCtx = NULL;
    return 1;
}






