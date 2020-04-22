//
//  DVMetaFlvTagData.m
//  iOS_Test
//
//  Created by DV on 2019/10/18.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVMetaFlvTagData.h"
#import "NSString+DVAMF.h"
#import "NSNumber+DVAMF.h"
#import "NSMutableDictionary+DVAMF.h"

@interface DVMetaFlvTagData ()

@property(nonatomic, strong) NSMutableDictionary<NSString<DVAMF> *,id<DVAMF>> *mDict;

@end


@implementation DVMetaFlvTagData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mDict = [NSMutableDictionary dictionary];
        self.duration = 0;
        self.fileSize = 0;
        self.videoCodecID = @"avc1";
        self.audioCodecID = @"mp4a";
    }
    return self;
}

- (void)dealloc {
    if (_mDict) {
        [_mDict removeAllObjects];
        _mDict = nil;
    }
}


#pragma mark - <-- Base -->
- (void)setDuration:(float)duration {
    _duration = duration;
    [self.mDict setAMFObject:[NSNumber numberWithDouble:(double)duration]
                   forAMFKey:@"duration"];
}

- (void)setFileSize:(float)fileSize {
    _fileSize = fileSize;
    [self.mDict setAMFObject:[NSNumber numberWithDouble:(double)fileSize]
                   forAMFKey:@"fileSize"];
}


#pragma mark - <-- Video -->
- (void)setVideoWidth:(CGFloat)videoWidth {
    _videoWidth = videoWidth;
    [self.mDict setAMFObject:[NSNumber numberWithDouble:(double)videoWidth]
                   forAMFKey:@"width"];
}

- (void)setVideoHeight:(CGFloat)videoHeight {
    _videoHeight = videoHeight;
    [self.mDict setAMFObject:[NSNumber numberWithDouble:(double)videoHeight]
                   forAMFKey:@"height"];
}

- (void)setVideoFps:(NSUInteger)videoFps {
    _videoFps = videoFps;
    [self.mDict setAMFObject:[NSNumber numberWithDouble:(double)videoFps]
                   forAMFKey:@"framerate"];
}

- (void)setVideoBitRate:(NSUInteger)videoBitRate {
    _videoBitRate = videoBitRate;
    [self.mDict setAMFObject:[NSNumber numberWithDouble:(double)(videoBitRate/1024.f)]
                   forAMFKey:@"videodatarate"];
}

- (void)setVideoCodecID:(NSString *)videoCodecID {
    _videoCodecID = videoCodecID;
    [self.mDict setAMFObject:videoCodecID
                   forAMFKey:@"videocodecid"];
}


#pragma mark - <-- Audio -->
- (void)setAudioSampleRate:(NSUInteger)audioSampleRate {
    _audioSampleRate = audioSampleRate;
    [self.mDict setAMFObject:[NSNumber numberWithDouble:(double)audioSampleRate]
                   forAMFKey:@"audiosamplerate"];
}

- (void)setAudioBits:(UInt32)audioBits {
    _audioBits = audioBits;
    [self.mDict setAMFObject:[NSNumber numberWithDouble:(double)audioBits]
                   forAMFKey:@"audiosamplesize"];
}

- (void)setAudioChannels:(UInt32)audioChannels {
    _audioChannels = audioChannels;
    NSNumber *num = [NSNumber numberWithBool:(audioChannels > 1 ? YES : NO)];
    [self.mDict setAMFObject:num
                   forAMFKey:@"stereo"];
}

- (void)setAudioCodecID:(NSString *)audioCodecID {
    _audioCodecID = audioCodecID;
    [self.mDict setAMFObject:audioCodecID
                   forAMFKey:@"audiocodecid"];
}


#pragma mark - <-- Delegate -->
- (NSData *)fullData {
    NSMutableData *mData = [NSMutableData data];
    
    NSString *metaAMF = @"onMetaData";
    
    [mData appendData:metaAMF.amfData];
    [mData appendData:self.mDict.amfData];
    
    return [mData copy];
}

@end
