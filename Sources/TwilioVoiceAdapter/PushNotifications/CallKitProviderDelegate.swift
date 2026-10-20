//
//  CallKitProviderDelegate.swift
//  TwilioVoicePackage
//
import Foundation
import TwilioVoice
import CallKit
import Combine

let twimlParamTo = "to"

/// CallKit framework CXProviderDelegate implementation
class CallKitProviderDelegate: NSObject, CXProviderDelegate {
    private let sharedData: SharedData
    private let audioDevice: DefaultAudioDevice
    /// Owns the active calls and call invites
    weak var callKitActions: CallKitActions?

    init(sharedData: SharedData, audioDevice: DefaultAudioDevice) {
        self.sharedData = sharedData
        self.audioDevice = audioDevice
    }

    func providerDidReset(_ provider: CXProvider) {
        print("\(#function)")
        audioDevice.isEnabled = false
        callKitActions?.endAllCalls()
        store.stateDispatch(action: .callKit(.reset))
    }

    func providerDidBegin(_ provider: CXProvider) {
        print("\(#function)")
        store.stateDispatch(action: .callKit(.begin))
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("\(#function)")
        audioDevice.isEnabled = true
        store.stateDispatch(action: .callKit(.activateSession))
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("\(#function)")
        audioDevice.isEnabled = false
        store.stateDispatch(action: .callKit(.deactivateSession))
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("\(#function)")
        store.stateDispatch(action: .callKit(.timeout))
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("\(#function)")
        store.stateDispatch(action: .callKit(.startTwilioCall))

        // Keep the SDK audio off until CallKit activates the audio session
        audioDevice.isEnabled = false
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())

        store.stateDispatch(action: .performVoiceCall(action.callUUID, "", sharedData.outgoingValue) { success in
            if success {
                NSLog("performVoiceCall() successful")
                provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
            } else {
                NSLog("performVoiceCall() failed")
            }
        })

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("\(#function)")

        // Keep the SDK audio off until CallKit activates the audio session
        audioDevice.isEnabled = false
        store.stateDispatch(action: .performAnswerVoiceCall(action.callUUID) { success in
            if success {
                NSLog("performAnswerVoiceCall() successful")
            } else {
                NSLog("performAnswerVoiceCall() failed")
            }
        })
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("\(#function)")

        // The call is ended locally, so CallKit doesn't need to be told about the disconnect later
        if callKitActions?.isActiveCall(uuid: action.callUUID) == true {
            sharedData.userInitiatedDisconnect = true
        }
        if callKitActions?.endCall(uuid: action.callUUID) != true {
            NSLog("Unknown UUID to perform end-call action with")
        }
        store.stateDispatch(action: .callKit(.endTwilioCall))
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        print("\(#function)")

        if callKitActions?.setHeld(action.isOnHold, uuid: action.callUUID) == true {
            action.fulfill()
        } else {
            action.fail()
        }
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        print("\(#function)")

        if callKitActions?.setMuted(action.isMuted, uuid: action.callUUID) == true {
            action.fulfill()
        } else {
            action.fail()
        }
    }
}
