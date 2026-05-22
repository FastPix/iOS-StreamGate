import Foundation
import fp_swift_upload_sdk
import Combine

@MainActor
final class UploadViewModel: NSObject,ObservableObject, UploadSDKErrorDelegate  {


    @Published var uploadProgress: Double = 0
    @Published var isUploading = false
    @Published var uploadCompleted = false
    @Published var uploadError: String?
    @Published var sharedURL: String?
    @Published var isProcessingVideo = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let uploader = Uploads()
    private let uploadService = UploadService()
    private var didFetchPlaybackURL = false
    
    override init() {

         super.init()

         uploader.errorDelegate = self
     }
    
    func uploadSDKDidFail(
            with error: String
        ) {

            DispatchQueue.main.async {

                self.isUploading = false

                self.uploadCompleted = false

                self.uploadError = self.mapSDKError(error)
            }
        }
    
    func uploadVideo(
        fileURL: URL
    ) async {
        resetState()

        do {

            isUploading = true
            uploadCompleted = false

            // getting signed url and upload id from fastpix server
            guard let (signedUrl, uploadId) = try await uploadService.createDirectUpload() else {
                return
            }
            
            // watching the progress of the upload
            uploader.progressHandler = { [weak self] progress in
                guard let self else { return }

                Task { @MainActor in

                    self.uploadProgress = Double(progress)

                    if progress >= 1.0 && !self.didFetchPlaybackURL {

                        self.didFetchPlaybackURL = true

                        self.isUploading = false
                        self.uploadCompleted = true
                        self.isProcessingVideo = true
        
                        // getting the status
                        await self.pollVideoStatus(
                            uploadId: uploadId
                        )
                    }
                }
            }

            // uploading file url to sdk
           uploader.uploadFile(
                file: fileURL,
                endpoint: signedUrl.absoluteString,
                chunkSizeKB: 5120
            )

        } catch {
            handleSystemError(error)
        }
    }
    
    private func pollVideoStatus(
        uploadId: String
    ) async {

        var attempts = 0
        let maxAttempts = 30

        while attempts < maxAttempts {

            attempts += 1

            if let (status, playbackId) =
                await self.uploadService.getStatus(
                    uploadId: uploadId
                ) {

                switch status.lowercased() {

                case "ready":
                    
                    self.isProcessingVideo = false
                    if let playbackId {

                        self.sharedURL =
                        "https://stream.fastpix.io/\(playbackId).m3u8"

                    }

                    return

                case "failed":
                    self.isProcessingVideo = false
                    self.uploadError =
                    "Video processing failed"

                    return

                default:
                    print("video still processing...")
                }
            }

            // wait before next poll
            try? await Task.sleep(
                nanoseconds: 3_000_000_000
            )
        }

        self.uploadError =
        "Video processing timeout"
    }
    
    private func handleSystemError(
            _ error: Error
        ) {

            isUploading = false

            uploadCompleted = false

            if let urlError = error as? URLError {

                switch urlError.code {

                case .notConnectedToInternet:

                    uploadError = "No internet connection."

                case .timedOut:

                    uploadError = "The request timed out."

                case .cannotFindHost:

                    uploadError = "Server not reachable."

                default:

                    uploadError = urlError.localizedDescription
                }

            } else {

                uploadError = error.localizedDescription
            }
        }

        // MARK: - SDK Error Mapping
    
        private func mapSDKError(
            _ error: String
        ) -> String {

            let lowercased = error.lowercased()

            if lowercased.contains("network") {

                return "Network issue during upload."

            } else if lowercased.contains("timeout") {

                return "Upload timed out."

            } else if lowercased.contains("permission") {

                return "Permission denied."

            } else if lowercased.contains("abort") {

                return "Upload was cancelled."

            }

            return error
        }

    
    func resetState() {
        
        didFetchPlaybackURL = false

        uploadProgress = 0

        isUploading = false

        uploadCompleted = false

        uploadError = nil
    }


    func pauseUpload() {

        uploader.pause()
    }


    func resumeUpload() {

        uploader.resume()
    }


    func abortUpload() {

        uploader.abort()

        resetState()
    }
}
