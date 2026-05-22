import SwiftUI
import Combine
import ReplayKit
import AVFoundation

struct RecordView: View {

    // MARK: - Recording State

    @State private var showCamera = false
    @State private var navigateToPreview = false
    @State private var recordedVideoURL: URL?
    @State private var isRecording = false

    // MARK: - Permission State

    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""

    // MARK: - Dependencies

    @StateObject private var vm = UploadViewModel()

    private let timer = Timer.publish(
        every: 2.0,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Body

    var body: some View {

        Group {

            if #available(iOS 16.0, *) {

                NavigationStack {

                    ZStack {

                        Color.black
                            .ignoresSafeArea()

                        VStack(spacing: 60) {

                            HeaderRecordSection()

                            VStack(spacing: 18) {

                                cameraSection

                                screenRecordingSection
                            }
                        }
                    }
                    .sheet(isPresented: $showCamera) {

                        VideoRecorderView { videoURL in

                            recordedVideoURL = videoURL
                            navigateToPreview = true
                        }
                    }
                    .navigationDestination(
                        isPresented: $navigateToPreview
                    ) {

                        if let videoURL = recordedVideoURL {

                            UploadPreviewView(
                                videoURL: videoURL
                            )
                        }
                    }
                    .alert(
                        "Permission Required",
                        isPresented: $showPermissionAlert
                    ) {

                        Button("Open Settings") {

                            PermissionManager.shared
                                .openSettings()
                        }

                        Button(
                            "Cancel",
                            role: .cancel
                        ) {}

                    } message: {

                        Text(permissionMessage)
                    }
                    .onAppear {

                        clearPreviousRecording()
                    }
                    .onReceive(timer) { _ in

                        syncRecordingState()

                        Task{
                           await checkForBroadcastVideo()
                        }
                    }
                }

            } else {

                Text("iOS 16 Required")
            }
        }
    }
}

// MARK: - Sections

private extension RecordView {

    var cameraSection: some View {

        RecordCameraSection {

            Task {

                let hasPermission =
                    await handleCameraRecordingPermission()

                guard hasPermission else {
                    return
                }

                await MainActor.run {

                    showCamera = true
                }
            }
        }
    }

    var screenRecordingSection: some View {

        RecordScreenSection(

            onTap: {

                Task {

                    let hasPermission =
                        await handleScreenRecordingPermission()

                    guard hasPermission else {
                        return
                    }

                    if isRecording {

                        clearPreviousRecording()
                    }
                }
            },

            isRecording: $isRecording
        )
    }
}

// MARK: - Permission Handling

private extension RecordView {

    func handleCameraRecordingPermission() async -> Bool {

        let cameraStatus =
            PermissionManager.shared.status(
                for: .camera
            )

        let micStatus =
            PermissionManager.shared.status(
                for: .microphone
            )

        // Already Denied

        if cameraStatus == .denied ||
            micStatus == .denied {

             showPermissionDenied(
                message: """
                Please enable Camera and Microphone access from Settings.
                """
            )

            return false
        }

        // Camera Permission
        if cameraStatus == .notDetermined {

            let result =
                await PermissionManager.shared.request(
                    .camera
                )

            guard result == .authorized else {

                 showPermissionDenied(
                    message: """
                    Camera access is required for recording videos.
                    """
                )

                return false
            }
        }

        // Microphone Permission
        if micStatus == .notDetermined {

            let result =
                await PermissionManager.shared.request(
                    .microphone
                )

            guard result == .authorized else {

                 showPermissionDenied(
                    message: """
                    Microphone access is required for recording audio.
                    """
                )

                return false
            }
        }

        return true
    }

    func handleScreenRecordingPermission() async -> Bool {

        let micStatus =
            PermissionManager.shared.status(
                for: .microphone
            )

        // Already Denied
        if micStatus == .denied {

             showPermissionDenied(
                message: """
                Please enable Microphone access from Settings.
                """
            )

            return false
        }

        // Request Permission
        if micStatus == .notDetermined {

            let result =
                await PermissionManager.shared.request(
                    .microphone
                )

            guard result == .authorized else {

                 showPermissionDenied(
                    message: """
                    Microphone access is required for screen recordings.
                    """
                )

                return false
            }
        }

        return true
    }

    @MainActor
    func showPermissionDenied(
        message: String
    ) {

        permissionMessage = message
        showPermissionAlert = true
    }
}

// MARK: - Recording State

private extension RecordView {

    func syncRecordingState() {

        let broadcasting =
            UserDefaults(
                suiteName: "group.com.streamgate.broadcast"
            )?
            .bool(forKey: "isBroadcasting") ?? false

        if isRecording != broadcasting {

            isRecording = broadcasting
        }
    }
}

// MARK: - Broadcast Video Handling

private extension RecordView {

    func checkForBroadcastVideo() async {

        guard
            let defaults = UserDefaults(
                suiteName: "group.com.streamgate.broadcast"
            ),
            let path = defaults.string(
                forKey: "recordedVideoURL"
            )
        else {
            return
        }

        let fileURL = URL(fileURLWithPath: path)

        guard FileManager.default.fileExists(
            atPath: fileURL.path
        ) else {
            return
        }

        // Validate asset
        let asset = AVURLAsset(url: fileURL)

        do {

            let isPlayable =
                try await asset.load(.isPlayable)

            guard isPlayable else {
                return
            }

        } catch {
            return
        }

        defaults.removeObject(
            forKey: "recordedVideoURL"
        )

        recordedVideoURL = fileURL

        navigateToPreview = true
    }
}

// MARK: - Cleanup

private extension RecordView {

    func clearPreviousRecording() {

        let suite = "group.com.streamgate.broadcast"

        guard let defaults = UserDefaults(
            suiteName: suite
        ) else {
            return
        }

        if let path = defaults.string(
            forKey: "recordedVideoURL"
        ) {

            let fileURL =
                URL(fileURLWithPath: path)

            if FileManager.default.fileExists(
                atPath: fileURL.path
            ) {

                do {

                    try FileManager.default
                        .removeItem(at: fileURL)

                } catch {

                    print(
                        "Failed to delete recording:",
                        error.localizedDescription
                    )
                }
            }
        }

        defaults.removeObject(
            forKey: "recordedVideoURL"
        )

        defaults.synchronize()
    }
}
