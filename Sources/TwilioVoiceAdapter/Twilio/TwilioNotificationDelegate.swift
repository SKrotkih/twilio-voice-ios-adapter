//
//  TwilioNotificationDelegate.swift
//  TwilioVoicePackage
//
import Foundation
import TwilioVoice

enum TwilioNotifications {
    case pending(CallInvite)
    case canceled(CallInvite)
    case error(Error)
}

/**
 Twilio NotificationDelegate
 @param
 @return
 */
class TwilioNotificationDelegate: NSObject, NotificationDelegate {
    weak var callKitActions: PhoneCallable?

    func callInviteReceived(callInvite: CallInvite) {
        NSLog("callInviteReceived:")

        /**
         * The TTL of a registration is 1 year. The TTL for registration for this device/identity
         * pair is reset to 1 year whenever a new registration occurs or a push notification is
         * sent to this device/identity pair.
         */
        UserDefaults.standard.set(Date(), forKey: kCachedBindingDate)

        let callerInfo: TVOCallerInfo = callInvite.callerInfo
        if let verified: NSNumber = callerInfo.verified {
            if verified.boolValue {
                NSLog("Call invite received from verified caller number!")
            }
        }

        let from = (callInvite.from ?? "Voice Bot").replacingOccurrences(of: "client:", with: "")

        // Always report to CallKit, and do it synchronously: since iOS 13 the incoming call
        // must be reported before the PushKit completion handler is called, or iOS kills the app
        callKitActions?.useActiveCallInvite(callInvite)
        callKitActions?.reportIncomingCall(from: from, uuid: callInvite.uuid)
    }

    func cancelledCallInviteReceived(cancelledCallInvite: CancelledCallInvite, error: Error) {
        callKitActions?.cancelledCallInviteReceived(cancelledCallInvite: cancelledCallInvite, error: error)
    }
}
