#import "KommunicateFlutterPlugin.h"
#import <kommunicate_flutter/kommunicate_flutter-Swift.h>

@implementation KommunicateFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKommunicateFlutterPlugin registerWithRegistrar:registrar];
}
@end
