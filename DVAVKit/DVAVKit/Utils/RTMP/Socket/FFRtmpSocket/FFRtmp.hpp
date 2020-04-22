//
//  FFRtmp.hpp
//  iOS_Test
//
//  Created by DV on 2019/11/4.
//  Copyright © 2019 iOS. All rights reserved.
//

#ifndef FFRtmp_hpp
#define FFRtmp_hpp

#include <stdio.h>
#ifdef __cplusplus
extern "C" {
#endif
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>
#include <libavutil/channel_layout.h>
#include <libavutil/common.h>
#include <libavutil/frame.h>
#include <libavutil/samplefmt.h>
#ifdef __cplusplus
};
#endif


class FFRtmp {
public:
    FFRtmp();
    ~FFRtmp();
    
    int connectToUrl(char* url);
    int disconnect();
    
    int sendData(char *bytes,size_t size);
    
private:
    AVFormatContext *formatCtx;
    AVPacket packet;
    
    int openSocket(char* url);
    int closeSocket();
};


#endif /* FFRtmp_hpp */
