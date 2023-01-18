# TwilioVoiceAdapter

Refactoring of the actual original project [SwiftVoiceQuickstart](https://github.com/twilio/voice-quickstart-swift).

## Requirements

- Xcode 13+
- Swift 5

## Get started with TwilioVoiceAdapter 

First of all you should implement TwilioAccessTokenFetcher class in this package or use your own in your app

## Use case

```
import TwilioVoiceAdapter
...
let viewModel = ViewModel()
```

and then update your UI with listening of the viewModel's publishers. See examples [TwilioSwiftUiQuickstart and TwilioUiKitQuickstart](https://github.com/SKrotkih/TwilioCallKitQuickstart) 

## Changes history:

- 01-10-2023 - the package was created 
