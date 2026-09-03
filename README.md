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

## Prerequisites

Before you build the project, make sure you have:

- **Xcode** 15 or later. Note: the committed project was created with Xcode 26.5 and both targets set `IPHONEOS_DEPLOYMENT_TARGET = 26.0`, so as-is you need Xcode 26 and an iOS 26 device. To run on iOS 16 (which the app's code supports via `if #available(iOS 16.0, *)`), lower the deployment target to 16.0 on both targets.
- A **physical iPhone** - ReplayKit Broadcast Extensions do not work reliably on the Simulator.
- An **Apple Developer account** (for signing the app and the extension).
- A **FastPix account** with an Access Token ID (Token ID) and a Secret Key.

<br />

## Get your FastPix credentials

The app authenticates to FastPix to create a signed direct-upload URL, so you need your API credentials:

1. Sign up or log in and follow the [Activate Your Account](https://fastpix.com/docs/getting-started/activate-your-account) guide.
2. Copy your **Access Token ID** (Token ID) and **Secret Key**.

You will set these as environment variables in Step 5. Never commit real credentials to version control.

<br />

## Step 1: Clone the repository

```bash
git clone https://github.com/FastPix/iOS-StreamGate.git
cd StreamGate
open StreamGate.xcodeproj
```

<br />

## Step 2: Add the FastPix iOS Uploads SDK

StreamGate uses the [FastPix iOS Uploads SDK](https://github.com/FastPix/iOS-Uploads) for resumable chunked uploads.

**Via Swift Package Manager:**

1. In Xcode go to **File → Add Package Dependencies**
2. Enter the package URL:
   ```
   https://github.com/FastPix/iOS-Uploads
   ```
3. Select the latest version and add it to the **StreamGate** main target

After adding, verify the SDK appears under the main target's **Frameworks, Libraries, and Embedded Content** alongside `ScreenBroadcastExtension.appex`:

```
Frameworks, Libraries, and Embedded Content
├── fp-swift-upload-sdk
└── ScreenBroadcastExtension.appex    →  Embed Without Signing
```

> `ScreenBroadcastExtension.appex` must be set to **Embed Without Signing** so iOS bundles the extension inside the main app at install time. Without this the broadcast picker will show no available extension.

For full SDK setup instructions refer to the official guide: [Set up Resumable Uploads for iOS](https://fastpix.com/docs/upload-videos/set-up-resumable-uploads-for-ios)

<br />

## Step 3: Configure App Groups

Enable the same App Group for both targets:

**Main App Target**

```
Signing & Capabilities
→ App Groups
→ group.com.streamgate.broadcast
```

**ScreenBroadcastExtension Target**

```
Signing & Capabilities
→ App Groups
→ group.com.streamgate.broadcast
```

> The App Group identifier must match exactly on both targets. If they differ, the extension and main app write and read from different sandboxed directories and no recorded file will ever be detected.

To learn more about App Groups and Broadcast Extensions refer to: [ReplayKit - Apple Developer Documentation](https://developer.apple.com/documentation/replaykit)

<br />

## Step 4: Configure the broadcast extension

Verify the Broadcast Extension Bundle Identifier:

```
com.streamgate.StreamGate.ScreenBroadcastExtension
```

And ensure the same identifier is referenced in `BroadcastPickerView.swift`:

```swift
picker.preferredExtension = "com.streamgate.StreamGate.ScreenBroadcastExtension"
```

<br />

## Step 5: Configure your FastPix credentials

The app reads your FastPix credentials from environment variables at runtime via `ProcessInfo` (`ACCESS_TOKEN_ID` and `SECRET_KEY`). Set them in your Xcode scheme:

1. Go to **Product → Scheme → Edit Scheme** (or press `⌘ <`)
2. Select the **Run** action → **Arguments** tab
3. Under **Environment Variables**, add:

| Name | Value |
|------|-------|
| `ACCESS_TOKEN_ID` | Your FastPix Token ID |
| `SECRET_KEY` | Your FastPix Secret Key |

Never commit credentials to version control. Get your credentials from [Activate Your Account](https://fastpix.com/docs/getting-started/activate-your-account).

<br />

## Step 6: Camera and microphone permissions

The app already requests camera and microphone access (declared in its generated `Info.plist`), so no action is needed. For reference, these are the usage descriptions it presents:

```xml
<key>NSCameraUsageDescription</key>
<string>Used to record videos.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Used to record audio.</string>
```

<br />

## Step 7: Build and run

**Using Xcode**

1. Open `StreamGate.xcodeproj`
2. Select a physical iPhone as the run destination
3. Ensure your Apple Developer Team is selected for both:
   * `StreamGate`
   * `ScreenBroadcastExtension`
4. Verify App Groups are enabled on both targets:
   * `group.com.streamgate.broadcast`
5. Build and run:

```
Product → Clean Build Folder
Product → Build
Product → Run
```

<br />

## Verify it works

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
Set `ScreenBroadcastExtension.appex` to **Embed Without Signing** in the main app target (see [Step 2](#step-2-add-the-fastpix-ios-uploads-sdk)). Without this, iOS does not bundle the extension and the picker is empty.

### A recorded file is never detected
The App Group identifier must match exactly on both targets (`group.com.streamgate.broadcast`). If they differ, the extension and app use different sandboxed directories. See [Step 3](#step-3-configure-app-groups).

### Upload fails or no shareable link appears
1. Confirm the `ACCESS_TOKEN_ID` and `SECRET_KEY` environment variables are set in your Run scheme (see [Step 5](#step-5-configure-your-fastpix-credentials)).
2. Confirm the credentials are active in your [FastPix Dashboard](https://dashboard.fastpix.com) and not expired.
3. Check network connectivity on the device.

### It will not build or install on iOS 16
The committed project targets iOS 26.0. Lower `IPHONEOS_DEPLOYMENT_TARGET` to 16.0 on both the `StreamGate` and `ScreenBroadcastExtension` targets (see [Prerequisites](#prerequisites)).

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
ReplayKit Broadcast Extensions do not work reliably on the Simulator. See [Prerequisites](#prerequisites).

**Where do I get my Token ID and Secret Key?**
From the FastPix Dashboard, via the [Activate Your Account](https://fastpix.com/docs/getting-started/activate-your-account) guide. See [Get your FastPix credentials](#get-your-fastpix-credentials).

**Where do I put my credentials?**
Set `ACCESS_TOKEN_ID` and `SECRET_KEY` as environment variables in your Xcode Run scheme. See [Step 5](#step-5-configure-your-fastpix-credentials).

**The broadcast picker is empty - why?**
The broadcast extension is not embedded. Set it to Embed Without Signing. See [Troubleshooting](#troubleshooting).

**Which iOS versions does it support?**
The app's code supports iOS 16.0+, but the committed project currently targets iOS 26.0. See [Prerequisites](#prerequisites) for how to lower it.

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
