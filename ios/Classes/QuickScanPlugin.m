#import "QuickScanPlugin.h"
#import "ScanViewFactory.h"

@implementation QuickScanPlugin
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    ScanViewFactory *scanViewFactory = [ScanViewFactory initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:scanViewFactory withId:@"scan_view"];
}

@end
