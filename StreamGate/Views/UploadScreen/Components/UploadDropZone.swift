import SwiftUI

struct UploadDropZone: View {

    var body: some View {

        VStack(spacing: 24) {

            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.08))
                .frame(width: 100, height: 100)
                .overlay {

                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                }

            VStack(spacing: 10) {

                Text("Drop a video here")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text("or click to browse")
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background {

            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    Color.white.opacity(0.2),
                    style: StrokeStyle(
                        lineWidth: 2,
                        dash: [8]
                    )
                )
        }
        .contentShape(Rectangle())
    }
}
