# FastPix Live - iOS RTMP live streaming demo app (Swift, HaishinKit)

[![Platform: iOS](https://img.shields.io/badge/platform-iOS%2013%2B-000000?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0-F05138?logo=swift&logoColor=white)](https://swift.org)
[![license](https://img.shields.io/github/license/FastPix/fastpix-iOS-live-streaming-demo-application)](https://github.com/FastPix/fastpix-iOS-live-streaming-demo-application/blob/main/LICENSE)
[![HaishinKit](https://img.shields.io/badge/RTMP-HaishinKit%201.7.1-informational)](https://github.com/shogo4405/HaishinKit.swift)
[![FastPix Live](https://img.shields.io/badge/FastPix-Live%20Streaming-5D09C7)](https://dashboard.fastpix.com)

An open-source iOS app that broadcasts live video from your iPhone camera to the FastPix Live platform over secure RTMPS, built with the [HaishinKit RTMP library](https://github.com/shogo4405/HaishinKit.swift). Use it as a working reference for adding camera-based live streaming, adaptive bitrate, network reconnection, and crash-safe camera switching to your own iOS app.

**Works with:** iOS 13+ · Swift · UIKit · CocoaPods · HaishinKit (RTMP/RTMPS) · FastPix Live · physical iPhone/iPad

📖 **FastPix Live docs:** https://fastpix.com/docs &nbsp;·&nbsp; 🚀 **Dashboard:** https://dashboard.fastpix.com &nbsp;·&nbsp; ⚙️ **RTMP library:** https://github.com/shogo4405/HaishinKit.swift

## Demo

![FastPix Live Demo](FpLive/Assets.xcassets/demo.gif)

<br />

## What this app demonstrates

FastPix Live is a reference implementation for camera-to-cloud live streaming on iOS. It shows how to:

- **Broadcast over RTMPS** - secure live streaming to the FastPix Live platform
- **Switch cameras live** - crash-safe front/back camera toggle during an active broadcast
- **Survive network changes** - automatic reconnection on dropouts and WiFi to cellular handoff, with exponential backoff
- **Adapt quality** - dynamic bitrate adjustment across four broadcasting profiles (1080p, 720p, 540p, 360p)
- **Monitor the stream** - live FPS and bitrate readouts, plus a full streaming state machine (idle, connecting, publishing, reconnecting, and more)
- **Keep the UI safe** - iOS 18-style notifications, haptics, screen wake lock, and thread-safe state handling

<br />

## Prerequisites

Before you start, make sure you have:

- A **Mac with Xcode** installed.
- **CocoaPods** installed (`sudo gem install cocoapods`), used to pull HaishinKit and the other dependencies.
- A **physical iPhone or iPad** running **iOS 13.0 or later**. The Simulator cannot access the camera, so streaming will not work on it.
- An **Apple Developer account** to sign and run the app on your device.
- A **FastPix account** with a live stream and its **RTMP stream key**.

<br />

## Get your FastPix stream key

The app publishes to a FastPix live stream identified by your stream key, which you enter in the app at runtime:

1. Sign up or log in at the [FastPix Dashboard](https://dashboard.fastpix.com/signup).
2. Create a **live stream** and copy its unique **stream key**.

You will paste this key into the app's setup screen the first time you broadcast. The RTMP endpoint itself is already configured in the app (see [About the RTMP endpoint](#about-the-rtmp-endpoint)), so the stream key is the only value you need.

<br />

## Clone the repository

```bash
git clone https://github.com/FastPix/fastpix-iOS-live-streaming-demo-application.git
cd fastpix-iOS-live-streaming-demo-application
```

> The `Podfile`, `FpLive.xcworkspace`, and `FpLive.xcodeproj` all live at the repository root. Run the next commands from this cloned root folder, not from the inner `FpLive/` source folder.

<br />

## Install dependencies with CocoaPods

This project uses CocoaPods (HaishinKit, Hue, Loaf). From the repository root, run:

```bash
pod install
```

<br />

## Open and run the app

Open the generated workspace (not the `.xcodeproj`):

```bash
open FpLive.xcworkspace
```

Then in Xcode:

1. Select the `FpLive` scheme and choose your connected iPhone/iPad as the run destination (not a Simulator).
2. In **Signing & Capabilities**, select your Apple Developer Team so the app can be signed for your device.
3. Build and run (`⌘R`).

<br />

## Start streaming and verify it works

1. Launch the app on your device and grant **camera** and **microphone** permission when prompted.
2. On the setup screen, paste your FastPix **stream key** and start the broadcast.
3. The app connects over RTMPS and begins publishing. You should see the live camera preview with real-time FPS and bitrate indicators, and the state move to `publishing`.
4. Confirm the stream is live by watching it back from your [FastPix Dashboard](https://dashboard.fastpix.com) (or any player pointed at your stream's playback ID).

If you see a black screen or a connection failure, see [Troubleshooting](#troubleshooting).

<br />

## About the RTMP endpoint

The app is preconfigured to publish to FastPix Live over secure RTMPS. The committed source connects to:

`rtmps://live.fastpix.com:443/live`

FastPix endpoints are migrating from the `.io` TLD to `.com`. The old `rtmps://live.fastpix.io:443/live` host continues to serve traffic temporarily for backward compatibility, but it is planned for future deprecation, so the `.com` endpoint above is recommended. You do not need to set this manually - it is already wired into the app.

<br />

## Streaming profiles

The app supports four broadcasting profiles, selectable in the UI:

```Swift
enum Preset {
  case hd_1080p_30fps_5mbps // Premium quality
  case hd_720p_30fps_3mbps // High quality
  case sd_540p_30fps_2mbps // Standard quality
  case sd_360p_30fps_1mbps // Data-saver quality
}
```

> **Note:** At 1080p, older devices may drop frames to around 20 fps. Camera switching is intentionally disabled during connection states to prevent crashes, and rotation changes during reconnection may cause a connection to fail.

<br />

## Architecture overview

### Core components

**`LiveStreamViewController.swift`** - the main streaming interface, containing:

- **Camera management**: safe switching between front/back cameras
- **Stream control**: start/stop broadcasting with state management
- **Network handling**: connection monitoring and automatic retry logic
- **UI management**: modern controls with real-time feedback

### Key classes

- **`UltraModernNotificationView`** - iOS 18-style notifications with blur effects, haptic feedback, and auto-dismiss animations.
- **`ModernNotificationManager`** - a centralized, thread-safe notification system with success/error/warning/info styles.
- **`StreamState` enum** - comprehensive lifecycle state management with per-state UI behavior.

<br />

## Technical implementation

### Stream setup process

**1. Permission handling**

```Swift
requestCameraPermission { [weak self] granted in
    if granted {
        self?.setupStreamingEngine()
    } else {
        DispatchQueue.main.async {
            self?.showPermissionAlert()
        }
    }
}
```

**2. RTMP configuration**

```Swift
rtmpStream = RTMPStream(connection: rtmpConnection)
configureStream(preset: self.preset)
rtmpStream.attachCamera(cameraDevice)
rtmpStream.attachAudio(audioDevice)
```

**3. Connection management**

```Swift
rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
rtmpConnection.connect("rtmps://live.fastpix.com:443/live")
```

### Crash protection

**Camera switching protection**

```Swift
private var isCameraSwitching = false
private var cameraAttachmentInProgress = false

private func attachCamera() {
guard !isCameraSwitching && !cameraAttachmentInProgress else { return }

// Safe camera switching logic

}
```

**Status interaction safety**

```Swift
private func handleConnectingStateInteraction() {
guard isViewLoaded, view.window != nil, presentedViewController == nil else { return }

// Safe UI interaction during connection states

}
```

### Streaming state machine

```Swift
enum StreamState {
  case idle // Ready to start streaming
  case connecting // Attempting RTMP connection
  case connected // Connected, starting stream
  case publishing // Live streaming active
  case reconnecting // Recovering from connection loss
  case stopping // Ending stream gracefully
  case waitingForNetwork // Poor network, waiting for improvement
}
```

### Error handling and recovery

- **Network change detection**: seamless transition between WiFi and cellular
- **Connection timeout**: 15-second timeout with user options
- **Poor network handling**: quality reduction and user notifications
- **Thread safety**: all UI updates on the main thread with proper guards
- **Debouncing**: prevents rapid button taps and concurrent operations

<br />

## Troubleshooting

### "No Podfile found" when running `pod install`
Run `pod install` from the repository **root** (`fastpix-iOS-live-streaming-demo-application/`), not from the inner `FpLive/` folder. The `Podfile` is at the root.

### Black screen during streaming
- Confirm camera and microphone permissions are granted.
- Verify your stream key is valid and copied correctly from the dashboard.
- Restart the app.

### Connection failures
- Check network connectivity and try a different network (WiFi or cellular).
- Confirm the RTMPS endpoint `rtmps://live.fastpix.com:443/live` is reachable from your network.
- Confirm the live stream is active in your [FastPix Dashboard](https://dashboard.fastpix.com).

### Nothing happens on the Simulator
Streaming and camera capture require a **physical device**. The Simulator has no camera and cannot broadcast.

### Camera switching crashes
The app includes crash protection for camera switching. Avoid switching cameras rapidly during connection/reconnection states.

<br />

## Which FastPix repo do I need?

This app **broadcasts** live video from iOS. To play FastPix video or add other capabilities, use:

| I want to... | Repo |
|---|---|
| Play FastPix video (incl. live playback) in an iOS app | [iOS-player](https://github.com/FastPix/iOS-player) |
| Play FastPix video on the web | [web-player-component](https://github.com/FastPix/web-player-component) |
| Add playback QoE analytics for AVPlayer (iOS / tvOS) | [iOS-data-avplayer-sdk](https://github.com/FastPix/iOS-data-avplayer-sdk) |
| Add resumable uploads to an iOS app | [iOS-Uploads](https://github.com/FastPix/iOS-Uploads) |
| Add resumable uploads in the browser | [web-uploads-sdk](https://github.com/FastPix/web-uploads-sdk) |

Browse everything in the [FastPix organization](https://github.com/orgs/FastPix/repositories).

<br />

## FAQ

**What does this app do?**
It broadcasts live video from an iPhone/iPad camera to FastPix Live over RTMPS, with adaptive bitrate and automatic reconnection. See [What this app demonstrates](#what-this-app-demonstrates).

**Which RTMP library does it use?**
[HaishinKit](https://github.com/shogo4405/HaishinKit.swift) (locked to version 1.7.1 via CocoaPods).

**Where do I get my stream key?**
Create a live stream in the [FastPix Dashboard](https://dashboard.fastpix.com) and copy its stream key. See [Get your FastPix stream key](#get-your-fastpix-stream-key).

**What RTMP endpoint does it stream to?**
`rtmps://live.fastpix.com:443/live`, already configured in the app. See [About the RTMP endpoint](#about-the-rtmp-endpoint).

**Why won't it work on the Simulator?**
The Simulator has no camera. You need a physical iPhone or iPad running iOS 13.0+.

**Can I stream in 1080p?**
Yes, but older devices may drop to around 20 fps at 1080p. Lower profiles (720p/540p/360p) are available for weaker networks or devices.

**How do I play the live stream back?**
Use a FastPix player - for iOS use [iOS-player](https://github.com/FastPix/iOS-player), or [web-player-component](https://github.com/FastPix/web-player-component) on the web. See [Which FastPix repo do I need?](#which-fastpix-repo-do-i-need)

<br />

## License

FastPix Live is released under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
