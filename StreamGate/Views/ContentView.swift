
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        if #available(iOS 16.0, *) {
            UploadView()
        } else {
            // Fallback on earlier versions
        }
    }
}
