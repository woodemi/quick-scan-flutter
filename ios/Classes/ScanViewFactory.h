#import <Flutter/Flutter.h>

@interface ScanViewFactory : NSObject<FlutterPlatformViewFactory>

+ (id)initWithMessenger:(NSObject <FlutterBinaryMessenger> *)messenger;

@end
