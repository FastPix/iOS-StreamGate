# FastPix StreamGate - iOS screen recording and camera capture with direct-to-cloud uploads (SwiftUI)

[![Platform: iOS](https://img.shields.io/badge/platform-iOS%2016%2B-000000?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-F05138?logo=swift&logoColor=white)](https://swift.org)
[![UI: SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0071E3?logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![license](https://img.shields.io/github/license/FastPix/iOS-StreamGate)](https://github.com/FastPix/iOS-StreamGate/blob/main/LICENSE)
[![FastPix iOS Uploads SDK](https://img.shields.io/badge/FastPix-iOS%20Uploads%20SDK-5D09C7)](https://github.com/FastPix/iOS-Uploads)

StreamGate is an open-source iOS reference app that captures video (native camera or device-wide ReplayKit screen recording) and uploads it directly to the cloud in resumable chunks using the [FastPix iOS Uploads SDK](https://github.com/FastPix/iOS-Uploads), then returns an instant, shareable playback link. Use it as a working example of complex mobile media workflows.

**Works with:** iOS 16+ · SwiftUI · ReplayKit · AVFoundation · FastPix iOS Uploads SDK · physical iPhone

📖 **Upload SDK docs:** https://fastpix.com/docs/upload-videos/set-up-resumable-uploads-for-ios &nbsp;·&nbsp; ⬆️ **Uploads SDK:** https://github.com/FastPix/iOS-Uploads &nbsp;·&nbsp; 🚀 **Dashboard:** https://dashboard.fastpix.com

<br />

## What this app demonstrates

StreamGate is built with a modern iOS stack (100% Swift, SwiftUI, ReplayKit, AVFoundation) and shows how to:

1. **Camera capture** - record video natively with `UIImagePickerController`.
2. **Screen recording** - capture device-wide screen activity with Apple's `ReplayKit` Broadcast Extension and `AVAssetWriter`, running reliably in a separate sandboxed process.
3. **Direct cloud uploading** - push large media files to the cloud in resumable chunks with the FastPix iOS Uploads SDK, with no intermediary backend server.
4. **Local playback / preview** - preview the recording with `AVPlayer` before the shareable link is generated.
5. **Auto cleanup** - delete previous recordings before each new session to keep on-device storage low.

Once an upload completes, StreamGate generates an instant, shareable playback link.

<br />

## Start here

If you are setting up this demo for the first time, follow these steps in order:

1. [Check your macOS version](#1-check-your-macos-version)
2. [Check that Xcode is installed](#2-check-that-xcode-is-installed)
3. [Connect a physical iPhone](#3-connect-a-physical-iphone)
4. [Get your FastPix credentials](#4-get-your-fastpix-credentials)
5. [Clone the repository](#5-clone-the-repository)
6. [Verify the FastPix iOS Uploads SDK](#6-verify-the-fastpix-ios-uploads-sdk)
7. [Verify App Groups on both targets](#7-verify-app-groups-on-both-targets)
8. [Verify the broadcast extension identifier](#8-verify-the-broadcast-extension-identifier)
9. [Configure your FastPix credentials](#9-configure-your-fastpix-credentials)
10. [Build and run on your device](#10-build-and-run-on-your-device)
11. [Record, upload, and verify it works](#11-record-upload-and-verify-it-works)

Do not skip the verification commands. If a step's check fails, fix that problem before you continue.

<br />

## Before you begin

Make sure you have the following ready. This app uses a ReplayKit Broadcast Extension and the device camera, so it needs a real iPhone.

| Requirement | Details |
|---|---|
| **A Mac with Xcode 26 or later** | Install the full Xcode app from the App Store. It provides the build tools, the Swift compiler, and Git. The committed project was created with Xcode 26.5. |
| **A physical iPhone running iOS 26** | Both targets set an iOS 26 deployment target, and ReplayKit Broadcast Extensions do not work reliably on the Simulator, so you need a real device. |
| **An Apple Developer account** | Needed to code-sign the main app **and** the broadcast extension for your device. |
| **A FastPix account** | Free to create at the [FastPix Dashboard](https://dashboard.fastpix.com). |
| **FastPix API credentials** | An Access Token ID (Token ID) and a Secret Key. |

The app reads your credentials from two environment variables at runtime:

| App environment variable | FastPix credential |
|---|---|
| `ACCESS_TOKEN_ID` | Access Token ID (Token ID) |
| `SECRET_KEY` | Secret Key |

> **Supported iOS versions:** The app's code supports **iOS 16.0+** (guarded with `if #available(iOS 16.0, *)`), but the committed project targets iOS 26. To run on an older OS, lower `IPHONEOS_DEPLOYMENT_TARGET` on **both** the `StreamGate` and `ScreenBroadcastExtension` targets in **Build Settings** (see [It will not build or install on iOS 16](#it-will-not-build-or-install-on-ios-16)).

> **Security:** Never commit your Access Token ID or Secret Key to source control. Set them in your Xcode scheme.

<br />

## 1. Check your macOS version

The build tools run on macOS. Confirm your version:

```bash
sw_vers
```

Output is similar to:

```text
ProductName:		macOS
ProductVersion:		26.6.2
BuildVersion:		25G83
```

Use a macOS version that supports Xcode 26. If macOS is too old, update it before you continue.

<br />

## 2. Check that Xcode is installed

This project builds with the full Xcode app. Confirm the command line points at Xcode:

```bash
xcodebuild -version
```

Expected output is similar to:

```text
Xcode 26.6
Build version 17F113
```

If instead you see `xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance`, point the command line at Xcode (this needs your password):

```bash
sudo xcode-select --switch /Applications/Xcode.app
sudo xcodebuild -license accept
```

Then run `xcodebuild -version` again. Do not continue until it prints a version.

<br />

## 3. Connect a physical iPhone

Screen recording relies on a ReplayKit Broadcast Extension, which does not work reliably on the Simulator, so run on a real iPhone. Connect and unlock your iPhone (tap **Trust This Computer** if prompted), then confirm the toolchain sees it:

```bash
xcrun xctrace list devices
```

Your iPhone appears under `== Devices ==` alongside any simulators.

<br />

## 4. Get your FastPix credentials

The app authenticates to FastPix to create a signed direct-upload URL, so you need your API credentials:

1. Sign up or log in and follow the [Activate Your Account](https://fastpix.com/docs/getting-started/activate-your-account) guide.
2. Copy your **Access Token ID** (Token ID) and **Secret Key**.

You set these as environment variables in [Configure your FastPix credentials](#9-configure-your-fastpix-credentials). Never commit real credentials to version control.

<br />

## 5. Clone the repository

```bash
git clone https://github.com/FastPix/iOS-StreamGate.git
cd iOS-StreamGate
open StreamGate.xcodeproj
```

> The clone creates a folder named `iOS-StreamGate` (the repository name). `StreamGate.xcodeproj` and the `StreamGate/` source folder both live inside it, so run the commands from the `iOS-StreamGate` root.

<br />

## 6. Verify the FastPix iOS Uploads SDK

StreamGate uses the [FastPix iOS Uploads SDK](https://github.com/FastPix/iOS-Uploads) for resumable chunked uploads. **The SDK is already integrated via Swift Package Manager**, so you don't need to add it manually - Xcode resolves it when you open the project.

To confirm it resolves from the command line, run this from the `iOS-StreamGate` root:

```bash
xcodebuild -project StreamGate.xcodeproj -scheme StreamGate -resolvePackageDependencies
```

The output confirms the package (the product is `fp-swift-upload-sdk`, module `fp_swift_upload_sdk`):

```text
Resolved source packages:
  fp-swift-upload-sdk: https://github.com/FastPix/iOS-Uploads.git @ 1.0.2
```

In Xcode, you can also confirm the main **StreamGate** target lists both the SDK and the embedded extension under **Frameworks, Libraries, and Embedded Content**:

```
Frameworks, Libraries, and Embedded Content
├── fp-swift-upload-sdk
└── ScreenBroadcastExtension.appex    →  Embed Without Signing
```

> `ScreenBroadcastExtension.appex` must be set to **Embed Without Signing** so iOS bundles the extension inside the main app at install time. Without this the broadcast picker shows no available extension.

For full SDK setup instructions, see [Set up Resumable Uploads for iOS](https://fastpix.com/docs/upload-videos/set-up-resumable-uploads-for-ios).

<br />

## 7. Verify App Groups on both targets

The `StreamGate` main app and the `ScreenBroadcastExtension` communicate through a shared App Group, which is already configured on both targets in the committed project. Confirm both use the **same** App Group under each target's **Signing & Capabilities → App Groups**:

```
group.com.streamgate.broadcast
```

> The App Group identifier must match exactly on both targets. If they differ, the extension and main app read and write different sandboxed directories, and no recorded file is ever detected.

To learn more, see [ReplayKit - Apple Developer Documentation](https://developer.apple.com/documentation/replaykit).

<br />

## 8. Verify the broadcast extension identifier

Confirm the broadcast extension's Bundle Identifier:

```
com.streamgate.StreamGate.ScreenBroadcastExtension
```

The same identifier is referenced in `BroadCastPickerView.swift`:

```swift
picker.preferredExtension = "com.streamgate.StreamGate.ScreenBroadcastExtension"
```

<br />

## 9. Configure your FastPix credentials

The app reads your FastPix credentials from environment variables at runtime via `ProcessInfo` (`ACCESS_TOKEN_ID` and `SECRET_KEY`). Set them in your Xcode scheme:

1. Go to **Product → Scheme → Edit Scheme** (or press `⌘ <`)
2. Select the **Run** action → **Arguments** tab
3. Under **Environment Variables**, add:

| Name | Value |
|------|-------|
| `ACCESS_TOKEN_ID` | Your FastPix Token ID |
| `SECRET_KEY` | Your FastPix Secret Key |

Never commit credentials to version control. Get your credentials from [Activate Your Account](https://fastpix.com/docs/getting-started/activate-your-account).

The app already requests camera and microphone access (declared in its generated `Info.plist`), so no extra permission setup is needed. For reference, it presents `NSCameraUsageDescription` ("Used to record videos.") and `NSMicrophoneUsageDescription` ("Used to record audio.").

<br />

## 10. Build and run on your device

In Xcode:

1. Open `StreamGate.xcodeproj`.
2. Select your connected iPhone as the run destination.
3. Under **Signing & Capabilities**, select your Apple Developer **Team** for **both** targets:
   * `StreamGate`
   * `ScreenBroadcastExtension`
4. Confirm the App Group `group.com.streamgate.broadcast` is enabled on both targets.
5. Build and run: **Product → Clean Build Folder**, then **Product → Run** (`⌘R`).

The first build compiles the Uploads SDK, so it can take a little longer. If the app does not launch on the device, open **Settings → General → VPN & Device Management** on the iPhone and trust your developer certificate, then run again.

<br />

## 11. Record, upload, and verify it works

Record a video with the camera, or start a screen broadcast, then let the app upload it. On success:

- The app uploads the file to FastPix in resumable chunks and polls until the media reaches `status: ready`.
- A shareable playback link appears in the form `https://stream.fastpix.com/<playbackId>.m3u8`.

If the upload does not start or no link appears, see [Troubleshooting](#troubleshooting).

<br />

## Tech stack

* **Language**: Swift
* **UI Framework**: SwiftUI
* **Screen Capture**: ReplayKit (`RPBroadcastSampleHandler`, `RPSystemBroadcastPickerView`)
* **Video Encoding**: AVFoundation (`AVAssetWriter`, H.264)
* **Inter-process Communication**: App Groups (shared `UserDefaults` + shared filesystem)
* **Uploading**: [FastPix iOS Uploads SDK](https://github.com/FastPix/iOS-Uploads)
* **Build Constraints**: `iOS 16.0+`, Xcode 15+, real device required

<br />

## Troubleshooting

### The broadcast picker shows no extension
Set `ScreenBroadcastExtension.appex` to **Embed Without Signing** in the main app target (see [Step 6](#6-verify-the-fastpix-ios-uploads-sdk)). Without this, iOS does not bundle the extension and the picker is empty.

### A recorded file is never detected
The App Group identifier must match exactly on both targets (`group.com.streamgate.broadcast`). If they differ, the extension and app use different sandboxed directories. See [Step 7](#7-verify-app-groups-on-both-targets).

### Upload fails or no shareable link appears
1. Confirm the `ACCESS_TOKEN_ID` and `SECRET_KEY` environment variables are set in your Run scheme (see [Step 9](#9-configure-your-fastpix-credentials)).
2. Confirm the credentials are active in your [FastPix Dashboard](https://dashboard.fastpix.com) and not expired.
3. Check network connectivity on the device.

### It will not build or install on iOS 16
The committed project targets iOS 26.0. Lower `IPHONEOS_DEPLOYMENT_TARGET` to 16.0 on both the `StreamGate` and `ScreenBroadcastExtension` targets (see [Before you begin](#before-you-begin)).

### Screen recording does not work on the Simulator
Use a physical iPhone - ReplayKit Broadcast Extensions are unreliable on the Simulator.

<br />

## Which FastPix repo do I need?

StreamGate shows uploads plus screen/camera capture in a full app. For the underlying SDKs and other platforms, use:

| I want to... | Repo |
|---|---|
| Add resumable uploads to an iOS app (the SDK this demo uses) | [iOS-Uploads](https://github.com/FastPix/iOS-Uploads) |
| Play FastPix video in an iOS app | [iOS-player](https://github.com/FastPix/iOS-player) |
| Add playback QoE analytics for AVPlayer (iOS / tvOS) | [iOS-data-avplayer-sdk](https://github.com/FastPix/iOS-data-avplayer-sdk) |
| Add resumable uploads in the browser | [web-uploads-sdk](https://github.com/FastPix/web-uploads-sdk) |
| Add a React uploader component | [react-web-uploader](https://github.com/FastPix/react-web-uploader) |

Browse everything in the [FastPix organization](https://github.com/orgs/FastPix/repositories).

<br />

## FAQ

**What does this app do?**
It records video (camera or full-screen ReplayKit recording) and uploads it directly to FastPix in resumable chunks, then returns a shareable playback link. See [What this app demonstrates](#what-this-app-demonstrates).

**Why does it need a physical iPhone?**
ReplayKit Broadcast Extensions do not work reliably on the Simulator. See [Before you begin](#before-you-begin).

**Where do I get my Token ID and Secret Key?**
From the FastPix Dashboard, via the [Activate Your Account](https://fastpix.com/docs/getting-started/activate-your-account) guide. See [Get your FastPix credentials](#4-get-your-fastpix-credentials).

**Where do I put my credentials?**
Set `ACCESS_TOKEN_ID` and `SECRET_KEY` as environment variables in your Xcode Run scheme. See [Step 9](#9-configure-your-fastpix-credentials).

**The broadcast picker is empty - why?**
The broadcast extension is not embedded. Set it to Embed Without Signing. See [Troubleshooting](#troubleshooting).

**Which iOS versions does it support?**
The app's code supports iOS 16.0+, but the committed project currently targets iOS 26.0. See [Before you begin](#before-you-begin) for how to lower it.

**How do I add resumable uploads to my own app?**
Use the FastPix iOS Uploads SDK directly. See [Which FastPix repo do I need?](#which-fastpix-repo-do-i-need)

<br />

## Important reference links

* FastPix Platform: [fastpix.com](https://fastpix.com)
* FastPix Access Token Guide: [Activate Your Account](https://fastpix.com/docs/getting-started/activate-your-account)
* FastPix VOD Upload API Docs: [Direct Upload Video Media](https://fastpix.com/docs/video-on-demand-api/upload-and-import-videos/direct-upload-video-media)
* FastPix iOS Uploads SDK: [FastPix/iOS-Uploads](https://github.com/FastPix/iOS-Uploads)
* Apple ReplayKit Docs: [ReplayKit - Apple Developer](https://developer.apple.com/documentation/replaykit)

<br />

## License

StreamGate is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
