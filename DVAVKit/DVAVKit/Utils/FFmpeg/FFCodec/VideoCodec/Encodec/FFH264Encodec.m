//
//  FFH264Encodec.m
//  DVAVKit
//
//  Created by DV on 2019/3/31.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "FFH264Encodec.h"

@implementation FFH264Encodec

//- (void)_newEncodecForH264:(AVCodec **)encodec {
//    AVCodec *codec = avcodec_find_encoder(AV_CODEC_ID_H264);
////    codec->height = dec_ctx->height;
////    codec->width = dec_ctx->width;
////    codec->sample_aspect_ratio = dec_ctx->sample_aspect_ratio;
////    codec->pix_fmt = encoder->pix_fmts[0];
////    codec->time_base = dec_ctx->time_base;
//    //codec->time_base.num = 1;
//    //codec->time_base.den = 25;
//    //H264的必备选项，没有就会错
//    codec->me_range=16;
//    codec->max_qdiff = 4;
//    codec->qmin = 10;
//    codec->qmax = 51;
//    codec->qcompress = 0.6;
//    codec->refs=3;
//    codec->bit_rate = 500000;
//
//    int ret = avcodec_open2(codec, encoder, NULL);
//    if (ret < 0) {
//        av_log(NULL, AV_LOG_ERROR, "Cannot open video encoder for stream #%u\n", i);
//        return ret;
//    }
//
//}

@end
