//
//  G726Encodec.hpp
//  LFLiveKit
//
//  Created by DV on 2018/10/26.
//  Copyright © 2018年 admin. All rights reserved.
//

#ifndef G726Encodec_hpp
#define G726Encodec_hpp

#include <stdio.h>
#include "libFFmpeg.hpp"

typedef struct _G726AudioPacket {
    uint8_t* data;
    int dataSize;
    int flag;
}G726AudioPacket;

class G726{
public:
    G726();
    ~G726();
    
    void init();
    
    G726AudioPacket encoder(uint8_t* buf, int buf_size);
    
private:
    AVCodec *codec;
    AVCodecContext *c = NULL;
    AVPacket avpkt;
    AVFrame *decoded_frame = NULL;
};

#endif /* G726Encodec_hpp */
