package io.kommunicate.kommunicate_flutter_plugin;

import android.content.Context;
import android.app.Activity;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

        public class KommunicateFlutterPlugin implements FlutterPlugin, ActivityAware  {

            private MethodChannel methodChannel;
            private BinaryMessenger binaryMessenger;
            public static void registerWith(Registrar registrar) {
                final MethodChannel channel = new MethodChannel(registrar.messenger(), "kommunicate_flutter");
                channel.setMethodCallHandler(new KmMethodHandler(registrar.activity()));
            }

            public void setupChannel(Activity context) {
                methodChannel = new MethodChannel(binaryMessenger, "kommunicate_flutter");
                methodChannel.setMethodCallHandler(new KmMethodHandler(context));
            }

            private void destroyChannel() {
                methodChannel.setMethodCallHandler(null);
                methodChannel = null;
            }

            @Override
            public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
                binaryMessenger = binding.getBinaryMessenger();
            }
            @Override
            public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
                destroyChannel();
            }

            @Override
            public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
                setupChannel(activityPluginBinding.getActivity());
            }

            @Override
            public void onDetachedFromActivityForConfigChanges() {
            }

            @Override
            public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
            }

            @Override
            public void onDetachedFromActivity() {
            }
}
