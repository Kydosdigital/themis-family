import SwiftUI

/// Grouped section / card surface. No border: the surface contrasts with the ground
/// (white on grey or warm ground, soft grey on white ground). Radius follows the audience.
struct ThemisCard<Content: View>: View {
    var padding: CGFloat
    var isSelected: Bool
    private let content: Content

    @Environment(\.themisAudience) private var audience
    @Environment(\.themisGround) private var ground

    init(
        padding: CGFloat = ThemisSpacing.card,
        isSelected: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.isSelected = isSelected
        self.content = content()
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: audience.cardRadius, style: .continuous)
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ground.surface, in: shape)
            .overlay {
                if isSelected {
                    // `border.selected` · 2 pt inset cobalt.
                    shape.strokeBorder(ThemisColor.brandPrimary, lineWidth: ThemisBorder.selected)
                }
            }
    }
}

/// Grouped rows in one surface with hairline dividers between rows (prototype `group`).
struct ThemisGroupedSection<Data: RandomAccessCollection, RowContent: View>: View where Data.Element: Identifiable {
    var title: String?
    let data: Data
    private let row: (Data.Element) -> RowContent

    @Environment(\.themisAudience) private var audience
    @Environment(\.themisGround) private var ground

    init(_ title: String? = nil, data: Data, @ViewBuilder row: @escaping (Data.Element) -> RowContent) {
        self.title = title
        self.data = data
        self.row = row
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: audience.cardRadius, style: .continuous)
        VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
            if let title, !title.isEmpty {
                SectionHeader(title: title)
                    .padding(.horizontal, 4)
            }
            VStack(spacing: 0) {
                ForEach(data) { element in
                    if element.id != data.first?.id {
                        Rectangle()
                            .fill(ThemisColor.borderHairline)
                            .frame(height: ThemisBorder.hairline)
                            .accessibilityHidden(true)
                    }
                    row(element)
                }
            }
            .background(ground.surface, in: shape)
            .clipShape(shape)
        }
    }
}

/// Standard row inside a grouped section: optional avatar, title, subtitle, trailing
/// status or value, and a disclosure chevron when it navigates.
struct ThemisRow: View {
    let title: String
    var subtitle: String? = nil
    var status: ThemisStatus? = nil
    var value: String? = nil
    var avatar: (initial: String, tone: ThemisTone)? = nil
    var isLink: Bool = false
    var showsChevron: Bool = false

    @Environment(\.themisAudience) private var audience

    var body: some View {
        HStack(spacing: ThemisSpacing.inline12) {
            if let avatar {
                AvatarTile(initial: avatar.initial, tone: avatar.tone)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .themisFont(.rowTitle)
                    .foregroundStyle(isLink ? ThemisColor.brandPrimary : ThemisColor.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .themisFont(.meta)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let status {
                StatusBadge(status)
            }
            if let value {
                Text(value)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .multilineTextAlignment(.trailing)
            }
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ThemisColor.chevron)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, ThemisSpacing.rowVertical)
        .padding(.horizontal, ThemisSpacing.rowHorizontal)
        .frame(minHeight: audience.rowMinHeight)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

/// Initial on a tinted tile (avatars use `radius.sm`).
struct AvatarTile: View {
    let initial: String
    let tone: ThemisTone

    @ScaledMetric(relativeTo: .headline) private var side: CGFloat = ThemisSize.avatar

    var body: some View {
        Text(initial)
            .themisFont(.rowTitle)
            .fontWeight(.heavy)
            .foregroundStyle(ThemisColor.textPrimary)
            .frame(width: side, height: side)
            .background(tone.band, in: RoundedRectangle(cornerRadius: ThemisRadius.sm, style: .continuous))
            .accessibilityHidden(true)
    }
}
