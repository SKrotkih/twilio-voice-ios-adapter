//
//  Dependencies.swift
//  TwilioVoicePackage
//
import Foundation
///
/// Dependency Injection
///
struct Dependencies {
    mutating func configure(for viewModel: TwilioVoiceController) {
        viewModel.microphoneManager = MicrophoneManager()
        viewModel.ringtoneManager = RingtoneManager()
        viewModel.audioDevice = AudioDeviceManager()
    }
}
