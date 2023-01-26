//
//  File.swift
//  
//  Created by Serghii Krotkykh on 25.01.2023.
//
import Foundation
import Combine

public class EnableMainButton: TwilioEvent {
    private let closure: (Bool) -> Void
    private var disposableBag = Set<AnyCancellable>()

    public init(_ closure: @escaping (Bool) -> Void) {
        self.closure = closure
    }
    
    public func perform(at controller: TwilioVoiceController) {
        controller.$enableMainButton
            .receive(on: RunLoop.main)
            .sink { enable in
                self.closure(enable)
            }.store(in: &disposableBag)
    }
}

public class MainButtonTitle: TwilioEvent {
    private let closure: (String) -> Void
    private var disposableBag = Set<AnyCancellable>()

    public init(_ closure: @escaping (String) -> Void) {
        self.closure = closure
    }

    public func perform(at controller: TwilioVoiceController) {
        controller.$mainButtonTitle
            .receive(on: RunLoop.main)
            .sink { [weak self] title in
                self?.closure(title)
            }.store(in: &disposableBag)
    }
}

public class ShowCallControl: TwilioEvent {
    private let closure: (Bool) -> Void
    private var disposableBag = Set<AnyCancellable>()

    public init(_ closure: @escaping (Bool) -> Void) {
        self.closure = closure
    }

    public func perform(at controller: TwilioVoiceController) {
        controller.$showCallControl
            .receive(on: RunLoop.main)
            .sink { [weak self] show in
                self?.closure(show)
            }.store(in: &disposableBag)
    }
}

public class OnMute: TwilioEvent {
    private let closure: (Bool) -> Void
    private var disposableBag = Set<AnyCancellable>()

    public init(_ closure: @escaping (Bool) -> Void) {
        self.closure = closure
    }

    public func perform(at controller: TwilioVoiceController) {
        controller.$onMute
            .receive(on: RunLoop.main)
            .sink { [weak self] show in
                self?.closure(show)
            }.store(in: &disposableBag)
    }
}

public class OnSpeaker: TwilioEvent {
    private let closure: (Bool) -> Void
    private var disposableBag = Set<AnyCancellable>()

    public init(_ closure: @escaping (Bool) -> Void) {
        self.closure = closure
    }

    public func perform(at controller: TwilioVoiceController) {
        controller.$onSpeaker
            .receive(on: RunLoop.main)
            .sink { [weak self] show in
                self?.closure(show)
            }.store(in: &disposableBag)
    }
}

public class StartLongTermProcess: TwilioEvent {
    private let closure: (Bool) -> Void
    private var disposableBag = Set<AnyCancellable>()

    public init(_ closure: @escaping (Bool) -> Void) {
        self.closure = closure
    }

    public func perform(at controller: TwilioVoiceController) {
        controller.$startLongTermProcess
            .receive(on: RunLoop.main)
            .sink { [weak self] show in
                self?.closure(show)
            }.store(in: &disposableBag)
    }
}

public class StopLongTermProcess: TwilioEvent {
    private let closure: (Bool) -> Void
    private var disposableBag = Set<AnyCancellable>()

    public init(_ closure: @escaping (Bool) -> Void) {
        self.closure = closure
    }

    public func perform(at controller: TwilioVoiceController) {
        controller.$stopLongTermProcess
            .receive(on: RunLoop.main)
            .sink { [weak self] show in
                self?.closure(show)
            }.store(in: &disposableBag)
    }
}

public class WarningText: TwilioEvent {
    private let closure: (String) -> Void
    private var disposableBag = Set<AnyCancellable>()

    public init(_ closure: @escaping (String) -> Void) {
        self.closure = closure
    }

    public func perform(at controller: TwilioVoiceController) {
        controller.$warningText
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.closure(text)
            }.store(in: &disposableBag)
    }
}

