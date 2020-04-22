//
//  DVVideoError.m
//  iOS_Test
//
//  Created by DV on 2019/9/27.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVVideoError.h"

void VideoCheckStatus(OSStatus status, NSString *message) {
    if (status == noErr) {
        return;
    }
    
    char fourCC[16];
    *(UInt32 *)fourCC = CFSwapInt32HostToBig(status);
    fourCC[4] = '\0';
    if (isprint(fourCC[0]) && isprint(fourCC[1]) && isprint(fourCC[2]) && isprint(fourCC[3])) {
        NSLog(@"[DVVideo ERROR]: %@ -> %s", message, fourCC);
    } else {
        NSLog(@"[DVVideo ERROR]: %@ -> %d", message, (int)status);
    }
}


@interface DVVideoError ()

@property(nonatomic, assign, readwrite) DVVideoErrorType errorType;

@end


@implementation DVVideoError

- (instancetype)initWithType:(DVVideoErrorType)errorType {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[self localDescWithType:errorType]};
    self = [super initWithDomain:self.videoDomain code:errorType userInfo:userInfo];
    if (self) {
        self.errorType = errorType;
    }
    return self;
}

+ (instancetype)errorWithType:(DVVideoErrorType)errorType {
    return [[DVVideoError alloc] initWithType:errorType];
}

- (NSErrorDomain)videoDomain {
    return @"DVVideoError";
}

- (NSString *)localDescWithType:(DVVideoErrorType)errorType {
    
    NSString *localDesc;
    
    switch (errorType) {
        case DVVideoError_notErr:
            localDesc = @"Not any error";
            break;
            
        case DVVideoError_DropSample:
            localDesc = @"Drop sample";
            break;
        
        default:
            localDesc = [NSString stringWithFormat: @"Can't identify error code:%lu",(unsigned long)self.errorType];
            break;
    }
    return [@"[DVVideo ERROR]:" stringByAppendingString:localDesc];
}

@end
