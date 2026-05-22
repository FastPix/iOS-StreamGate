import SwiftUI
import PhotosUI
import AVKit

@available(iOS 16.0, *)
struct UploadView: View {

    @StateObject private var vm = UploadViewModel()

    @State private var selectedItem: PhotosPickerItem?
    @State private var player = AVPlayer()
    @State private var selectedVideoURL: URL?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    

    var body: some View {

        if #available(iOS 17.0, *) {
            NavigationStack {
                
                ZStack {
                    
                    Color.black
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack(spacing: 24) {
                            
                            HeaderSection()
                            
                            // Video Picker
                            
                        if(selectedVideoURL == nil)
                            {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .videos
                            ) {
                                
                                UploadDropZone()
                            }
                        }
                            
                            if selectedVideoURL != nil {
                                
                                VideoPlayer(player: player)
                                    .frame(height:screenHeight * 0.35)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 24)
                                    )
                            }
                            
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
                                
                                Text("Upload Completed")
                                    .foregroundStyle(.green)
                                    .fontWeight(.semibold)
                            }
                            
                            if vm.isProcessingVideo {

                                VStack(spacing: 12) {

                                    ProgressView()

                                    Text("Processing video...")
                                        .foregroundStyle(.white)
                                }
                                .padding()
                            }
                            
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

                                        // Copy Button
                                        Button {

                                            UIPasteboard.general.string = sharedURL

                                        } label: {

                                            HStack {

                                                Image(systemName: "doc.on.doc.fill")

                                                Text("Copy Link")
                                                    .fontWeight(.semibold)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(Color.orange)
                                            .foregroundStyle(.white)
                                            .clipShape(
                                                RoundedRectangle(cornerRadius: 14)
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

                                            HStack {

                                                Image(systemName: "play.fill")

                                                Text("Preview")
                                                    .fontWeight(.semibold)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(Color.orange)
                                            .foregroundStyle(.white)
                                            .clipShape(
                                                RoundedRectangle(cornerRadius: 14)
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
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.horizontal)
                            }
                            if let error = vm.uploadError {

                                VStack(spacing: 12) {

                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.red)
                                        .font(.title2)

                                    Text(error)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                            }
                            
                            SeparatorSection()
                            
                            NavigationLink {
                                
                                RecordView()
                                
                            } label: {
                                
                                RecordButton()
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 40)
                        .frame(maxWidth: 500)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .onChange(of: selectedItem) {
                
                Task {
                    
                    guard let item = selectedItem else {
                        return
                    }
                    
                    do {
                        
                        if let movie = try await item.loadTransferable(
                            type: CustomMovieFile.self
                        ) {
                            
                            // Store Selected Video URL
                            selectedVideoURL = movie.url
                            
                            // Create Player Item
                            let playerItem = AVPlayerItem(
                                url: movie.url
                            )
                            
                            // Load Into Video Player
                            player.replaceCurrentItem(
                                with: playerItem
                            )
                            
                            // Auto Play
                            player.play()
                            
                            // Start Upload
                            await vm.uploadVideo(
                                fileURL: movie.url
                            )
                        }
                        
                    } catch {
                        // show the error
                        
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
