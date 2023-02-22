//
//  Environment.swift
//  TwilioVoicePackage
//
import Foundation

struct NetworkService {
    var callKitActions: PhoneCallable

    init(with callKitActions: PhoneCallable) {
        self.callKitActions = callKitActions
    }
}
//
// Initiate all Twilio and CallKit dependencies
//
class Environment {
    let callKitActions: CallKitActions
    let sharedData: SharedData

    init() {
        sharedData = SharedData()
        let twilioNotificationsDelegate = TwilioNotificationDelegate()
        let callKitProviderDelegate = CallKitProviderDelegate(sharedData: sharedData)
        let pushNotificationsDelegate = PushNotificationsDelegate(
            notificationDelegate: twilioNotificationsDelegate
        )
        let voIpNotificationsDelegate = VoIpNotificationsDelegate(delegate: pushNotificationsDelegate)
        // TODO: Find out where it is used
        let _ = VoIpNotificationsCenter(notificationsDelegate: voIpNotificationsDelegate)
        let twilioCallDelegate = TwilioCallsDelegate(sharedData: sharedData)
        var appName = ""
        if let dictionary = Bundle.main.infoDictionary {
            if let version: String = dictionary["CFBundleDisplayName"] as? String {
                appName = version
            }
        }
        callKitActions = CallKitActions(appName: appName,
                                        twilioCallDelegate: twilioCallDelegate,
                                        callKitProviderDelegate: callKitProviderDelegate)
        callKitActions.pushKitEventDelegate = pushNotificationsDelegate
    }
}
