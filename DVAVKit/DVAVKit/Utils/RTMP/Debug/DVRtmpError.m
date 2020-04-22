//
//  DVRtmpError.m
//  iOS_Test
//
//  Created by DV on 2019/10/24.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVRtmpError.h"

void RtmpCheckStatus(int status, NSString *message) {
#ifdef DEBUG
    
    if (status == 0) return;
        
    char fourCC[16];
    *(UInt32 *)fourCC = CFSwapInt32HostToBig(status);
    fourCC[4] = '\0';
    if (isprint(fourCC[0]) && isprint(fourCC[1]) && isprint(fourCC[2]) && isprint(fourCC[3])) {
        NSLog(@"[DVRtmp ERROR]: %@ -> %s", message, fourCC);
    } else {
        NSLog(@"[DVRtmp ERROR]: %@ -> %d", message, (int)status);
    }
    
#endif
}


@interface DVRtmpError ()

@property(nonatomic, assign, readwrite) DVRtmpErrorType errorType;

@end


@implementation DVRtmpError

- (instancetype)initWithType:(DVRtmpErrorType)errorType {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[self localDescWithType:errorType]};
    self = [super initWithDomain:self.rtmpDomain code:errorType userInfo:userInfo];
    if (self) {
        self.errorType = errorType;
    }
    return self;
}

+ (instancetype)errorWithType:(DVRtmpErrorType)errorType {
    return [[DVRtmpError alloc] initWithType:errorType];
}

- (NSErrorDomain)rtmpDomain {
    return @"DVRtmpError";
}

- (NSString *)localDescWithType:(DVRtmpErrorType)errorType {
    
    NSString *localDesc;
    
    switch (errorType) {
        case DVRtmpErrorNotErr:
            localDesc = @"Not any error";
            break;
            
        case DVRtmpErrorFailToSendPacket:
            localDesc = @"Send Packet Fail";
            break;
        
        default:
            localDesc = [NSString stringWithFormat: @"Can't identify error code:%lu",(unsigned long)self.errorType];
            break;
    }
    return [@"[DVRtmp ERROR]:" stringByAppendingString:localDesc];
}

@end
