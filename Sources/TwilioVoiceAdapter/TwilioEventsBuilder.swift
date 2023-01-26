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
    public static func buildBlock(_ components: TwilioEvent...) -> TwilioVoiceController {
        let controller = TwilioVoiceController()
        for component in components {
            component.perform(at: controller)
        }
        return controller
    }
}

public extension TwilioVoiceController {
    convenience init(@TwilioEventsBuilder _ builder: () -> TwilioVoiceController) {
        self.init()
        let _ = builder()
    }
}
