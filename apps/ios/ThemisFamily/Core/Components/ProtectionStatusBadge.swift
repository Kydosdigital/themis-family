import SwiftUI

struct ProtectionStatusBadge: View {
    let status: ProtectionStatus

    var body: some View {
        Label(status.title, systemImage: status.symbolName)
            .font(ThemisTypography.caption)
            .foregroundStyle(ThemisColor.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(ThemisColor.status(status).opacity(0.22))
            .clipShape(Capsule())
            .accessibilityLabel("Protection status: \(status.title)")
    }
}
