# TwilioVoiceAdapter

TwilioVoiceAdapter is a SPM (Swift Package Manager) package which is a refactored codebase from the [Twilio Voice Quickstart for iOS](https://github.com/twilio/voice-quickstart-swift).
The project's goal is to create reusable code for Twilio Voice clients.

Project Link: https://github.com/SKrotkih/twilio-voice-ios-adapter

## Requirements

- Xcode 13+
- Swift 5

## Get started with TwilioVoiceAdapter 

- Open your project in Xcode, navigate to **Menu -> File -> Add packages...** and enter [https://github.com/SKrotkih/twilio-voice-ios-adapter](https://github.com/SKrotkih/twilio-voice-ios-adapter) in the **Search or Enter Package URL** filed. Select `twilio-voice-ios-adapter`, select `main` branch and select your project name in the `Add to Project`. Press on the `Add Package` button.  
- To start using this code you should prepare an access token. Implement *TwilioAccessTokenFetcher* for that.

## How to use?

```swift
import TwilioVoiceAdapter
...
let viewModel = TwilioVoiceController()
...
viewModel.$enableMainButton
  .receive(on: RunLoop.main)
  .sink { [weak self] enable in
    self?.placeCallButton.isEnabled = enable
  }.store(in: &disposableBag)
```

and then update your app UI with listening of the *TwilioVoiceController.swift* observable objects. See examples for UIKit and SwiftUI in [TwilioSwiftUiQuickstart and TwilioUIKitQuickstart ](https://github.com/SKrotkih/TwilioCallKitQuickstart) project.  

## Changes history:

- 01-10-2023 - first commit 
