#import "KommunicateFlutterPlugin.h"
#import <kommunicate_flutter_plugin/kommunicate_flutter_plugin-Swift.h>

@implementation KommunicateFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKommunicateFlutterPlugin registerWithRegistrar:registrar];
}
@end
