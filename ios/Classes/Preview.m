//
//  Preview.m
//  quick_scan
//
//  Created by Larry_iMac on 2019/10/14.

#import "Preview.h"
#import <AVFoundation/AVFoundation.h>

@interface Preview () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *dataOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation Preview
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self startScanning];
    }
    return self;
}

- (void)configCameraAndStart{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        self.dataOutput = [[AVCaptureMetadataOutput alloc] init];
        [self.dataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        self.session = [[AVCaptureSession alloc] init];
        if ([self.device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
        }else {
            [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        }
        if ([self.session canAddInput:self.deviceInput]){
            [self.session addInput:self.deviceInput];
        }
        if ([self.session canAddOutput:self.dataOutput]){
            [self.session addOutput:self.dataOutput];
        }
        if (![self.dataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            NSLog(@"The camera unsupport for QRCode.");
        }
        self.dataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.previewLayer.frame = self.frame;
            [self.layer insertSublayer:self.previewLayer atIndex:0];
            [self.session startRunning];
            self.dataOutput.rectOfInterest = [self.previewLayer metadataOutputRectOfInterestForRect: self.bounds];
        });
    });
}

- (void)startScanning{
    if (![self statusCheck]) {
        return;
    }
    if (!self.session) {
        [self configCameraAndStart];
        return;
    }
    if (self.session.isRunning){
        return;
    }
    [self.session startRunning];
}

- (void)stopScanning{
    if (!self.session.isRunning){
        return;
    }
    [self.session stopRunning];
}

#pragma mark - 权限判断
- (BOOL)statusCheck{
    if (![self isCameraAvailable]){
        NSString *str = @"设备无相机——设备无相机功能，无法进行扫描";
        NSLog(@"缺少权限 = %@", str);   //  TODO：传给flutter
        return NO;
    }
    if (![self isRearCameraAvailable] && ![self isFrontCameraAvailable]) {
        NSString *str = @"设备相机错误——无法启用相机，请检查";
        NSLog(@"缺少权限 = %@", str);   //  TODO：传给flutter
        return NO;
    }
    if (![self isCameraAuthStatusCorrect]) {
        NSString *str = @"未打开相机权限 ——请在“设置-隐私-相机”选项中，允许滴滴访问你的相机";
        NSLog(@"缺少权限 = %@", str);   //  TODO：传给flutter
        return NO;
    }
    return YES;
}

- (BOOL)isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL)isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL)isCameraAuthStatusCorrect{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined) {
        return YES;
    }
    return NO;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray<AVMetadataMachineReadableCodeObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count == 0) {
        return;
    }
    NSString *result = [metadataObjects.firstObject stringValue];
    NSLog(@"识别result = %@", result);    //  TODO：传给flutter
}

@end
