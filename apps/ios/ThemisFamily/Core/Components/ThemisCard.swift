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
///
/// At accessibility text sizes the status or value moves under the subtitle, so a
/// long status such as "Protection unavailable" is never squeezed or clipped.
struct ThemisRow: View {
    let title: String
    var subtitle: String? = nil
    var status: ThemisStatus? = nil
    var value: String? = nil
    var avatar: (initial: String, tone: ThemisTone)? = nil
    var isLink: Bool = false
    var showsChevron: Bool = false

    @Environment(\.themisAudience) private var audience
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let stacked = dynamicTypeSize.isAccessibilitySize
        HStack(alignment: stacked ? .top : .center, spacing: ThemisSpacing.inline12) {
            if let avatar {
                AvatarTile(initial: avatar.initial, tone: avatar.tone)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .themisFont(.rowTitle)
                    .foregroundStyle(isLink ? ThemisColor.brandPrimary : ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle {
                    Text(subtitle)
                        .themisFont(.meta)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if stacked {
                    trailing(stacked: true)
                        .padding(.top, 6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if !stacked {
                trailing(stacked: false)
            }
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(ThemisColor.chevron)
                    .accessibilityHidden(true)
                    .padding(.top, stacked ? 4 : 0)
            }
        }
        .padding(.vertical, ThemisSpacing.rowVertical)
        .padding(.horizontal, ThemisSpacing.rowHorizontal)
        .frame(minHeight: audience.rowMinHeight)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func trailing(stacked: Bool) -> some View {
        if let status {
            StatusBadge(status)
        }
        if let value {
            Text(value)
                .themisFont(.secondary)
                .foregroundStyle(ThemisColor.textSecondary)
                .multilineTextAlignment(stacked ? .leading : .trailing)
        }
    }
}

/// Initial on a tinted tile (avatars use `radius.sm`). `.regular` 38 pt in rows,
/// `.large` 40 pt at the head of a card.
struct AvatarTile: View {
    enum Size {
        case regular
        case large
    }

    let initial: String
    let tone: ThemisTone
    @ScaledMetric private var side: CGFloat

    init(initial: String, tone: ThemisTone, size: Size = .regular) {
        self.initial = initial
        self.tone = tone
        _side = ScaledMetric(
            wrappedValue: size == .large ? ThemisSize.avatarLarge : ThemisSize.avatar,
            relativeTo: .headline
        )
    }

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
