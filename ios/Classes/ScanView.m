#import "ScanView.h"
#import "QuickScanPlugin.h"
#import "Preview.h"

@implementation ScanView
+ (instancetype)initWithMessenger:(NSObject <FlutterBinaryMessenger> *)messenger viewIdentifier:(int64_t)viewId {
    return [ScanView new];
}

- (UIView *)view {
    //  注：相机部分frame(x, y, w, h);x与y相对于flutter中widget的位置；w与h时native的size
    //  TODO：flutter需传入w、h
    return [[Preview alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
}
@end
