//
//  TwilioEventsBuilder.swift
//  TwilioVoicePackage
//
//  Created by Serhii Krotkykh
//
import SwiftUI

public protocol TwilioEvent {
    func happened(at controller: TwilioVoiceController)
}

@resultBuilder
public struct TwilioEventsBuilder {
    public static func buildBlock(_ events: TwilioEvent...) -> [TwilioEvent] {
        events
    }
}

public extension TwilioVoiceController {
    convenience init(@TwilioEventsBuilder _ builder: () -> [TwilioEvent]) {
        self.init()
        let events = builder()
        for event in events {
            event.happened(at: self)
        }
    }
}
