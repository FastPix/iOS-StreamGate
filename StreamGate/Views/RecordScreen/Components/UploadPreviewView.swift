import SwiftUI
import AVKit

struct UploadPreviewView: View {
    
    let videoURL: URL
    
    @StateObject private var vm = UploadViewModel()
    
    @State private var player = AVPlayer()
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                
                VStack(spacing: 24) {
                    ZStack {
                               Color.black.ignoresSafeArea()

                               VStack {
                               }
                           }
                           .navigationTitle("Upload Video")
                           .navigationBarTitleDisplayMode(.inline)
                    
                    // Video Player
                    VideoPlayer(player: player)
                        .frame(height: 300)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 24)
                        )
                    
                    // Upload Progress
                    if vm.isUploading {
                        
                        VStack(spacing: 12) {
                            
                            ProgressView(
                                value: vm.uploadProgress
                            )
                            .tint(.orange)
                            
                            Text(
                                "\(Int(vm.uploadProgress * 100))%"
                            )
                            .foregroundStyle(.white)
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    
                    // Upload Success
                    if vm.uploadCompleted {
                        
                        if #available(iOS 16.0, *) {
                            Text("Upload Completed")
                                .foregroundStyle(.green)
                                .fontWeight(.semibold)
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    
                    // Processing the video
                    if vm.isProcessingVideo {

                        VStack(spacing: 12) {

                            ProgressView()

                            Text("Processing video...")
                                .foregroundStyle(.white)
                        }
                        .padding()
                    }
                    
                    // Shared URL
                    if let sharedURL = vm.sharedURL {

                        VStack(spacing: 20) {

                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.green)

                            Text("Video Ready")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)

                            Text(sharedURL)
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            HStack(spacing: 16) {

                                // Copy Link Button
                                Button {

                                    UIPasteboard.general.string = sharedURL

                                } label: {

                                    HStack(spacing: 8) {

                                        Image(systemName: "doc.on.doc.fill")

                                        Text("Copy Link")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.orange)
                                    .foregroundStyle(.white)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 16)
                                    )
                                    .shadow(
                                        color: .orange.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                                }

                                // Preview Button
                                Button {

                                    if let url = URL(string: sharedURL) {

                                        UIApplication.shared.open(url)
                                    }

                                } label: {

                                    HStack(spacing: 8) {

                                        Image(systemName: "play.fill")

                                        Text("Preview")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.orange)
                                    .foregroundStyle(.white)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 16)
                                    )
                                    .shadow(
                                        color: .orange.opacity(0.4),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    Color.orange.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                    }
                    
                    // Error
                    if let error = vm.uploadError {
                        
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
        }
        .task {
            
            // Setup Player
            let playerItem = AVPlayerItem(
                url: videoURL
            )
            
            player.replaceCurrentItem(
                with: playerItem
            )
            
            player.play()

            // Upload
            await vm.uploadVideo(
                fileURL: videoURL
            )
        }
    }
}
