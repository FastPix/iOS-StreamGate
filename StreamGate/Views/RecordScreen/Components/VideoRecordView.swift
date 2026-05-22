import SwiftUI
import UIKit

struct VideoRecorderView: UIViewControllerRepresentable {
    
    var onVideoRecorded: (URL) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    class Coordinator: NSObject,
                       UINavigationControllerDelegate,
                       UIImagePickerControllerDelegate {
        
        let parent: VideoRecorderView
        
        init(parent: VideoRecorderView) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            
            if let videoURL = info[.mediaURL] as? URL {
                parent.onVideoRecorded(videoURL)
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            parent.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        
        picker.delegate = context.coordinator
        
        #if targetEnvironment(simulator)
        
        // Simulator fallback
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        
        #else
        
        // Real device camera
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            fatalError("Camera not available")
        }
        
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeMedium
        picker.videoMaximumDuration = 60
        
        #endif
        
        return picker
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
    }
}
