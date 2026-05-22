import Foundation
import AVFoundation
import Photos
import UIKit

final class PermissionManager {

    static let shared = PermissionManager()

    private init() {}

    // MARK: - Public API
    
    func status(for permission: PermissionType)
    -> PermissionStatus {

        switch permission {

        case .camera:

            return mapCameraStatus(
                AVCaptureDevice.authorizationStatus(
                    for: .video
                )
            )

        case .microphone:

            return mapMicrophoneStatus(
                AVCaptureDevice.authorizationStatus(
                    for: .audio
                )
            )

        case .photoLibrary:

            return mapPhotoLibraryStatus(
                PHPhotoLibrary.authorizationStatus(
                    for: .readWrite
                )
            )
        }
    }

    // MARK: - Request Permission

    func request(
        _ permission: PermissionType
    ) async -> PermissionStatus {

        switch permission {

        case .camera:

            let granted =
                await AVCaptureDevice.requestAccess(
                    for: .video
                )

            return granted ? .authorized : .denied

        case .microphone:

            let granted =
                await AVCaptureDevice.requestAccess(
                    for: .audio
                )

            return granted ? .authorized : .denied

        case .photoLibrary:

            let status =
                await PHPhotoLibrary.requestAuthorization(
                    for: .readWrite
                )

            return mapPhotoLibraryStatus(status)
        }
    }

    // MARK: - Open Settings

    func openSettings() {

        guard let url = URL(
            string: UIApplication.openSettingsURLString
        ) else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {

            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Mapping Helpers

private extension PermissionManager {

    func mapCameraStatus(
        _ status: AVAuthorizationStatus
    ) -> PermissionStatus {

        switch status {

        case .authorized:
            return .authorized

        case .denied:
            return .denied

        case .restricted:
            return .restricted

        case .notDetermined:
            return .notDetermined

        @unknown default:
            return .denied
        }
    }

    func mapMicrophoneStatus(
        _ status: AVAuthorizationStatus
    ) -> PermissionStatus {

        switch status {

        case .authorized:
            return .authorized

        case .denied:
            return .denied

        case .restricted:
            return .restricted

        case .notDetermined:
            return .notDetermined

        @unknown default:
            return .denied
        }
    }

    func mapPhotoLibraryStatus(
        _ status: PHAuthorizationStatus
    ) -> PermissionStatus {

        switch status {

        case .authorized:
            return .authorized

        case .limited:
            return .limited

        case .denied:
            return .denied

        case .restricted:
            return .restricted

        case .notDetermined:
            return .notDetermined

        @unknown default:
            return .denied
        }
    }
}
