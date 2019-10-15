#import "ScanView.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanView ()
@property(nonatomic, strong) UIView *preview;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong) AVCaptureSession *session;
@end

@implementation ScanView
+ (instancetype)initWithMessenger:(NSObject <FlutterBinaryMessenger> *)messenger viewIdentifier:(int64_t)viewId {
    ScanView *scanView = [ScanView new];
    [scanView initPreview];
    [scanView initSession];
    return scanView;
}

- (void)initPreview {
    self.preview = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.preview.backgroundColor = [UIColor clearColor];

    self.previewLayer = [AVCaptureVideoPreviewLayer new];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // FIXME self.previewLayer.bounds = self.preview.bounds;
    self.previewLayer.frame = self.preview.frame;
    [self.preview.layer addSublayer:self.previewLayer];
}

- (void)initSession {
    self.session = [AVCaptureSession new];
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    NSError *e;
    [self.session addInput:[AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&e]];
    [self.previewLayer setSession:self.session];

    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    [self.session startRunning];
}

- (UIView *)view {
    //  TODO：Bounds need to be set
    return self.preview;
}

- (void)dealloc {
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
}
@end
