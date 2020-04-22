//
//  libFFmpeg.hpp
//  DVAVKit
//
//  Created by DV on 2019/1/6.
//  Copyright © 2019 DVKit. All rights reserved.
//

#ifndef libFFmpeg_hpp
#define libFFmpeg_hpp

#include <stdio.h>
#include "pthread.h"
#ifdef __cplusplus
extern "C" {
#endif
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/avutil.h>
#include <libavutil/mathematics.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>
#include <libavutil/opt.h>
#ifdef __cplusplus
};
#endif


class libFFmpeg {
public:
    libFFmpeg();
    ~libFFmpeg();
    
    int openURL(const char *url);
    int closeURL();
    
    pthread_mutex_t queue;
    
private:
    AVFormatContext *formatCtx;
    
    
};



#endif /* libFFmpeg_hpp */
