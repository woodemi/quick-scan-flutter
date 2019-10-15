#import "ScanView.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanView () <FlutterStreamHandler, AVCaptureMetadataOutputObjectsDelegate>
@property(nonatomic, strong) FlutterEventSink scanResultSink;
@property(nonatomic, strong) UIView *preview;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property(nonatomic, strong) AVCaptureSession *session;
@end

@implementation ScanView
+ (instancetype)initWithMessenger:(NSObject <FlutterBinaryMessenger> *)messenger viewIdentifier:(int64_t)viewId {
    ScanView *scanView = [ScanView new];
    NSString *eventChannelName = [@"quick_scan" stringByAppendingFormat:@"/scanview_%lld/event", viewId];
    [[FlutterEventChannel eventChannelWithName:eventChannelName binaryMessenger:messenger] setStreamHandler:scanView];
    [scanView initPreview];
    [scanView initMetadataOutput];
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

- (void)initMetadataOutput {
    self.metadataOutput = [AVCaptureMetadataOutput new];
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.metadataOutput.rectOfInterest = [self.previewLayer metadataOutputRectOfInterestForRect:self.previewLayer.bounds];
}

- (void)initSession {
    self.session = [AVCaptureSession new];
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    NSError *e;
    [self.session addInput:[AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&e]];
    [self.previewLayer setSession:self.session];
    [self.session addOutput:self.metadataOutput];
    // https://stackoverflow.com/questions/26244714/avfoundation-metadata-object-types
    self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];

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

#pragma mark - FlutterStreamHandler

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)events {
    self.scanResultSink = events;
    return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.scanResultSink = nil;
    return nil;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray<AVMetadataMachineReadableCodeObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count >= 0 && self.scanResultSink) {
        self.scanResultSink([metadataObjects.firstObject stringValue]);
    }
}
@end
