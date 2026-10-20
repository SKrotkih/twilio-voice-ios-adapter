# TwilioVoiceAdapter

TwilioVoiceAdapter is a Swift Package Manager library built from a refactored [Twilio Voice Quickstart for iOS](https://github.com/twilio/voice-quickstart-swift).
It wraps the Twilio Voice SDK, CallKit and PushKit behind one observable object, `TwilioVoiceController`, so a UIKit or SwiftUI app only has to render its state and forward user actions.

Project link: https://github.com/SKrotkih/twilio-voice-ios-adapter

Example apps (UIKit and SwiftUI): [TwilioCallKitQuickstart](https://github.com/SKrotkih/TwilioCallKitQuickstart)

## Features

- Outgoing calls to a client name or phone number, started through CallKit (`CXStartCallAction`).
- Incoming calls via VoIP push (PushKit), reported to CallKit synchronously, as iOS 13+ requires.
- Mute, hold and speaker routing, kept in sync with the system call UI.
- Remote hang-ups, failed connections and reconnects are reported to CallKit.
- Automatic Twilio push registration, renewed when half of the 1-year registration TTL has passed.
- Microphone permission check with a "Continue without microphone / Settings / Cancel" alert.
- Call quality warnings published as a ready-to-show text.

## Requirements

- iOS 13+
- Xcode 14+ (Swift 5.7, `swift-tools-version: 5.7`)
- [Twilio Voice iOS SDK](https://github.com/twilio/twilio-voice-ios) `6.5.0` up to the next major version (pulled in automatically)
- An access token server (see [Access token server](#access-token-server))
- A real device for incoming calls: VoIP pushes are not delivered to the Simulator

## Installation

In Xcode open **File → Add Package Dependencies...**, enter
`https://github.com/SKrotkih/twilio-voice-ios-adapter`, choose the `main` branch and add the `TwilioVoiceAdapter` library to your app target.

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SKrotkih/twilio-voice-ios-adapter", branch: "main")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "TwilioVoiceAdapter", package: "twilio-voice-ios-adapter")
    ])
]
```

## App setup

The adapter uses CallKit and PushKit, so the host app needs:

- **Signing & Capabilities → Push Notifications** (`aps-environment` entitlement).
- **Signing & Capabilities → Background Modes → Audio** and **Voice over IP** (`UIBackgroundModes`: `audio`, `voip`).
- `NSMicrophoneUsageDescription` in `Info.plist`.
- A VoIP Services certificate uploaded to Twilio as a Push Credential, and its SID set in your token server, so Twilio can send incoming call pushes.
- `CFBundleDisplayName` in `Info.plist` (optional): it is used as the name shown on the CallKit screen.
- For a custom ringback, a `ringtone.wav` file in the app bundle (see [Custom ringback](#custom-ringback)).

## Access token server

The adapter gets a Twilio access token from your server with a plain `GET` request:

```
GET {baseURLString}{accessTokenEndpoint}?identity={identity}
```

The response body must be the token itself as plain text (no JSON). Any server from the Twilio Voice quickstarts works, for example the [Twilio Serverless function](https://github.com/twilio/voice-quickstart-server-functions) or [voice-quickstart-server-node](https://github.com/twilio/voice-quickstart-server-node).
Outgoing calls are routed by your TwiML application; the dialed value is sent to it as the `to` parameter.

The token is requested:

- when PushKit issues or changes the device token (to register for incoming call pushes),
- when PushKit invalidates the device token (to unregister),
- before every outgoing call.

> **Note**
> The request is synchronous. If the configuration is missing, the URL is invalid or the server can't be reached, the adapter logs an error and falls back to a fake token, so registration and calls fail on Twilio's side. Check the console for `TwilioAccessTokenFetcher:` messages if nothing happens.

## Usage

### 1. Create the controller

```swift
import TwilioVoiceAdapter

let tokenConfiguration = TwilioAccessTokenConfiguration(
    baseURLString: "https://your-token-server.com",
    accessTokenEndpoint: "/accessToken",   // e.g. "/accessToken.php" for a PHP server
    identity: "alice"                      // client identity the token is issued for
)

let voiceController = TwilioVoiceController(accessTokenConfiguration: tokenConfiguration)
```

Creating the controller sets up the Twilio audio device, the CallKit provider and the PushKit registry. Create it **once, as early as possible** (at app launch or in the first screen), so incoming call pushes can be handled. The CallKit/PushKit state inside the package is shared, so keep a single controller for the whole app.

### 2. Start it from your screen

```swift
voiceController.viewDidLoad(viewController: self)
```

This call is required. It subscribes the controller to call events and enables the call button. The view controller is used to present the microphone permission alert. Calling it again (e.g. from SwiftUI `onAppear`) only updates the view controller; the setup runs once.

### 3. Forward user actions

| Method | What it does |
| --- | --- |
| `saveOutgoingValue(_ value: String?)` | Stores the client name or phone number to call. An empty value calls "Voice Bot" (an automated response from the quickstart TwiML app). |
| `makeCallButtonPressed()` | Starts a call (after the microphone check), or hangs up if a call is active. |
| `toggleMuteSwitch(to isOn: Bool)` | Mutes or unmutes the active call through CallKit. |
| `toggleSpeakerSwitch(to isOn: Bool)` | Routes audio to the speaker (`true`) or the receiver (`false`). |
| `qualityWarningsUpdatePopup(_:isCleared:)` | Builds `warningText` from Twilio quality warnings. Called by the adapter itself; you normally don't need it. |

### 4. Render the state

`TwilioVoiceController` is an `ObservableObject` (it conforms to the `TwilioVoiceControllable` protocol). Its published properties describe the UI:

| Property | Type | Meaning |
| --- | --- | --- |
| `enableMainButton` | `Bool` | The call button is enabled. |
| `mainButtonTitle` | `String` | Call button title: `Call`, `Ringing`, `Hang Up`, `Reconnecting`. |
| `showCallControl` | `Bool` | Show the in-call controls (mute, speaker). |
| `onMute` | `Bool` | The call is muted. |
| `onSpeaker` | `Bool` | Audio goes to the speaker. Turned on when a call connects. |
| `startLongTermProcess` | `Bool` | A call is being started: show a progress indicator. |
| `stopLongTermProcess` | `Bool` | The call connected, ended or was cancelled: hide the progress indicator. |
| `warningText` | `String` | Call quality warnings, e.g. `Warnings detected: high-rtt, low-mos`. |

## SwiftUI example

```swift
import SwiftUI
import TwilioVoiceAdapter

@main
struct VoiceApp: App {
    @StateObject var viewModel = TwilioVoiceController(
        accessTokenConfiguration: TwilioAccessTokenConfiguration(
            baseURLString: "https://your-token-server.com",
            accessTokenEndpoint: "/accessToken",
            identity: "alice"
        )
    )

    var body: some Scene {
        WindowGroup { ContentView(viewModel: viewModel) }
    }
}

struct ContentView<ViewModel: TwilioVoiceControllable>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var outgoingValue = ""

    var body: some View {
        VStack {
            Text(viewModel.warningText)
            TextField("Client name or phone number", text: $outgoingValue)
                .onChange(of: outgoingValue) { viewModel.saveOutgoingValue($0) }
            Button(viewModel.mainButtonTitle) { viewModel.makeCallButtonPressed() }
                .disabled(!viewModel.enableMainButton)
            if viewModel.showCallControl {
                Toggle("Mute", isOn: $viewModel.onMute)
                    .onChange(of: viewModel.onMute) { viewModel.toggleMuteSwitch(to: $0) }
                Toggle("Speaker", isOn: $viewModel.onSpeaker)
                    .onChange(of: viewModel.onSpeaker) { viewModel.toggleSpeakerSwitch(to: $0) }
            }
        }
        .onAppear {
            // Any view controller that is on screen, used for the microphone alert
            let root = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?.rootViewController
            viewModel.viewDidLoad(viewController: root ?? UIHostingController(rootView: self))
        }
    }
}
```

## UIKit example

You can subscribe to the published properties with Combine:

```swift
viewModel.$enableMainButton
    .receive(on: RunLoop.main)
    .sink { [weak self] enable in self?.placeCallButton.isEnabled = enable }
    .store(in: &disposableBag)
```

or describe the UI declaratively with the `TwilioEventsBuilder` result builder. Each event object subscribes to the matching published property and calls your closures on the main run loop:

```swift
import UIKit
import TwilioVoiceAdapter

class ViewController: UIViewController {
    private var viewModel: TwilioVoiceController!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = TwilioVoiceController(accessTokenConfiguration: tokenConfiguration) {
            CallButton()
                .onEnabled { [weak self] in self?.placeCallButton.isEnabled = $0 }
                .onTitle { [weak self] in self?.placeCallButton.setTitle($0, for: .normal) }
            CallControl()
                .onShow { [weak self] in self?.callControlView.isHidden = false }
                .onHide { [weak self] in self?.callControlView.isHidden = true }
            MuteControl()
                .onMute { [weak self] in self?.muteSwitch.isOn = true }
                .offMute { [weak self] in self?.muteSwitch.isOn = false }
            SpeackerControl()
                .onSpeacker { [weak self] in self?.speakerSwitch.isOn = true }
                .offSpeacker { [weak self] in self?.speakerSwitch.isOn = false }
            LongTermProcess()
                .onStart { [weak self] in self?.spinner.startSpin() }
                .onEnd { [weak self] in self?.spinner.stopSpin() }
            CallResult()
                .onWarning { [weak self] text in self?.qualityWarningsLabel.text = text }
        }
        viewModel.viewDidLoad(viewController: self)
    }

    @IBAction func makeCallButtonPressed(_ sender: Any) { viewModel.makeCallButtonPressed() }
    @IBAction func muteSwitchToggled(_ sender: UISwitch) { viewModel.toggleMuteSwitch(to: sender.isOn) }
    @IBAction func speakerSwitchToggled(_ sender: UISwitch) { viewModel.toggleSpeakerSwitch(to: sender.isOn) }
}
```

| Event | Callbacks | Source property |
| --- | --- | --- |
| `CallButton` | `onEnabled(Bool)`, `onTitle(String?)` | `enableMainButton`, `mainButtonTitle` |
| `CallControl` | `onShow`, `onHide` | `showCallControl` |
| `MuteControl` | `onMute`, `offMute` | `onMute` |
| `SpeackerControl` | `onSpeacker`, `offSpeacker` | `onSpeaker` |
| `LongTermProcess` | `onStart`, `onEnd` | `startLongTermProcess`, `stopLongTermProcess` |
| `CallResult` | `onWarning(String)` | `warningText` |

You can also adopt the public `TwilioEvent` protocol (`func happened(at controller: TwilioVoiceController)`) to add your own events to the builder.

## How a call works

**Outgoing call**

1. `makeCallButtonPressed()` checks the microphone permission (and shows the alert if it is missing).
2. The adapter requests a `CXStartCallAction` from CallKit. The UI gets `startLongTermProcess = true`.
3. CallKit's provider fetches an access token and calls `TwilioVoiceSDK.connect` with `to` set to the saved outgoing value.
4. Twilio events update the UI: `Ringing` → `Hang Up` with call controls shown and audio on the speaker.
5. Pressing the button again sends a `CXEndCallAction`. Remote hang-ups and failures are reported to CallKit by the adapter.

**Incoming call**

1. PushKit delivers a VoIP push; the adapter passes it to `TwilioVoiceSDK.handleNotification`.
2. The call invite is reported to CallKit right away, so the system incoming call screen appears even when the app is in the background or killed.
3. Answer / Decline / Mute / Hold on the system screen are handled by the adapter. If the caller hangs up first, the call is ended in CallKit.

## Custom ringback

`TwilioVoiceController` can play `ringtone.wav` from the main bundle between the "ringing" and "connected" events. It is turned off by default (`playCustomRingback = false` in `TwilioVoiceController.swift`). Turn it on only if your TwiML `<Dial>` uses [answerOnBridge](https://www.twilio.com/docs/voice/twiml/dial#answeronbridge), because then the caller doesn't hear the network ringback.

## Package structure

| Folder / file | Role |
| --- | --- |
| `TwilioVoiceController.swift` | Public entry point and published UI state. |
| `TwilioAccessTokenFetcher.swift` | `TwilioAccessTokenConfiguration` and the token request. |
| `TwilioEvents.swift`, `TwilioEventsBuilder.swift` | Declarative UIKit events and the result builder. |
| `CallKit/` | `CallKitActions`: CallKit transactions, active calls and call invites. |
| `PushNotifications/` | PushKit registry, push registration, `CXProviderDelegate`. |
| `Twilio/` | Twilio `CallDelegate` / `NotificationDelegate` and the interactor that maps call events to UI events. |
| `Redux/` | Internal store, actions and reducer that run CallKit/Twilio side effects on the main actor. |
| `Microphone/`, `Audiodevice/`, `Ringtone/` | Microphone permission, audio route, ringback player. |

## Changes history

- 2026-10-20 — The token server is configured by the app through `TwilioAccessTokenConfiguration` (no hardcoded URL/identity in the package). CallKit and PushKit call flow fixed: incoming calls reported synchronously, remote hang-ups reported to CallKit, mute and hold go through CallKit, one shared audio device.
- 01-10-2023 — First commit.

## License

MIT, see [LICENSE](LICENSE).
