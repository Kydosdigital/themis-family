import SwiftUI

struct ThemisCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(ThemisSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ThemisColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: ThemisSpacing.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: ThemisSpacing.cardRadius, style: .continuous)
                    .stroke(ThemisColor.border, lineWidth: 1)
            }
    }
}
