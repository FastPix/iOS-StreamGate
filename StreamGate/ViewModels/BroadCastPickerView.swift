import SwiftUI
import ReplayKit

struct BroadcastPickerView: UIViewRepresentable {
    
    static weak var pickerView: RPSystemBroadcastPickerView?
    
    func makeUIView(context: Context) -> RPSystemBroadcastPickerView {
        let picker = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        picker.showsMicrophoneButton = false
        
        picker.preferredExtension = "com.streamgate.StreamGate.ScreenBroadcastExtension"
        
        if let button = picker.subviews.first(where: { $0 is UIButton }) as? UIButton {
            button.imageView?.tintColor = .white
        }
        
        // 💡 THE MISSING LINE: Assign the created picker to your static reference so trigger() can find it!
        DispatchQueue.main.async {
            BroadcastPickerView.pickerView = picker
        }
        
        return picker
    }
    
    func updateUIView(_ uiView: RPSystemBroadcastPickerView, context: Context) {}
}

// MARK: - Trigger Helper
extension BroadcastPickerView {
    static func trigger() {
        guard let picker = pickerView else {
         
            return
        }
        
        guard let button = picker.subviews.first(where: { $0 is UIButton }) as? UIButton else {
            return
        }
        
        button.sendActions(for: .touchUpInside)
    }
}
