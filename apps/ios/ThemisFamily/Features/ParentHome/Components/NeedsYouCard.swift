import SwiftUI

/// `NeedsYouCard` · the first block on Parent Home.
///
/// The only elevated surface on the screen: white, `border.elevated`, `shadow.elevated`.
/// One primary item with its grace countdown and action, then further items as rows.
struct NeedsYouCard: View {
    let content: NeedsYouContent
    let open: (ParentHomeRoute) -> Void

    @Environment(\.themisAudience) private var audience

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: audience.cardRadius, style: .continuous)

        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            header

            HStack(spacing: ThemisSpacing.inline12) {
                AvatarTile(initial: content.primary.avatar.initial, tone: content.primary.avatar.tone, size: .large)
                Text(content.primary.title)
                    .themisFont(.headline)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .combine)

            if let grace = content.primary.grace {
                GraceBar(label: "Approval grace ends in", window: grace)
            }

            ThemisButton(title: content.primary.actionTitle) {
                open(content.primary.destination)
            }
            .accessibilityHint(content.primary.title)

            ForEach(content.others) { item in
                Button {
                    open(item.destination)
                } label: {
                    NeedsYouItemRow(item: item)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(ThemisSpacing.cardNeedsYou)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemisColor.surface, in: shape)
        .overlay { shape.strokeBorder(ThemisColor.borderElevated, lineWidth: ThemisBorder.hairline) }
        .themisShadow(ThemisShadow.elevated)
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        HStack(spacing: ThemisSpacing.inline8) {
            Text("Needs you")
                .themisFont(.sectionLabel)
                .foregroundStyle(ThemisColor.brandPrimary)
                .lineLimit(1)
                .fixedSize()
            Text("\(content.count)")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(ThemisColor.textOnPrimary)
                .padding(.horizontal, 6)
                .frame(minWidth: 20, minHeight: 20)
                .background(ThemisColor.brandPrimary, in: Capsule())
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(countDescription)
        .accessibilityAddTraits(.isHeader)
    }
}

extension NeedsYouCard {
    fileprivate var countDescription: String {
        content.count == 1 ? "Needs you, 1 item" : "Needs you, \(content.count) items"
    }
}

/// A further Needs You item: avatar, title, detail and status, under a hairline.
private struct NeedsYouItemRow: View {
    let item: NeedsYouItem

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(ThemisColor.borderHairline)
                .frame(height: ThemisBorder.hairline)
                .padding(.bottom, ThemisSpacing.block)

            HStack(alignment: dynamicTypeSize.isAccessibilitySize ? .top : .center, spacing: ThemisSpacing.inline12) {
                AvatarTile(initial: item.avatar.initial, tone: item.avatar.tone)
                let text = VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .themisFont(.rowTitle)
                        .foregroundStyle(ThemisColor.textPrimary)
                    Text(item.detail)
                        .themisFont(.meta)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
                        text
                        StatusBadge(item.status)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    text.frame(maxWidth: .infinity, alignment: .leading)
                    StatusBadge(item.status)
                }
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
