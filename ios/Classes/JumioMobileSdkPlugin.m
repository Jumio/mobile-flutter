#import "JumioMobileSdkPlugin.h"
#if __has_include(<jumio_mobile_sdk_flutter/jumio_mobile_sdk_flutter-Swift.h>)
#import <jumio_mobile_sdk_flutter/jumio_mobile_sdk_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "jumio_mobile_sdk_flutter-Swift.h"
#endif

@implementation JumioMobileSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftJumioMobileSdkPlugin registerWithRegistrar:registrar];
}
@end
