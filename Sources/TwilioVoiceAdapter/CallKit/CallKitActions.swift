//
//  CallKitActions.swift
//  TwilioVoicePackage
//
import Foundation
import CallKit
import TwilioVoice

protocol PhoneCallable: AnyObject {
    func performVoiceCall(uuid: UUID, client: String?, to: String?, completionHandler: @escaping (Bool) -> Void)
    func performAnswerVoiceCall(uuid: UUID, completionHandler: @escaping (Bool) -> Void)
    func performStartCallAction(uuid: UUID, handle: String)
    func setUpMuteForActiveCall(_ isMuted: Bool)
    func performEndCallAction()
    func reportIncomingCall(from: String, uuid: UUID)
    func useActiveCallInvite(_ callInvite: CallInvite)
    func cancelledCallInviteReceived(cancelledCallInvite: CancelledCallInvite, error: Error)
    func callDidFailToConnect(call: Call, error: Error)
    func callDidDisconnect(call: Call, error: Error?)
    func callDisconnected(call: Call)
    func performEndCallAction(uuid: UUID)
    func isCallInActiveState(completionHandler: @escaping (Bool) -> Void)
}

/// Make call action and other ones with using CallKit framework
final class CallKitActions: NSObject, PhoneCallable {
    let callKitCallController = CXCallController()
    var callKitProvider: CXProvider?
    var activeCalls: [String: Call] = [:]
    var activeCallInvites: [String: CallInvite] = [:]
    // activeCall represents the last connected call
    private var activeCall: Call?
    private let twilioCallDelegate: TwilioCallsDelegate
    // CXProvider holds its delegate weakly, so keep a strong reference here
    private let callKitProviderDelegate: CallKitProviderDelegate
    weak var pushKitEventDelegate: PushKitEventDelegate?

    init(appName: String,
         twilioCallDelegate: TwilioCallsDelegate,
         callKitProviderDelegate: CallKitProviderDelegate) {
        self.twilioCallDelegate = twilioCallDelegate
        self.callKitProviderDelegate = callKitProviderDelegate
        /* Please note that the designated initializer `CXProviderConfiguration(localizedName: String)`
         has been deprecated on iOS 14. */
        let configuration = CXProviderConfiguration(localizedName: appName)
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        callKitProvider = CXProvider(configuration: configuration)
        if let provider = callKitProvider {
            provider.setDelegate(callKitProviderDelegate, queue: nil)
        }
    }

    func performVoiceCall(uuid: UUID, client: String?, to: String?, completionHandler: @escaping (Bool) -> Void) {
        let accessToken = TwilioAccessTokenFetcher.fetchAccessToken()
        let connectOptions = ConnectOptions(accessToken: accessToken) { builder in
            builder.params = [twimlParamTo: to ?? ""]
            builder.uuid = uuid
        }
        twilioCallDelegate.callKitCompletionCallback = completionHandler
        let call = TwilioVoiceSDK.connect(options: connectOptions, delegate: twilioCallDelegate)
        activeCall = call
        activeCalls[call.uuid!.uuidString] = call
    }

    func performAnswerVoiceCall(uuid: UUID, completionHandler: @escaping (Bool) -> Void) {
        guard let callInvite = activeCallInvites[uuid.uuidString] else {
            NSLog("No CallInvite matches the UUID")
            completionHandler(false)
            return
        }

        let acceptOptions = AcceptOptions(callInvite: callInvite) { builder in
            builder.uuid = callInvite.uuid
        }

        twilioCallDelegate.callKitCompletionCallback = completionHandler
        let call = callInvite.accept(options: acceptOptions, delegate: twilioCallDelegate)
        activeCall = call
        activeCalls[call.uuid!.uuidString] = call

        activeCallInvites.removeValue(forKey: uuid.uuidString)

        pushKitEventDelegate?.incomingPushHandled()
    }

    func performStartCallAction(uuid: UUID, handle: String) {
        guard let provider = callKitProvider else {
            NSLog("CallKit provider not available")
            return
        }

        let callHandle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: uuid, handle: callHandle)
        let transaction = CXTransaction(action: startCallAction)

        callKitCallController.request(transaction) { error in
            if let error = error {
                NSLog("StartCallAction transaction request failed: \(error.localizedDescription)")
                return
            }

            NSLog("StartCallAction transaction request successful")

            let callUpdate = CXCallUpdate()

            callUpdate.remoteHandle = callHandle
            callUpdate.supportsDTMF = true
            callUpdate.supportsHolding = true
            callUpdate.supportsGrouping = false
            callUpdate.supportsUngrouping = false
            callUpdate.hasVideo = false

            provider.reportCall(with: uuid, updated: callUpdate)
        }
    }

    func reportIncomingCall(from: String, uuid: UUID) {
        guard let provider = callKitProvider else {
            NSLog("CallKit provider not available")
            return
        }

        let callHandle = CXHandle(type: .generic, value: from)
        let callUpdate = CXCallUpdate()

        callUpdate.remoteHandle = callHandle
        callUpdate.supportsDTMF = true
        callUpdate.supportsHolding = true
        callUpdate.supportsGrouping = false
        callUpdate.supportsUngrouping = false
        callUpdate.hasVideo = false

        provider.reportNewIncomingCall(with: uuid, update: callUpdate) { error in
            if let error = error {
                NSLog("Failed to report incoming call successfully: \(error.localizedDescription).")
            } else {
                NSLog("Incoming call successfully reported.")
            }
        }
    }

    func callDisconnected(call: Call) {
        if call == activeCall {
            activeCall = nil
        }
        activeCalls.removeValue(forKey: call.uuid!.uuidString)
    }

    func callDidDisconnect(call: Call, error: Error?) {
        var reason = CXCallEndedReason.remoteEnded

        if error != nil {
            reason = .failed
        }

        if let provider = callKitProvider {
            provider.reportCall(with: call.uuid!, endedAt: Date(), reason: reason)
        }
    }

    func callDidFailToConnect(call: Call, error: Error) {
        if let provider = callKitProvider {
            provider.reportCall(with: call.uuid!, endedAt: Date(), reason: CXCallEndedReason.failed)
        }
    }

    func useActiveCallInvite(_ callInvite: CallInvite) {
        activeCallInvites[callInvite.uuid.uuidString] = callInvite
    }

    func isCallInActiveState(completionHandler: (Bool) -> Void ) {
        completionHandler(activeCall != nil)
    }

    func setUpMuteForActiveCall(_ isMuted: Bool) {
        // Go through CallKit so the system call UI stays in sync with the app
        guard let uuid = activeCall?.uuid else { return }

        let muteCallAction = CXSetMutedCallAction(call: uuid, muted: isMuted)
        let transaction = CXTransaction(action: muteCallAction)

        callKitCallController.request(transaction) { error in
            if let error = error {
                NSLog("SetMutedCallAction transaction request failed: \(error.localizedDescription).")
            }
        }
    }

    // MARK: - CXProviderDelegate support

    func isActiveCall(uuid: UUID) -> Bool {
        activeCalls[uuid.uuidString] != nil
    }

    /// Rejects the pending invite or disconnects the call with this UUID
    /// - Returns: false if there is no invite or call with this UUID
    func endCall(uuid: UUID) -> Bool {
        if let invite = activeCallInvites.removeValue(forKey: uuid.uuidString) {
            invite.reject()
            pushKitEventDelegate?.incomingPushHandled()
            return true
        } else if let call = activeCalls[uuid.uuidString] {
            call.disconnect()
            return true
        }
        return false
    }

    func setMuted(_ isMuted: Bool, uuid: UUID) -> Bool {
        guard let call = activeCalls[uuid.uuidString] else { return false }
        call.isMuted = isMuted
        return true
    }

    func setHeld(_ isOnHold: Bool, uuid: UUID) -> Bool {
        guard let call = activeCalls[uuid.uuidString] else { return false }
        call.isOnHold = isOnHold
        return true
    }

    func endAllCalls() {
        activeCallInvites.values.forEach { $0.reject() }
        activeCallInvites.removeAll()
        activeCalls.values.forEach { $0.disconnect() }
        activeCalls.removeAll()
        activeCall = nil
    }

    func performEndCallAction() {
        if let call = activeCall, let uuid = call.uuid {
            performEndCallAction(uuid: uuid)
        }
    }

    func performEndCallAction(uuid: UUID) {

        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)

        callKitCallController.request(transaction) { error in
            if let error = error {
                NSLog("EndCallAction transaction request failed: \(error.localizedDescription).")
            } else {
                NSLog("EndCallAction transaction request successful")
            }
        }
    }

    func cancelledCallInviteReceived(cancelledCallInvite: CancelledCallInvite, error: Error) {
        NSLog("cancelledCallInviteCanceled:error:, error: \(error.localizedDescription)")

        guard activeCallInvites.isEmpty == false else {
            NSLog("No pending call invite")
            return
        }

        let callInvite = activeCallInvites.values.first { invite in invite.callSid == cancelledCallInvite.callSid }

        if let callInvite = callInvite {
            // The caller hung up: tell CallKit directly, the invite must not be rejected again
            activeCallInvites.removeValue(forKey: callInvite.uuid.uuidString)
            callKitProvider?.reportCall(with: callInvite.uuid, endedAt: Date(), reason: .remoteEnded)
        }
    }
}
