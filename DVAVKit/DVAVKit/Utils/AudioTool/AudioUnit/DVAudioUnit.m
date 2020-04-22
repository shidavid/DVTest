//
//  DVAudioUnit.m
//  iOS_Test
//
//  Created by DV on 2019/1/10.
//  Copyright © 2019年 iOS. All rights reserved.
//

#import "DVAudioUnit.h"
#import "DVAudioError.h"

@interface DVAudioUnit()

@property(nonatomic, assign, readwrite) AudioUnit audioUnit;
@property(nonatomic, assign, readwrite) BOOL isRunning;
@property(nonatomic, assign) BOOL isSetup;
@property(nonatomic, strong) dispatch_queue_t audioQueue;

@property(nonatomic, strong, readwrite) DVAudioIOUnit *IO;
@property(nonatomic, strong, readwrite) DVAudioMixUnit *Mix;

@end


@implementation DVAudioUnit

#pragma mark - <-- Instancetype -->
- (instancetype)initWithComponentDesc:(AudioComponentDescription)componentDesc
                             delegate:(id<DVAudioUnitDelegate>)delegate
                                error:(NSError ** _Nullable)error {
    self = [super init];
    if (self) {
        AudioComponent component = AudioComponentFindNext(NULL, &componentDesc);
        OSStatus status = AudioComponentInstanceNew(component, &_audioUnit);
        
        if (nil != error) *error = status != noErr ? [DVAudioError errorWithType:DVAudioError_notErr] : nil;
    
        AudioCheckStatus(status, @"Init AudioComponentDescription error");
        
        
        self.delegate = delegate;
        self.isSetup = NO;
        self.isRunning = NO;
        self.audioQueue = dispatch_queue_create("my.queue.audioUnit", NULL);
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;

    _IO = nil;
    _Mix = nil;
    
    if (self.isRunning) {
        [self stop];
    }
    if (self.isSetup) {
        [self clearUnitConfig];
    }
    if (_audioUnit) {
        AudioComponentInstanceDispose(_audioUnit);
        _audioUnit = nil;
    }
}


#pragma mark - <-- getter -->
- (DVAudioIOUnit *)IO {
    if (_IO == nil) {
        _IO = [[DVAudioIOUnit alloc] init];
        [_IO setValue:self forKey:@"_wAudioUnit"];
    }
    return _IO;
}

- (DVAudioMixUnit *)Mix {
    if (_Mix == nil) {
        _Mix = [[DVAudioMixUnit alloc] init];
        [_Mix setValue:self forKey:@"_wAudioUnit"];
    }
    return _Mix;
}


#pragma mark - <-- Method -->
- (BOOL)setupUnitConfig:(void (^)(DVAudioUnit * _Nonnull))block {
    if (self.isRunning == YES) {
        NSLog(@"已开始中,请先执行 \'stop\'");
        return NO;
    }
    if (self.isSetup == YES) {
        NSLog(@"已配置,请先执行 \'clearUnitConfig\'");
        return NO;
    }
    
    if (block != nil) {
        __weak __typeof(self)weakSelf = self;
        block(weakSelf);
    }
    
    OSStatus status = AudioUnitInitialize(_audioUnit);
    AudioCheckStatus(status, @"set up AudioUnit configuration error");
    
    self.isSetup = status == noErr ? YES : NO;
    return status == noErr ? YES : NO;
}

- (BOOL)clearUnitConfig {
    if (self.isRunning == YES) {
        NSLog(@"已开始中,请先执行 \'stop\'");
        return NO;
    }
    if (self.isSetup == NO) {
        NSLog(@"未配置 AudioUnit");
        return NO;
    }
    
    OSStatus status = AudioUnitUninitialize(_audioUnit);
    AudioCheckStatus(status, @"clean AudioUnit configuration error");
    
    self.isSetup = status == noErr ? NO : YES;
    return status == noErr ? YES : NO;
}

- (BOOL)start {
    if (self.isSetup == NO) {
        NSLog(@"请先执行 \'setupUnitConfig\'");
        return NO;
    }
    if (self.isRunning == YES) {
        NSLog(@"已经开始中");
        return NO;
    }
    
    OSStatus status = AudioOutputUnitStart(_audioUnit);
    AudioCheckStatus(status, @"start error");
    
    self.isRunning = status == noErr ? YES : NO;
    return status == noErr ? YES : NO;
}

- (BOOL)stop {
    if (self.isSetup == NO) {
        NSLog(@"请先执行 \'setupUnitConfig\'");
        return NO;
    }
    if (self.isRunning == NO) {
        NSLog(@"已经停止了");
        return NO;
    }
    
    OSStatus status = AudioOutputUnitStop(_audioUnit);
    AudioCheckStatus(status, @"stop error");
    
    self.isRunning = status == noErr ? NO : YES;
    return status == noErr ? YES : NO;
}

@end

