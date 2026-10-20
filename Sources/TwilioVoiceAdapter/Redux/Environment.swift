//
//  Environment.swift
//  TwilioVoicePackage
//
import Foundation
import TwilioVoice

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
    /// The single audio device shared by the Twilio SDK and the CallKit provider delegate
    let audioDevice: DefaultAudioDevice
    // CXProvider and PKPushRegistry hold their delegates weakly, so the Environment keeps them alive
    private let twilioNotificationsDelegate: TwilioNotificationDelegate
    private let pushNotificationsDelegate: PushNotificationsDelegate
    private let voIpNotificationsDelegate: VoIpNotificationsDelegate
    private let voIpNotificationsCenter: VoIpNotificationsCenter

    init() {
        sharedData = SharedData()
        /*
         * The audio device must be set before performing any other actions with the SDK
         * (such as connecting a Call, or accepting an incoming Call).
         */
        audioDevice = DefaultAudioDevice()
        TwilioVoiceSDK.audioDevice = audioDevice
        twilioNotificationsDelegate = TwilioNotificationDelegate()
        let callKitProviderDelegate = CallKitProviderDelegate(sharedData: sharedData, audioDevice: audioDevice)
        pushNotificationsDelegate = PushNotificationsDelegate(
            notificationDelegate: twilioNotificationsDelegate
        )
        voIpNotificationsDelegate = VoIpNotificationsDelegate(delegate: pushNotificationsDelegate)
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
        callKitProviderDelegate.callKitActions = callKitActions
        twilioNotificationsDelegate.callKitActions = callKitActions
        // Register for VoIP pushes last, so every delegate is wired before the first push arrives
        voIpNotificationsCenter = VoIpNotificationsCenter(notificationsDelegate: voIpNotificationsDelegate)
    }
}
