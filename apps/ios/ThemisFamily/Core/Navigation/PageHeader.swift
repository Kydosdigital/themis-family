import SwiftUI

/// `PageHeader` · tab-root header: optional small subtitle above a large page title,
/// with the Action Centre bell or a trailing text action.
///
/// Drawn in content rather than as a navigation-bar large title, because the approved
/// frames set the subtitle ("Good evening") above the title, which the system large
/// title cannot do. Tab roots hide the navigation bar; pushed screens use the native bar.
struct PageHeader<Trailing: View>: View {
    let title: String
    var subtitle: String? = nil
    private let trailing: Trailing

    init(title: String, subtitle: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: ThemisSpacing.inline12) {
            VStack(alignment: .leading, spacing: 2) {
                if let subtitle {
                    Text(subtitle)
                        .themisFont(.secondary)
                        .fontWeight(.semibold)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
                Text(title)
                    .themisFont(.pageTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            trailing
        }
        .padding(.top, 6)
    }
}

extension PageHeader where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil) {
        self.init(title: title, subtitle: subtitle) { EmptyView() }
    }
}

/// `BellButton` · opens the Action Centre (A-001). The count is announced, not just drawn.
struct BellButton: View {
    let count: Int
    let action: () -> Void

    @Environment(\.themisGround) private var ground

    var body: some View {
        Button(action: action) {
            Image(systemName: "bell")
                .symbolRenderingMode(.monochrome)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(ThemisColor.textPrimary)
                .frame(width: ThemisSize.tapMinimum, height: ThemisSize.tapMinimum)
                .background(ground.surface, in: Circle())
                .overlay(alignment: .topTrailing) {
                    if count > 0 {
                        Text(count > 99 ? "99+" : "\(count)")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(ThemisColor.textOnPrimary)
                            .padding(.horizontal, 5)
                            .frame(minWidth: 18, minHeight: 18)
                            .background(ThemisColor.brandPrimary, in: Capsule())
                            .offset(x: -1, y: 1)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Action Centre")
        .accessibilityValue(countDescription)
    }

    private var countDescription: String {
        switch count {
        case 0: return "Nothing needs you"
        case 1: return "1 item needs you"
        default: return "\(count) items need you"
        }
    }
}
