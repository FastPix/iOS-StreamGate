import SwiftUI

struct RecordCameraSection: View {
    
    let onTap: () -> Void
    
    var body: some View {
        
        VStack {
          
            Button {
                onTap()
            } label: {
                
                HStack(spacing: 14) {
                    
                    Image(systemName: "video")
                        .font(.system(size: 28, weight: .semibold))
                    
                    Text("Record Camera")
                        .font(.system(size: 22, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: 300)
                .frame(height: 70)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(.black).opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                )
            }
        }
    }
}
