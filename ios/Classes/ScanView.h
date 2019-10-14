#import <Flutter/Flutter.h>

@interface ScanView : NSObject<FlutterPlatformView>

+ (instancetype)initWithMessenger:(NSObject <FlutterBinaryMessenger> *)messenger viewIdentifier:(int64_t)viewId;

@end
