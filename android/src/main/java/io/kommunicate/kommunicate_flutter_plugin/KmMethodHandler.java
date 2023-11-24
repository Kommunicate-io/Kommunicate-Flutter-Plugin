package io.kommunicate.kommunicate_flutter_plugin;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.text.TextUtils;
import java.util.List;
import java.util.ArrayList;

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
import com.applozic.mobicomkit.api.account.user.User;
import com.applozic.mobicomkit.ApplozicClient;
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
import com.applozic.mobicomkit.api.conversation.AlTotalUnreadCountTask;
import io.kommunicate.preference.KmConversationInfoSetting;
import com.applozic.mobicomkit.broadcast.AlEventManager;
import com.applozic.mobicomkit.api.conversation.MessageBuilder;

import java.util.HashMap;
import java.util.Map;
import org.json.JSONObject;
/**
 * KommunicateFlutterPlugin
 */
public class KmMethodHandler implements MethodCallHandler {
    /**
     * Plugin registration.
     */
    private static final String SUCCESS = "Success";
    private static final String ERROR = "Error";
    private Activity context;
    private MethodChannel methodChannel;

    public KmMethodHandler(Activity context) {
        this.context = context;
    }

    @Override
    public void onMethodCall(MethodCall call, final Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("isLoggedIn")) {
            result.success(Kommunicate.isLoggedIn(context));
        } else if (call.method.equals("login")) {
            try {
                JSONObject userObject = new JSONObject(call.arguments.toString());
                KMUser user = (KMUser) GsonUtils.getObjectFromJson(userObject.toString(), KMUser.class);

                if (userObject.has("appId") && !TextUtils.isEmpty(userObject.get("appId").toString())) {
                    Kommunicate.init(context, userObject.get("appId").toString());
                } else {
                    result.error(ERROR, "appId is missing", null);
                    return;
                }
                user.setPlatform(User.Platform.FLUTTER.getValue());
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
            } catch (Exception e) {
                    result.error(ERROR, e.toString(), null);
                }
        } else if (call.method.equals("updatePrefilledText")) {
            try {
                String preFilledText = (String) call.arguments();
                Kommunicate.setChatText(context,preFilledText);
            } catch (Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        } else if (call.method.equals("updateUserLanguage")) {
            try {
                final String languageCode = (String) call.arguments();
                KmSettings.updateUserLanguage(context, languageCode);
            } catch (Exception e) {
                result.error(ERROR, e.getMessage(), null);
            }
        } else if (call.method.equals("sendMessage")) {
            try {
                JSONObject messageObject = new JSONObject(call.arguments.toString());
                if (messageObject.has("channelID") && !TextUtils.isEmpty(messageObject.get("channelID").toString()) && messageObject.has("message") && !TextUtils.isEmpty(messageObject.get("message").toString())) {
                    final String Message = messageObject.get("message").toString();
                    final String ConversationId = messageObject.get("channelID").toString();
                    new MessageBuilder(context)
                    .setMessage(Message)
                    .setClientGroupId(ConversationId)
                    .send();
                }
                
            } catch (Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        } else if (call.method.equals("loginAsVisitor")) {
            try {
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
        } catch (Exception e) {
            result.error(ERROR, e.toString(), null);
        }
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
        } else if (call.method.equals("getConversarionIdOrKey")) {
            try {
            JSONObject conversationIdObjc = new JSONObject(call.arguments.toString());
            if (conversationIdObjc.has("channelID") && !TextUtils.isEmpty(conversationIdObjc.get("channelID").toString())) {
                final String searchChannelID = conversationIdObjc.get("channelID").toString();
            
                new KmConversationInfoTask(context, Integer.valueOf(searchChannelID), new KmGetConversationInfoCallback() {
                    @Override
                    public void onSuccess(Channel channel, Context context) {
                        if (channel != null) {
                           result.success(String.valueOf(channel.getClientGroupId()));
                        } else {
                           result.error(ERROR, "Conversation Not Found", null);
                        }
                    }
                    @Override
                    public void onFailure(Exception e, Context context) {
                        result.error(ERROR, e != null ? e.getMessage() : "Invalid channelID", null);
                    }  
                }).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
            } else if (conversationIdObjc.has("clientChannelKey") && !TextUtils.isEmpty(conversationIdObjc.get("clientChannelKey").toString())) {
                final String searchClientChannelKey = conversationIdObjc.get("clientChannelKey").toString();
                

                new KmConversationInfoTask(context, searchClientChannelKey, new KmGetConversationInfoCallback() {
                    @Override
                    public void onSuccess(Channel channel, Context context) {
                        if (channel != null) {
                           result.success(String.valueOf(channel.getKey()));
                        } else {
                           result.error(ERROR, "Conversation Not Found", null);
                        }
                    }
                    @Override
                    public void onFailure(Exception e, Context context) {
                        result.error(ERROR, e != null ? e.getMessage() : "Invalid clientChannelKey", null);
                    }  
                }).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
            } else {
                result.error(ERROR, "Object doesn't contain 'clientChannelKey' or 'channelID'", null);
            }
        } catch (Exception e) {
            result.error(ERROR, e.getMessage(), null);
        }
        } else if (call.method.equals("openParticularConversation")) {
            try {
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
                    new KmConversationInfoTask(context, Integer.valueOf(clientConversationId), new KmGetConversationInfoCallback() {
                        @Override
                        public void onSuccess(Channel channel, Context context) {
                            if (channel != null) {

                                    Kommunicate.openConversation(context, channel.getKey(), new KmCallback() {
                                        @Override
                                        public void onSuccess(Object message) {
                                            result.success(message.toString());
                                        }

                                        @Override
                                        public void onFailure(Object error) {
                                            result.error(ERROR, error.toString(), null);
                                        }
                                    });

                            }
                        }

                        @Override
                        public void onFailure(Exception e, Context context) {
                            result.error(ERROR, e != null ? e.getMessage() : "Invalid conversationId", null);
                        }
                    }).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
                }
            }).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
        } catch (Exception e) {
            result.error(ERROR, e.toString(), null);
        }
        } else if (call.method.equals("buildConversation")) {
            try {
                JSONObject conversationObject = new JSONObject(call.arguments.toString());
                KmConversationBuilder conversationBuilder = (KmConversationBuilder) GsonUtils.getObjectFromJson(conversationObject.toString(), KmConversationBuilder.class);
                conversationBuilder.setContext(context);

                if (!conversationObject.has("isSingleConversation")) {
                    conversationBuilder.setSingleConversation(true);
                }
                if (!conversationObject.has("skipConversationList")) {
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
                
                if (conversationObject.has("createOnly") && (boolean) conversationObject.get("createOnly")) {
                    conversationBuilder.createConversation(callback);
                } else if (conversationObject.has("launchAndCreateIfEmpty") && (boolean) conversationObject.get("launchAndCreateIfEmpty")) {
                    conversationBuilder.launchAndCreateIfEmpty(callback);
                } else {
                    conversationBuilder.launchConversation(callback);
                }
            } catch (Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        } else if (call.method.equals("updateChatContext")) {
            try {
                JSONObject chatContextObject = new JSONObject(call.arguments.toString());
                HashMap<String, Object> chatContext = (HashMap<String, Object>) GsonUtils.getObjectFromJson(chatContextObject.toString(), HashMap.class);
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
                    JSONObject userObject = new JSONObject(call.arguments.toString());
                    KMUser kmUser = (KMUser) GsonUtils.getObjectFromJson(userObject.toString(), KMUser.class);
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
            try {
                result.success(String.valueOf(new MessageDatabaseService(context).getTotalUnreadCount()));
            } catch (Exception e) {
                result.error(ERROR, e.toString(), null);
            }
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
        } else if(call.method.equals("updateTeamId")) {
            try {
                final String clientConversationId = call.hasArgument("clientConversationId") ? (String) call.argument("clientConversationId") : null;
                final Integer conversationId = call.hasArgument("conversationId") ? (Integer) call.argument("conversationId") : null;
                final String teamId = call.hasArgument("teamId") ? (String) call.argument("teamId") : null;
                if (TextUtils.isEmpty(clientConversationId) && conversationId == null) {
                    result.error(ERROR, "Invalid or empty clientConversationId", null);
                    return;
                }
                if (TextUtils.isEmpty(teamId)) {
                    result.error(ERROR, "Invalid or empty teamID", null);
                    return;
                }
                if (Kommunicate.isLoggedIn(context)) {
                    KmSettings.updateTeamId(context,
                            conversationId,
                            clientConversationId,
                            teamId,
                            new KmCallback() {
                                @Override
                                public void onSuccess(Object o) {
                                    result.success(o);
                                }
                              
                                @Override
                                public void onFailure(Object o) {
                                    result.error(ERROR, o.toString(), null);
                                }
                            });
                } else {
                    result.error(ERROR, "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the chatContext", null);

                }
            } catch(Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        } else if(call.method.equals("hideChatListOnNotification")) {
            try {
                ApplozicClient.getInstance(context).hideChatListOnNotification();
                result.success(SUCCESS);
            } catch(Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        } else if(call.method.equals("updateDefaultSetting")) {
            try {
                KmSettings.clearDefaultSettings();
                JSONObject settingObject = new JSONObject(call.arguments.toString());
                if (settingObject.has("defaultAgentIds") && !TextUtils.isEmpty(settingObject.get("defaultAgentIds").toString())) {
                    List<String> agentList = new ArrayList<String>();
                    for(int i = 0; i < settingObject.getJSONArray("defaultAgentIds").length(); i++){
                        agentList.add(settingObject.getJSONArray("defaultAgentIds").get(i).toString());
                    }
                    KmSettings.setDefaultAgentIds(agentList);
                }
                if (settingObject.has("defaultBotIds") && !TextUtils.isEmpty(settingObject.get("defaultBotIds").toString())) {
                    List<String> botList = new ArrayList<String>();
                    for(int i = 0; i < settingObject.getJSONArray("defaultBotIds").length(); i++){
                        botList.add(settingObject.getJSONArray("defaultBotIds").get(i).toString());
                    }
                    KmSettings.setDefaultBotIds(botList);
                }
                if (settingObject.has("defaultAssignee") && !TextUtils.isEmpty(settingObject.get("defaultAssignee").toString())) {
                    KmSettings.setDefaultAssignee(settingObject.get("defaultAssignee").toString());
                }
                if (settingObject.has("teamId")) {
                    KmSettings.setDefaultTeamId(settingObject.get("teamId").toString());
                }
                if (settingObject.has("skipRouting")) {
                    KmSettings.setSkipRouting(Boolean.valueOf(settingObject.get("skipRouting").toString()));
                }
                result.success(SUCCESS);
            } catch(Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        } else if(call.method.equals("closeConversationScreen")) {
            if(context != null) {
                Kommunicate.closeConversationScreen(context);
            }
        } else if(call.method.equals("createConversationInfo")) {
            try {
                JSONObject settingObject = new JSONObject(call.arguments.toString());
                KmConversationInfoSetting kmConversationInfoSetting = KmConversationInfoSetting.getInstance(context);
                
                if (settingObject.has("infoContent") && !TextUtils.isEmpty(settingObject.get("infoContent").toString())) {
                    kmConversationInfoSetting.setInfoContent(settingObject.get("infoContent").toString());
                }
                if (settingObject.has("contentTextColor") && !TextUtils.isEmpty(settingObject.get("contentTextColor").toString())) {
                    kmConversationInfoSetting.setContentColor(settingObject.get("contentTextColor").toString());
                }
                if (settingObject.has("backgroundColor") && !TextUtils.isEmpty(settingObject.get("backgroundColor").toString())) {
                    kmConversationInfoSetting.setBackgroundColor(settingObject.get("backgroundColor").toString());
                }
                if (settingObject.has("trailingIcon") && !TextUtils.isEmpty(settingObject.get("trailingIcon").toString())) {
                    kmConversationInfoSetting.setTrailingImageIcon(settingObject.get("trailingIcon").toString());
                }
                if (settingObject.has("leadingIcon") && !TextUtils.isEmpty(settingObject.get("leadingIcon").toString())) {
                    kmConversationInfoSetting.setLeadingImageIcon(settingObject.get("leadingIcon").toString());
                }
                if (settingObject.has("show")) {
                    kmConversationInfoSetting.enableKmConversationInfo(Boolean.valueOf(settingObject.get("show").toString()));
                }
                result.success(SUCCESS);
            } catch(Exception e) {
                result.error(ERROR, e.toString(), null);
            }
        } else if(call.method.equals("createCustomToolbar")) {
            try {
                JSONObject toolbarObject = new JSONObject(call.arguments.toString());
                KmConversationInfoSetting kmConversationInfoSetting = KmConversationInfoSetting.getInstance(context);
                if (toolbarObject.has("show")) {
                    kmConversationInfoSetting.enableCustomToolbarSubtitleDesign(Boolean.valueOf(toolbarObject.get("show").toString()));
                }
                if (toolbarObject.has("experienceText") && !TextUtils.isEmpty(toolbarObject.get("experienceText").toString())) {
                    kmConversationInfoSetting.setToolbarAgentExperience(toolbarObject.get("experienceText").toString());

                }
                if (toolbarObject.has("rating") && !TextUtils.isEmpty(toolbarObject.get("rating").toString())) {
                    kmConversationInfoSetting.setToolbarSubtitleRating(Float.valueOf(toolbarObject.get("rating").toString()));
                }
            } catch(Exception e) {
                    result.error(ERROR, e.toString(), null);
                }
        } else if(call.method.equals("hideAssigneeStatus")) {
            try {
                boolean hide = (boolean) call.arguments();
                    Kommunicate.hideAssigneeStatus(context, hide);
            } catch (Exception e) {
                result.error(ERROR, "Invalid argument passed to hideAssigneeStatus", null);
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
