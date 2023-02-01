//
//  File.swift
//  
//  Created by Serghii Krotkykh on 25.01.2023.
//
import Foundation
import Combine

public class CallButton: TwilioEvent {
    typealias EnableClosure = (Bool) -> Void
    typealias TitleClosure = (String) -> Void
    private var enabledClosure: EnableClosure?
    private var titleClosure: TitleClosure?

    private var disposableBag = Set<AnyCancellable>()

    public init() { }
    
    public func perform(at controller: TwilioVoiceController) {
        if enabledClosure != nil {
            controller.$enableMainButton
                .receive(on: RunLoop.main)
                .sink { enable in
                    self.enabledClosure?(enable)
                }.store(in: &disposableBag)
        }
        if titleClosure != nil {
            controller.$mainButtonTitle
                .receive(on: RunLoop.main)
                .sink { title in
                    self.titleClosure?(title)
                }.store(in: &disposableBag)
        }
    }

    @discardableResult public func onEnabled(_ closure: @escaping (Bool) -> Void) -> CallButton {
        enabledClosure = closure
        return self
    }

    @discardableResult public func onTitle(_ closure: @escaping (String?) -> Void) -> CallButton {
        titleClosure = closure
        return self
    }
}

public class LongTermProcess: TwilioEvent {
    typealias Closure = () -> Void
    private var onStartClosure: Closure?
    private var onEndClosure: Closure?

    private var disposableBag = Set<AnyCancellable>()

    public init() { }
    
    public func perform(at controller: TwilioVoiceController) {
        if onStartClosure != nil {
            controller.$startLongTermProcess
                .receive(on: RunLoop.main)
                .sink { [weak self] show in
                    self?.onStartClosure?()
                }.store(in: &disposableBag)
        }
        if onEndClosure != nil {
            controller.$stopLongTermProcess
                .receive(on: RunLoop.main)
                .sink { [weak self] show in
                    self?.onEndClosure?()
                }.store(in: &disposableBag)
        }
    }

    @discardableResult public func onStart(_ closure: @escaping () -> Void) -> LongTermProcess {
        onStartClosure = closure
        return self
    }

    @discardableResult public func onEnd(_ closure: @escaping () -> Void) -> LongTermProcess {
        onEndClosure = closure
        return self
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

