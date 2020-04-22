//
//  DVAudioError.m
//  iOS_Test
//
//  Created by DV on 2019/1/11.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import "DVAudioError.h"

void AudioCheckStatus(OSStatus status, NSString *message) {
    if (status == noErr) {
        return;
    }
    
    char fourCC[16];
    *(UInt32 *)fourCC = CFSwapInt32HostToBig(status);
    fourCC[4] = '\0';
    if (isprint(fourCC[0]) && isprint(fourCC[1]) && isprint(fourCC[2]) && isprint(fourCC[3])) {
        NSLog(@"[DVAudio ERROR]: %@ -> %s", message, fourCC);
    } else {
        NSLog(@"[DVAudio ERROR]: %@ -> %d", message, (int)status);
    }
}


@interface DVAudioError ()

@property(nonatomic, assign, readwrite) DVAudioErrorType errorType;

@end


@implementation DVAudioError

- (instancetype)initWithType:(DVAudioErrorType)errorType {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[self localDescWithType:errorType]};
    self = [super initWithDomain:self.audioDomain code:errorType userInfo:userInfo];
    if (self) {
        self.errorType = errorType;
    }
    return self;
}

+ (instancetype)errorWithType:(DVAudioErrorType)errorType {
    return [[DVAudioError alloc] initWithType:errorType];
}


- (NSErrorDomain)audioDomain {
    return @"DVAudioError";
}

- (NSString *)localDescWithType:(DVAudioErrorType)errorType {
    
    NSString *localDesc;
    
    switch (errorType) {
        case DVAudioError_notErr:
            localDesc = @"Not any error";
            break;
            
        case DVAudioError_notRecord:
            localDesc = @"Can't record";
            break;
            
        case DVAudioError_notPlay:
            localDesc = @"Can't play";
            break;
            
        default:
            localDesc = [NSString stringWithFormat: @"Can't identify error code:%lu",(unsigned long)self.errorType];
            break;
    }
    return [@"[DVAudio ERROR]:" stringByAppendingString:localDesc];
}

@end
