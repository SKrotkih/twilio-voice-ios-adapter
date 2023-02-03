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

public class CallControl: TwilioEvent {
    typealias Closure = () -> Void
    private var onShowClosure: Closure?
    private var onHideClosure: Closure?
    private var disposableBag = Set<AnyCancellable>()
    public init() { }
    
    public func perform(at controller: TwilioVoiceController) {
        if onShowClosure != nil || onHideClosure != nil {
            controller.$showCallControl
                .receive(on: RunLoop.main)
                .sink { [weak self] show in
                    if show {
                        self?.onShowClosure?()
                    } else {
                        self?.onHideClosure?()
                    }
                }.store(in: &disposableBag)
        }
    }

    @discardableResult public func onShow(_ closure: @escaping () -> Void) -> CallControl {
        onShowClosure = closure
        return self
    }

    @discardableResult public func onHide(_ closure: @escaping () -> Void) -> CallControl {
        onHideClosure = closure
        return self
    }
}

public class MuteControl: TwilioEvent {
    typealias Closure = () -> Void
    private var onMuteClosure: Closure?
    private var offMuteClosure: Closure?
    private var disposableBag = Set<AnyCancellable>()
    public init() { }
    
    public func perform(at controller: TwilioVoiceController) {
        if onMuteClosure != nil || offMuteClosure != nil {
            controller.$onMute
                .receive(on: RunLoop.main)
                .sink { [weak self] onMute in
                    if onMute {
                        self?.onMuteClosure?()
                    } else {
                        self?.offMuteClosure?()
                    }
                }.store(in: &disposableBag)
        }
    }

    @discardableResult public func onMute(_ closure: @escaping () -> Void) -> MuteControl {
        onMuteClosure = closure
        return self
    }

    @discardableResult public func offMute(_ closure: @escaping () -> Void) -> MuteControl {
        offMuteClosure = closure
        return self
    }
}

public class SpeackerControl: TwilioEvent {
    typealias Closure = () -> Void
    private var onSpeackerClosure: Closure?
    private var offSpeackerClosure: Closure?
    private var disposableBag = Set<AnyCancellable>()
    public init() { }
    
    public func perform(at controller: TwilioVoiceController) {
        if onSpeackerClosure != nil || offSpeackerClosure != nil {
            controller.$onSpeaker
                .receive(on: RunLoop.main)
                .sink { [weak self] onSpeacker in
                    if onSpeacker {
                        self?.onSpeackerClosure?()
                    } else {
                        self?.offSpeackerClosure?()
                    }
                }.store(in: &disposableBag)
        }
    }

    @discardableResult public func onSpeacker(_ closure: @escaping () -> Void) -> SpeackerControl {
        onSpeackerClosure = closure
        return self
    }

    @discardableResult public func offSpeacker(_ closure: @escaping () -> Void) -> SpeackerControl {
        offSpeackerClosure = closure
        return self
    }
}

public class CallResult: TwilioEvent {
    typealias Closure = (String) -> Void
    private var onWarningClosure: Closure?
    private var disposableBag = Set<AnyCancellable>()
    public init() { }
    
    public func perform(at controller: TwilioVoiceController) {
        if onWarningClosure != nil {
            controller.$warningText
                .receive(on: RunLoop.main)
                .sink { [weak self] text in
                    self?.onWarningClosure?(text)
                }.store(in: &disposableBag)
        }
    }

    @discardableResult public func onWarning(_ closure: @escaping (String) -> Void) -> CallResult {
        onWarningClosure = closure
        return self
    }
}
