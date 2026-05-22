import SwiftUI

struct RecordButton : View {
    var body: some View {
       
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)

                Text("Record your screen or camera")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 22)
            .frame(height: 70)
            .background {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.black)
                    .overlay {
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.15), lineWidth: 2)
                    }
                    
            }
        
    }
}
