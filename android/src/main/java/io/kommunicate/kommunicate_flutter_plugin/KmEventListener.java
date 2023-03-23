package io.kommunicate.kommunicate_flutter_plugin;

import com.applozic.mobicomkit.broadcast.AlEventManager;
import io.kommunicate.callbacks.KmPluginEventListener;
import com.applozic.mobicomkit.api.conversation.Message;
import io.flutter.plugin.common.MethodChannel;
import com.applozic.mobicommons.json.GsonUtils;
import org.json.JSONObject;
import org.json.JSONException;
import com.applozic.mobicomkit.listners.KmConversationInfoListener;


public class KmEventListener implements KmPluginEventListener, KmConversationInfoListener {
    private MethodChannel methodChannel;

   public void register(MethodChannel methodChannel) {
    this.methodChannel = methodChannel;
        AlEventManager.getInstance().registerPluginEventListener(this);
        AlEventManager.getInstance().registerConversationInfoListener(this);
    }

    public void unregister() {
        AlEventManager.getInstance().unregisterPluginEventListener();
    }

    @Override
    public void onPluginLaunch() {
        methodChannel.invokeMethod("onPluginLaunch", "launch");
    }

    @Override
    public void onPluginDismiss() {
        methodChannel.invokeMethod("onPluginDismiss", "dismiss");
    }

    @Override
    public void onConversationResolved(Integer conversationId) {
        methodChannel.invokeMethod("onConversationResolved", conversationId);
    }

    @Override
    public void onConversationRestarted(Integer conversationId) {
        methodChannel.invokeMethod("onConversationRestarted", conversationId);
    }

    @Override
    public void onRichMessageButtonClick(Integer conversationId, String actionType, Object action) {
        try  {
            JSONObject messageActionObject = new JSONObject();
            messageActionObject.put("conversationId", conversationId);
            messageActionObject.put("actionType", actionType);
            messageActionObject.put("action", action);
            methodChannel.invokeMethod("onRichMessageButtonClick", String.valueOf(messageActionObject));
        } catch(JSONException e) {
            methodChannel.invokeMethod("onRichMessageButtonClick", "error fetching data");
            e.printStackTrace();
        }
    }

    @Override
    public void onStartNewConversation(Integer conversationId) {
        methodChannel.invokeMethod("onStartNewConversation", conversationId);
    }

    @Override
    public void onSubmitRatingClick(Integer conversationId, Integer rating, String feedback) {
        try {
            JSONObject ratingObject = new JSONObject();
            ratingObject.put("conversationId", conversationId);
            ratingObject.put("rating", rating);
            ratingObject.put("feedback", feedback);
            methodChannel.invokeMethod("onSubmitRatingClick", String.valueOf(ratingObject));
        } catch(JSONException e) {
            methodChannel.invokeMethod("onSubmitRatingClick", "error fetching data");
            e.printStackTrace();
        }
    }

    @Override
    public void onMessageSent(Message message) {
        methodChannel.invokeMethod("onMessageSent", GsonUtils.getJsonFromObject(message, Message.class));
    }

    @Override
    public void onMessageReceived(Message message) {
        methodChannel.invokeMethod("onMessageReceived", GsonUtils.getJsonFromObject(message, Message.class));
    }

    @Override
    public void onBackButtonClicked(boolean isConversationOpened) {
        methodChannel.invokeMethod("onBackButtonClicked", isConversationOpened);
    }

    @Override
    public void onAttachmentClick(String attachmentType) {
        methodChannel.invokeMethod("onAttachmentClick", attachmentType);
    }

    @Override
    public void onFaqClick(String faqUrl) {
        methodChannel.invokeMethod("onFaqClick", faqUrl);
    }

    @Override
    public void onLocationClick() {
        methodChannel.invokeMethod("onLocationClick", "clicked");
    }

    @Override
    public void onNotificationClick(Message message) {
        methodChannel.invokeMethod("onNotificationClick",  GsonUtils.getJsonFromObject(message, Message.class));
    }

    @Override
    public void onVoiceButtonClick(String action) {
        methodChannel.invokeMethod("onVoiceButtonClick", action);
    }

    @Override
    public void onRatingEmoticonsClick(Integer integer) {
        methodChannel.invokeMethod("onRatingEmoticonsClick", String.valueOf(integer));
    }

    @Override
    public void onRateConversationClick() {
        methodChannel.invokeMethod("onRateConversationClick", "clicked");
    }

    @Override
    public void onConversationInfoClicked() {
        methodChannel.invokeMethod("onConversationInfoClicked", "clicked");
    }
}