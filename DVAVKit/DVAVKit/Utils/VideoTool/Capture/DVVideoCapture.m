//
//  DVVideoCapture.m
//  iOS_Test
//
//  Created by DV on 2019/9/27.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "DVVideoCapture.h"

@interface DVVideoCapture () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, assign) BOOL lastRunning;
@property(nonatomic, strong) DVVideoConfig *config;
@property(nonatomic, strong, readwrite) UIView *preView;
@property(nonatomic, strong, readwrite) DVVideoCamera *camera;

@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureDevice *videoDevice;
@property(nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property(nonatomic, strong) AVCaptureConnection *videoConnection;
@property(nonatomic, strong, readwrite) AVCaptureVideoPreviewLayer *preViewLayer;

@property(nonatomic, strong) dispatch_queue_t videoQueue;

@end



@implementation DVVideoCapture

#pragma mark - <-- Initializer -->
- (instancetype)initWithConfig:(DVVideoConfig *)config delegate:(id<DVVideoCaptureDelegate>)delegate {
    self = [super init];
    if (self) {
        self.config = config;
        self.delegate = delegate;
    
        [self initSession];
        [self updateConfig:config];
        [self addNotification];
    }
    return self;
}

- (void)dealloc {
    if (_session && _session.running) {
        [_session stopRunning];
        _session = nil;
    }
    
    _delegate = nil;
    _videoQueue = nil;
    [self removeNotification];
    
    if (_preViewLayer) {
        [_preViewLayer removeFromSuperlayer];
        _preViewLayer = nil;
    }
    
    if (_preView) {
        [_preView removeObserver:self forKeyPath:@"frame" context:nil];
        [_preView removeObserver:self forKeyPath:@"bounds" context:nil];
        [_preView removeFromSuperview];
        _preView = nil;
    }
}


#pragma mark - <-- Init -->
- (void)initSession {
    
    // 1.获取设备
    self.videoDevice = [self getCameraWithPosition:self.config.position];
    
    // 2.初始化输入
    NSError *error = nil;
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
    if (error) {
        NSLog(@"[DVVideoCapture ERROR]: 无法初始化摄像头输入 error-> %@",error.localizedDescription);
        return;
    }
    
    // 3.初始化输出
    self.videoQueue = dispatch_queue_create("com.queue.videoOutput", DISPATCH_QUEUE_SERIAL);
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.videoOutput setSampleBufferDelegate:self queue:self.videoQueue];
    self.videoOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]};
    
    // 4.初始化会话,添加输入输出
    self.session = [[AVCaptureSession alloc] init];
    [self.session beginConfiguration];
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
    [self.session commitConfiguration];
    
    // 5.获取输出连接
    self.videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    self.videoConnection.videoMirrored = (self.config.position == AVCaptureDevicePositionFront
                                          && self.videoConnection.isVideoMirroringSupported);
}


#pragma mark - <-- Lazy Property -->
- (void)setSession:(AVCaptureSession *)session {
    _session = session;
    [self.camera setValue:session forKey:@"_wSession"];
}

- (void)setVideoDevice:(AVCaptureDevice *)videoDevice {
    _videoDevice = videoDevice;
    [self.camera setValue:videoDevice forKey:@"_wDevice"];
}

- (void)setVideoOutput:(AVCaptureVideoDataOutput *)videoOutput {
    _videoOutput = videoOutput;
    [self.camera setValue:videoOutput forKey:@"_wOutput"];
}

- (void)setVideoConnection:(AVCaptureConnection *)videoConnection {
    _videoConnection = videoConnection;
    [self.camera setValue:videoConnection forKey:@"_wConnect"];
}

- (AVCaptureVideoPreviewLayer *)preViewLayer {
    if (_preViewLayer == nil) {
        _preViewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _preViewLayer;
}

- (UIView *)preView {
    if (_preView == nil) {
        _preView = [[UIView alloc] init];
        [_preView.layer addSublayer:self.preViewLayer];
        [_preView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        [_preView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _preView;
}

- (DVVideoCamera *)camera {
    if (_camera == nil) {
        _camera = [[DVVideoCamera alloc] init];
    }
    return _camera;
}


#pragma mark - <-- Property -->
- (BOOL)isRunning {
    return self.session.isRunning;
}


#pragma mark - <-- Private Method -->
- (AVCaptureDevice *)getCameraWithPosition:(AVCaptureDevicePosition)position {
    AVCaptureDevice *device = nil;
    NSArray<AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType: AVMediaTypeVideo];
       
    for (AVCaptureDevice *tempDevice in devices) {
        if ([tempDevice position] == position) {
            device = tempDevice;
            break;
        }
    }
    
    if (!device) {
        NSLog(@"[DVVideoCapture ERROR]: 寻找不到%@摄像头",position == AVCaptureDevicePositionFront ? @"前" : @"后");
    }
    
    return device;
}

- (void)changeCameraWithPosition:(AVCaptureDevicePosition)position {
    if (position == AVCaptureDevicePositionUnspecified) return;
    if (self.videoDevice.position == position) return;
    
    AVCaptureDevice *newDevice = [self getCameraWithPosition:position];
    if (!newDevice) return;
    
    NSError *error;
    AVCaptureDeviceInput *oldVideoInput = self.videoInput;
    AVCaptureDeviceInput *newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:&error];
    if (error) {
        NSLog(@"[DVVideoCapture ERROR]: 无法切换摄像头 error-> %@",error.localizedDescription);
        return;
    }
    
    [self.session beginConfiguration];

    [self.session removeInput:oldVideoInput];
    if ([self.session canAddInput:newVideoInput]) {
        [self.session addInput:newVideoInput];
        self.videoDevice = newDevice;
        self.videoInput = newVideoInput;
        self.videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
        self.videoConnection.videoMirrored = (newDevice.position == AVCaptureDevicePositionFront
                                              && self.videoConnection.isVideoMirroringSupported);
        self.config.position = position;
    } else {
        [self.session addInput:oldVideoInput];
    }
    
    __weak __typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)),
                   dispatch_get_global_queue(0, 0), ^{
        [weakSelf.session commitConfiguration];
    });
}


#pragma mark - <-- Public Method -->
- (void)start {
    if (self.isRunning) {
        NSLog(@"[DVVideoCapture ERROR]: 摄像头已经开启");
        return;
    }
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.videoQueue, ^{
        [weakSelf.session startRunning];
    });
}

- (void)stop {
    if (!self.isRunning) {
        NSLog(@"[DVVideoCapture ERROR]: 摄像头已经关闭");
        return;
    }
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.videoQueue, ^{
        [weakSelf.session stopRunning];
    });
}

- (void)updateConfig:(DVVideoConfig *)config {
    self.config = config;
    
    if (self.session.inputs.count > 0) {
        [self changeCameraWithPosition:config.position];
    }
    
    do {
        NSError *error;
        [self.videoDevice lockForConfiguration:&error];
        if (error) {
            NSLog(@"[DVVideoCapture ERROR]: 无法配置摄像头, error-> %@",error.localizedDescription);
            break;
        }

        self.camera.sessionPreset = config.sessionPreset;
        self.camera.orientation = config.orientation;
        self.camera.fps = config.fps;
        self.camera.bitRate = config.bitRate;
        self.camera.alwaysDiscardsLateVideoFrames = NO;
        
    } while (NO);
    
    [self.videoDevice unlockForConfiguration];
}

- (void)updateCamera:(void (^)(DVVideoCamera * _Nonnull))block {
    
    do {
        NSError *error;
        [self.videoDevice lockForConfiguration:&error];
        
        if (error) {
            NSLog(@"[DVVideoCapture ERROR]: 无法配置摄像头, error-> %@",error.localizedDescription);
            break;
        }
        
        block(self.camera);
        
    } while (NO);
    
    [self.videoDevice unlockForConfiguration];
}

- (void)changeToFrontCamera {
    [self changeCameraWithPosition:AVCaptureDevicePositionFront];
    [self updateConfig:self.config];
}

- (void)changeToBackCamera {
    [self changeCameraWithPosition:AVCaptureDevicePositionBack];
    [self updateConfig:self.config];
}



#pragma mark - <-- KVO -->
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([object isEqual:self.preView]) {
        if ([keyPath isEqualToString:@"frame"]) {
            self.preViewLayer.frame = self.preView.frame;
        }
        else if ([keyPath isEqualToString:@"bounds"]) {
            self.preViewLayer.bounds = self.preView.bounds;
        }
    }
}


#pragma mark - <-- Delegate -->
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                                       fromConnection:(AVCaptureConnection *)connection {
    if (self.delegate) {
        [self.delegate DVVideoCapture:self outputSampleBuffer:sampleBuffer error:nil];
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                                     fromConnection:(AVCaptureConnection *)connection {
    if (self.delegate) {
        DVVideoError *error = [DVVideoError errorWithType:DVVideoError_DropSample];
        [self.delegate DVVideoCapture:self outputSampleBuffer:sampleBuffer error:error];
    }
}


#pragma mark - <-- Notification -->
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarChanged:)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillChangeStatusBarOrientationNotification
                                                  object:nil];
}

- (void)willEnterBackground:(NSNotification *)notification {
    self.lastRunning = self.isRunning;
    if (self.lastRunning) [self stop];
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (self.lastRunning) [self start];
}

- (void)statusBarChanged:(NSNotification *)notification {
    NSLog(@"UIApplicationWillChangeStatusBarOrientationNotification. UserInfo: %@", notification.userInfo);
    UIInterfaceOrientation statusBar = [[UIApplication sharedApplication] statusBarOrientation];

    if(self.camera.isAutoRotate){
        if (self.camera.isLandscape) {
            self.camera.orientation = (statusBar == UIInterfaceOrientationLandscapeLeft) ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationLandscapeLeft;
        } else {
            self.camera.orientation = (statusBar == UIInterfaceOrientationPortrait) ? UIInterfaceOrientationPortraitUpsideDown : UIInterfaceOrientationPortrait;
        }
    }
}

@end
