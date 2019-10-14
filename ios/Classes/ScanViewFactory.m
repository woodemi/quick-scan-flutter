#import "ScanViewFactory.h"
#import "ScanView.h"

@interface ScanViewFactory()

@property (nonatomic, strong)NSObject <FlutterBinaryMessenger> *messenger;

@end

@implementation ScanViewFactory
+ (id)initWithMessenger:(NSObject <FlutterBinaryMessenger> *)messenger {
    ScanViewFactory *scanViewFactory = [ScanViewFactory new];
    scanViewFactory.messenger = messenger;
    return scanViewFactory;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject <FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
    ScanView *view = [ScanView initWithMessenger:_messenger viewIdentifier:viewId];
    return view;
}
@end
