//
//  RecordViewController.m
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/9/11.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import "RecordViewController.h"

@interface RecordViewController () <DVAudioUnitDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;

@property(nonatomic, strong) DVAudioUnit *audioUnit;

@property(nonatomic, strong) NSFileHandle *fileHandle;
@property(nonatomic, strong) dispatch_queue_t fileQueue;
@property(nonatomic, copy) NSString *recordPath;

@end


@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"录音";
    
    NSString *docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    self.recordPath = [docuPath stringByAppendingPathComponent:@"record.pcm"];
    
    [self initSession];
    [self initAudioUnit];
}

- (void)initSession {
    
    
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [audioSession setActive:YES error:&error];
}

- (void)initAudioUnit {
    
    AudioComponentDescription compDesc = [DVAudioComponentDesc kComponentDesc_Output_IO];
    
    DVAudioConfig *audioConfig = [DVAudioConfig kConfig_16k_16bit_2ch];
    AudioStreamBasicDescription basicDesc = [DVAudioStreamBaseDesc pcmBasicDescWithConfig:audioConfig];
    
    NSError *error = nil;
    self.audioUnit = [[DVAudioUnit alloc] initWithComponentDesc:compDesc
                                                       delegate:self
                                                          error:&error];
    [self.audioUnit setupUnitConfig:^(DVAudioUnit * _Nonnull au) {
        au.IO.audioFormat = basicDesc;
        au.IO.inputPortStatus = YES;
        au.IO.inputCallBackSwitch = YES;
        au.IO.outputPortStatus = YES;
        au.IO.bypassVoiceProcessingStatus = YES;
    }];
    
}

- (void)initAudioPlayer {
    
}


#pragma mark - <-- Method -->
- (dispatch_queue_t)fileQueue {
    if (!_fileQueue) {
        _fileQueue = dispatch_queue_create("com.dv.avkit.live.record", nil);
    }
    return _fileQueue;
}

- (NSFileHandle *)fileHandle {
    if (!_fileHandle && _recordPath) {
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_recordPath];
        [self.fileHandle seekToEndOfFile];
    }
    return _fileHandle;
}

- (void)createFileAtPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
       NSError *error;
       [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
   }
   
   [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}


#pragma mark - <-- Delegate -->
- (void)DVAudioUnit:(DVAudioUnit *)audioUnit recordData:(NSData *)data error:(DVAudioError *)error {
    
    dispatch_async(self.fileQueue, ^{
        [self.fileHandle writeData:data];
    });
}


#pragma mark - <-- Response -->
- (IBAction)onClickForRecord:(UIButton *)sender {
//    if (self.btnPlay.selected) return;
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self createFileAtPath:self.recordPath];
        [self.audioUnit start];
    } else {
        [self.audioUnit stop];
    }
}

- (IBAction)onClickForPlay:(UIButton *)sender {
    
}

@end
