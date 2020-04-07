package io.kommunicate.kommunicate_flutter_plugin;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.kommunicate.KmConversationBuilder;
import io.kommunicate.KmSettings;
import io.kommunicate.Kommunicate;
import io.kommunicate.callbacks.KMLogoutHandler;
import io.kommunicate.callbacks.KmCallback;
import io.kommunicate.users.KMUser;

import com.applozic.mobicomkit.api.account.user.AlUserUpdateTask;
import com.applozic.mobicomkit.feed.ChannelFeedApiResponse;
import com.applozic.mobicomkit.listners.AlCallback;
import com.applozic.mobicommons.json.GsonUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * KommunicateFlutterPlugin
 */
public class KommunicateFlutterPlugin implements MethodCallHandler {
    /**
     * Plugin registration.
     */
    private static final String SUCCESS = "Success";
    private static final String ERROR = "Error";
    private Activity context;
    private MethodChannel methodChannel;

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "kommunicate_flutter_plugin");
        channel.setMethodCallHandler(new KommunicateFlutterPlugin(registrar.activity(), channel));
    }

    public KommunicateFlutterPlugin(Activity activity, MethodChannel methodChannel) {
        this.context = activity;
        this.methodChannel = methodChannel;
        this.methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, final Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("buildConversation")) {

            KmConversationBuilder conversationBuilder = (KmConversationBuilder) GsonUtils.getObjectFromJson(call.arguments.toString(), KmConversationBuilder.class);
            conversationBuilder.setContext(context);

            if (!call.hasArgument("isSingleConversation")) {
                conversationBuilder.setSingleConversation(true);
            }
            if (!call.hasArgument("skipConversationList")) {
                conversationBuilder.setSkipConversationList(true);
            }

            KmCallback callback = new KmCallback() {
                @Override
                public void onSuccess(Object message) {
                    result.success(message);
                }

                @Override
                public void onFailure(Object error) {
                    result.error(ERROR, error != null ? (error instanceof ChannelFeedApiResponse ? GsonUtils.getJsonFromObject(error, ChannelFeedApiResponse.class) : error.toString()) : "Some internal error occurred", null);
                }
            };

            if (call.hasArgument("createOnly") && (boolean) call.argument("createOnly")) {
                conversationBuilder.createConversation(callback);
            } else if (call.hasArgument("launchAndCreateIfEmpty") && (boolean) call.argument("launchAndCreateIfEmpty")) {
                conversationBuilder.launchAndCreateIfEmpty(callback);
            } else {
                conversationBuilder.launchConversation(callback);
            }
        } else if (call.method.equals("updateChatContext")) {
            try {
                HashMap<String, Object> chatContext = (HashMap<String, Object>) GsonUtils.getObjectFromJson(call.arguments.toString(), HashMap.class);
                if (Kommunicate.isLoggedIn(context)) {
                    KmSettings.updateChatContext(context, getStringMap(chatContext));
                    result.success(SUCCESS);
                } else {
                    result.error(ERROR, "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the chatContext", null);
                }
            } catch (Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        } else if (call.method.equals("updateUserDetail")) {
            try {
                if (KMUser.isLoggedIn(context)) {
                    KMUser kmUser = (KMUser) GsonUtils.getObjectFromJson(GsonUtils.getJsonFromObject(call.arguments, Object.class), KMUser.class);
                    new AlUserUpdateTask(context, kmUser, new AlCallback() {
                        @Override
                        public void onSuccess(Object message) {
                            result.success(SUCCESS);
                        }

                        @Override
                        public void onError(Object error) {
                            result.error(ERROR, "Unable to update user details", null);
                        }
                    }).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
                } else {
                    result.error(ERROR, "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the user details", null);
                }
            } catch (Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        } else if (call.method.equals("logout")) {
            Kommunicate.logout(context, new KMLogoutHandler() {
                @Override
                public void onSuccess(Context context) {
                    result.success(SUCCESS);
                }

                @Override
                public void onFailure(Exception exception) {
                    result.error(ERROR, GsonUtils.getJsonFromObject(exception, Exception.class), null);
                }
            });
        } else {
            result.notImplemented();
        }
    }

    private Map<String, String> getStringMap(HashMap<String, Object> objectMap) {
        if (objectMap == null) {
            return null;
        }
        Map<String, String> newMap = new HashMap<>();
        for (Map.Entry<String, Object> entry : objectMap.entrySet()) {
            newMap.put(entry.getKey(), entry.getValue() instanceof String ? (String) entry.getValue() : entry.getValue().toString());
        }
        return newMap;
    }
}
