package io.kommunicate.kommunicate_flutter_plugin;

import android.content.Context;
import android.app.Activity;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class KommunicateFlutterPlugin implements FlutterPlugin, ActivityAware {

    private MethodChannel methodChannel;
    private BinaryMessenger binaryMessenger;
    private KmEventListener kmEventListener;
    private Activity activity;

    // Remove the old registerWith method
    // public static void registerWith(Registrar registrar) {
    //     final MethodChannel channel = new MethodChannel(registrar.messenger(), "kommunicate_flutter");
    //     channel.setMethodCallHandler(new KmMethodHandler(registrar.activity()));
    //     new KmEventListener().register(channel);
    // }

    public void setupChannel(Activity context) {
        methodChannel = new MethodChannel(binaryMessenger, "kommunicate_flutter");
        methodChannel.setMethodCallHandler(new KmMethodHandler(context));
        kmEventListener = new KmEventListener();
        kmEventListener.register(methodChannel);
    }

    private void destroyChannel() {
        if (methodChannel != null) {
            methodChannel.setMethodCallHandler(null);
            methodChannel = null;
        }
        if (kmEventListener != null) {
            kmEventListener.unregister();
            kmEventListener = null;
        }
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
        activity = activityPluginBinding.getActivity();
        setupChannel(activity);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        onAttachedToActivity(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivity() {
        destroyChannel();
        activity = null;
    }
}