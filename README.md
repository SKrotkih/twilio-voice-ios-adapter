# TwilioVoiceAdapter

This SPM package contains refactored codebase from original Twilio for iOS project [SwiftVoiceQuickstart](https://github.com/twilio/voice-quickstart-swift).

## Requirements

- Xcode 13+
- Swift 5

## Get started with TwilioVoiceAdapter 

- Open *File* - *Add packages...* menu item. Enter `https://github.com/SKrotkih/twilio-voice-ios-adapter` in the *Search or Enter Package URL* filed. Select `twilio-voice-ios-adapter`, select `main` branch and select your project name in the `Add to Project`. Press on the `Add Package` button.  
- To start using this code you should prepare an access token. Implement *TwilioAccessTokenFetcher* for that.

## Use case

```swift
import TwilioVoiceAdapter
...
let viewModel = ViewModel()
```

and then update your app UI with listening of the *viewModel.swift* publishers. See examples in  [TwilioSwiftUiQuickstart and TwilioUiKitQuickstart](https://github.com/SKrotkih/TwilioCallKitQuickstart) projects. 

## Changes history:

- 01-10-2023 - first commit 
