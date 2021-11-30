package io.kommunicate.kommunicate_flutter_plugin;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.text.TextUtils;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.kommunicate.KmConversationBuilder;
import io.kommunicate.KmSettings;
import io.kommunicate.Kommunicate;
import io.kommunicate.async.KmConversationInfoTask;
import io.kommunicate.callbacks.KMLoginHandler;
import io.kommunicate.callbacks.KMLogoutHandler;
import io.kommunicate.callbacks.KmCallback;
import io.kommunicate.callbacks.KmGetConversationInfoCallback;
import io.kommunicate.users.KMUser;
import io.kommunicate.KmConversationHelper;
import io.kommunicate.KmException;

import com.applozic.mobicomkit.api.account.user.AlUserUpdateTask;
import com.applozic.mobicomkit.api.conversation.database.MessageDatabaseService;
import com.applozic.mobicomkit.channel.service.ChannelService;
import com.applozic.mobicomkit.feed.ChannelFeedApiResponse;
import com.applozic.mobicomkit.listners.AlCallback;
import com.applozic.mobicommons.json.GsonUtils;
import com.applozic.mobicomkit.api.account.register.RegistrationResponse;
import com.applozic.mobicommons.people.channel.Channel;
import com.applozic.mobicommons.people.contact.Contact;
import com.applozic.mobicomkit.uiwidgets.conversation.fragment.MobiComConversationFragment;

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
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "kommunicate_flutter");
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
        } else if (call.method.equals("isLoggedIn")) {
            result.success(Kommunicate.isLoggedIn(context));
        } else if (call.method.equals("login")) {
            KMUser user = (KMUser) GsonUtils.getObjectFromJson(call.arguments.toString(), KMUser.class);

            if (call.hasArgument("appId") && !TextUtils.isEmpty((String) call.argument("appId"))) {
                Kommunicate.init(context, (String) call.argument("appId"));
            } else {
                result.error(ERROR, "appId is missing", null);
                return;
            }

            Kommunicate.login(context, user, new KMLoginHandler() {
                @Override
                public void onSuccess(RegistrationResponse registrationResponse, Context context) {
                    result.success(GsonUtils.getJsonFromObject(registrationResponse, RegistrationResponse.class));
                }

                @Override
                public void onFailure(RegistrationResponse registrationResponse, Exception exception) {
                    result.error(ERROR, registrationResponse != null ? GsonUtils.getJsonFromObject(registrationResponse, RegistrationResponse.class) : exception != null ? exception.getMessage() : null, null);
                }
            });
        } else if (call.method.equals("loginAsVisitor")) {
            String appId = (String) call.arguments();
            if (!TextUtils.isEmpty(appId)) {
                Kommunicate.init(context, appId);
            } else {
                result.error(ERROR, "appId is missing", null);
                return;
            }

            Kommunicate.loginAsVisitor(context, new KMLoginHandler() {
                @Override
                public void onSuccess(RegistrationResponse registrationResponse, Context context) {
                    result.success(GsonUtils.getJsonFromObject(registrationResponse, RegistrationResponse.class));
                }

                @Override
                public void onFailure(RegistrationResponse registrationResponse, Exception exception) {
                    result.error(ERROR, registrationResponse != null ? GsonUtils.getJsonFromObject(registrationResponse, RegistrationResponse.class) : exception != null ? exception.getMessage() : null, null);
                }
            });
        } else if (call.method.equals("openConversations")) {
            Kommunicate.openConversation(context, new KmCallback() {
                @Override
                public void onSuccess(Object message) {
                    result.success(message.toString());
                }

                @Override
                public void onFailure(Object error) {
                    result.error(ERROR, error.toString(), null);
                }
            });
        } else if (call.method.equals("openParticularConversation")) {
            final String clientConversationId = (String) call.arguments;
            if (TextUtils.isEmpty(clientConversationId)) {
                result.error(ERROR, "Invalid or empty clientConversationId", null);
                return;
            }

            new KmConversationInfoTask(context, clientConversationId, new KmGetConversationInfoCallback() {
                @Override
                public void onSuccess(Channel channel, Context context) {
                    if (channel != null) {
                        try {
                            KmConversationHelper.openConversation(context, true, channel.getKey(), new KmCallback() {
                                @Override
                                public void onSuccess(Object message) {
                                    result.success(message.toString());
                                }

                                @Override
                                public void onFailure(Object error) {
                                    result.error(ERROR, error.toString(), null);
                                }
                            });
                        } catch (KmException k) {
                            result.error(ERROR, k.getMessage(), null);
                        }
                    }
                }

                @Override
                public void onFailure(Exception e, Context context) {
                    try {
                        Kommunicate.openConversation(context, Integer.valueOf(clientConversationId), new KmCallback() {
                            @Override
                            public void onSuccess(Object message) {
                                result.success(message.toString());
                            }

                            @Override
                            public void onFailure(Object error) {
                                result.error(ERROR, error.toString(), null);
                            }
                        });
                    } catch (NumberFormatException ex) {
                        result.error(ERROR, "Invalid Conversation ID / Channel Key", null);
                    }
                }
            }).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
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
                    Integer conversationId = (Integer) message;
                    result.success(ChannelService.getInstance(context).getChannel(conversationId).getClientGroupId());
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
                    }).execute();
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
        } else if (call.method.equals("unreadCount")) {
            result.success(String.valueOf(new MessageDatabaseService(context).getTotalUnreadCount()));
        } else if(call.method.equals("fetchUserDetails")) {
            try {
                new MobiComConversationFragment.KMUserDetailTask(context, call.arguments.toString(), new MobiComConversationFragment.KmUserDetailsCallback() {
                    @Override
                    public void hasFinished(Contact contact) {
                        result.success(GsonUtils.getJsonFromObject(contact, Contact.class));
                    }
                }).execute();
            } catch (Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        }
        else {
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
