import SwiftUI

struct ThemisButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: String
    var systemImage: String? = nil
    var style: Style = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ThemisSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(ThemisTypography.bodyStrong)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .foregroundStyle(style == .primary ? Color.white : ThemisColor.textPrimary)
        .background(style == .primary ? ThemisColor.actionPrimary : ThemisColor.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: ThemisSpacing.controlRadius, style: .continuous))
        .accessibilityLabel(title)
    }
}
