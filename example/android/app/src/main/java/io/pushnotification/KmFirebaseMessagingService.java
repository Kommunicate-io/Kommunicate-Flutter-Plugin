package io.pushnotification;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import io.kommunicate.Kommunicate;
import io.kommunicate.commons.commons.core.utils.Utils;

public class KmFirebaseMessagingService extends FirebaseMessagingService {

    private static final String TAG = "KmFCMService";

    @Override
    public void onNewToken(String s) {
        Utils.printLog(this, TAG, "Found deviceToken in KM : " + s);
        super.onNewToken(s);
        Kommunicate.updateDeviceToken(this, s);
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Utils.printLog(this, TAG, "Kommunicate notification processing...");
        if (Kommunicate.isKmNotification(this, remoteMessage.getData())) {
            return;
        }
        super.onMessageReceived(remoteMessage);
    }
}
