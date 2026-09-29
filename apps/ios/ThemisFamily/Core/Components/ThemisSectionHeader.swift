import SwiftUI

struct ThemisSectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.xs) {
            Text(title)
                .font(ThemisTypography.section)
                .foregroundStyle(ThemisColor.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(ThemisTypography.caption)
                    .foregroundStyle(ThemisColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
