import SwiftUI

struct HeaderRecordSection:View{
    var body: some View {

        VStack(spacing: 5) {

            // Logo + Brand
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.orange)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }.padding(.top)

                Text("StreamGate")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white).padding(.top)
            }

            VStack(spacing: 16) {
                Text("Record a video")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)

                Text("Choose screen recording or camera — your video will upload automatically when you stop.")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: 500)
                    .minimumScaleFactor(0.5)
            }
        }
        .padding(.top, 40)

    }
}
