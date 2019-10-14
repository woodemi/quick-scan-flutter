#import "ScanView.h"
#import "QuickScanPlugin.h"

@implementation ScanView
+ (instancetype)initWithMessenger:(NSObject <FlutterBinaryMessenger> *)messenger viewIdentifier:(int64_t)viewId {
    return [ScanView new];
}

- (UIView *)view {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor greenColor];    //  TODO 
    return view;
}
@end
