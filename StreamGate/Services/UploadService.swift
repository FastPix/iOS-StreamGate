import Foundation

private let apiKey: String = "https://api.fastpix.io/v1/on-demand/upload"

private let accessTokenID: String = ProcessInfo.processInfo.environment["ACCESS_TOKEN_ID"] ?? ""
private let secretKey: String = ProcessInfo.processInfo.environment["SECRET_KEY"] ?? ""

final class UploadService {
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func createDirectUpload() async throws -> (URL, String)? {
    
        let parameters: [String: Any] = [
                    "corsOrigin": "*",
                    "pushMediaSettings": [
                        "accessPolicy": "public",
                        "generateSubtitles": true,
                        "normalizeAudio": true,
                        "maxResolution": "1080p",
                    ]
                ]
                
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            throw NSError(domain: "com.example.app", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to serialize parameters"
            ])
        }
        
        let request = try {
            var req = try URLRequest(url: fullURL(forEndpoint: "upload"))
            req.httpBody = jsonData
            req.httpMethod = "POST"
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
            req.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let credentials = "\(accessTokenID):\(secretKey)"
            let basicAuthCredential = Data(credentials.utf8).base64EncodedString()
            req.addValue("Basic \(basicAuthCredential)", forHTTPHeaderField: "Authorization")
            
            return req
        }()
        
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CreateUploadError.custom("Invalid HTTP response")
        
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            do {
                if let jsonDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataDic = jsonDictionary["data"] as? [String: Any],
                   let uploadId = dataDic["uploadId"] as? String,
                   let urlString = dataDic["url"] as? String,
                   let uploadUrl = URL(string: urlString) {
                    return (uploadUrl, uploadId)
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        } else {
            let errorMessage = String(decoding: data, as: UTF8.self)
            throw CreateUploadError.custom("Upload POST failed: HTTP \(httpResponse.statusCode):\n\(errorMessage)")
        }
    }
    
    func getStatus(
        uploadId: String
    ) async -> (String, String?)? {

        let credentials = Data(
            "\(accessTokenID):\(secretKey)".utf8
        ).base64EncodedString()

        guard let url = URL(
            string: "https://api.fastpix.io/v1/on-demand/\(uploadId)"
        ) else {
            return nil
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        request.setValue(
            "Basic \(credentials)",
            forHTTPHeaderField: "Authorization"
        )

        do {

            let (data, response) =
            try await URLSession.shared.data(for: request)

            guard let httpResponse =
                    response as? HTTPURLResponse else {

                return nil
            }

            guard (200...299).contains(
                httpResponse.statusCode
            ) else {

                return nil
            }

            let decoded = try JSONDecoder().decode(
                MediaResponse.self,
                from: data
            )

            let status = decoded.data.status

            let playbackId =
            decoded.data.playbackIds.first?.id

            return (status, playbackId)

        } catch {
            return nil
        }
    }
    
    // Generates a full URL for a given endpoint in the FastPix Video public API
    private func fullURL(forEndpoint endpoint: String) throws -> URL {
        let fullPath = "https://api.fastpix.io/v1/on-demand/\(endpoint)"
        guard let url = URL(string: fullPath) else {
            throw CreateUploadError.custom("Bad endpoint: \(endpoint)")
        }
        return url
    }
    
}
