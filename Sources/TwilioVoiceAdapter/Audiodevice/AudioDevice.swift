//
//  AudioDevice.swift
//  TwilioVoicePackage
//
import AVFoundation
import TwilioVoice

/// AVAudioSession
class AudioDeviceManager {
    private let audioDevice: DefaultAudioDevice

    /// - Parameter audioDevice: the device already set as `TwilioVoiceSDK.audioDevice`
    init(audioDevice: DefaultAudioDevice) {
        self.audioDevice = audioDevice
    }

    func toggleAudioRoute(toSpeaker: Bool) {
        // The mode set by the Voice SDK is "VoiceChat" so the default audio route
        // is the built-in receiver. Use port override to switch the route.
        audioDevice.block = {
            DefaultAudioDevice.DefaultAVAudioSessionConfigurationBlock()

            do {
                if toSpeaker {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                } else {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                }
            } catch {
                NSLog(error.localizedDescription)
            }
        }

        audioDevice.block()
    }
}
