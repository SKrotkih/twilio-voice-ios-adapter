//
//  TwilioEventsBuilder.swift
//  TwilioVoicePackage
//
//  Created by Serhii Krotkykh
//
import SwiftUI

public protocol TwilioEvent {
    func perform(at controller: TwilioVoiceController)
}

@resultBuilder
public struct TwilioEventsBuilder {
    public static func buildBlock(_ components: TwilioEvent...) -> [TwilioEvent] {
        components
    }
}

public extension TwilioVoiceController {
    convenience init(@TwilioEventsBuilder _ builder: () -> [TwilioEvent]) {
        self.init()
        let components = builder()
        for component in components {
            component.perform(at: self)
        }
    }
}
