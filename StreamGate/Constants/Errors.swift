import SwiftUI
enum CreateUploadError: LocalizedError {
    
    case invalidResponse
    case invalidUploadURL
    case serializationFailed
    case badEndpoint(String)
    case serverError(statusCode: Int, message: String)
    case custom(String)
    
    var errorDescription: String? {
        switch self {
            
        case .invalidResponse:
            return "Invalid HTTP response received from server."
            
        case .invalidUploadURL:
            return "Failed to generate a valid upload URL."
            
        case .serializationFailed:
            return "Failed to serialize request body."
            
        case .badEndpoint(let endpoint):
            return "Invalid endpoint: \(endpoint)"
            
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
            
        case .custom(let message):
            return message
        }
    }
}
