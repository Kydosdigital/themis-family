import SwiftUI

/// `SectionHeader` · group label / eyebrow: 12 pt, heavy, +9% tracking, capitals.
struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var color: Color = ThemisColor.textSecondary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .themisFont(.sectionLabel)
                .foregroundStyle(color)
                .accessibilityAddTraits(.isHeader)
            if let subtitle {
                Text(subtitle)
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
            }
        }
        .padding(.top, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Name kept for the pre-handoff scaffold views.
typealias ThemisSectionHeader = SectionHeader
