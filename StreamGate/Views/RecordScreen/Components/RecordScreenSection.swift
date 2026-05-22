import SwiftUI
import ReplayKit

struct RecordScreenSection: View {
    let onTap: () -> Void
    @Binding var isRecording: Bool

    var body: some View {
        HStack(spacing: 14) {

            BroadcastPickerView()
                .frame(width: 44, height: 44)
                .allowsHitTesting(false)

            Text(isRecording ? "Stop Recording" : "Start Recording")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))

            Spacer()

        }
        .padding(.horizontal, 20)
        .frame(width: 300, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isRecording ? Color(red: 0.6, green: 0, blue: 0) : Color.red)
                .animation(.easeInOut(duration: 0.2), value: isRecording)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()

            BroadcastPickerView.trigger()

        }
    }
}
