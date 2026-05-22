import Foundation

enum PermissionStatus {

    case authorized
    case denied
    case restricted
    case notDetermined
    case limited
}

enum PermissionType {

    case camera
    case microphone
    case photoLibrary
}
