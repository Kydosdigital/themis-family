import SwiftUI

/// `KeyValueList` · label/value rows in one surface. At accessibility sizes each row
/// stacks (label above value, left aligned) so times never wrap as "5:55 / PM".
struct KeyValueList: View {
    struct Item: Identifiable, Hashable {
        let key: String
        let value: String
        var id: String { key }

        init(_ key: String, _ value: String) {
            self.key = key
            self.value = value
        }
    }

    let items: [Item]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.themisAudience) private var audience
    @Environment(\.themisGround) private var ground

    var body: some View {
        let stacked = dynamicTypeSize.isAccessibilitySize
        VStack(spacing: 0) {
            ForEach(items) { item in
                if item.id != items.first?.id {
                    Rectangle().fill(ThemisColor.borderHairline).frame(height: ThemisBorder.hairline)
                }
                row(item, stacked: stacked)
            }
        }
        .background(ground.surface, in: RoundedRectangle(cornerRadius: audience.cardRadius, style: .continuous))
    }

    @ViewBuilder
    private func row(_ item: Item, stacked: Bool) -> some View {
        let layout = stacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 2))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 14))
        layout {
            Text(item.key)
                .themisFont(.secondary)
                .fontWeight(.semibold)
                .foregroundStyle(ThemisColor.textSecondary)
                .frame(maxWidth: stacked ? .infinity : nil, alignment: .leading)
            if !stacked { Spacer(minLength: 0) }
            Text(item.value)
                .themisFont(.secondary)
                .fontWeight(.bold)
                .foregroundStyle(ThemisColor.textPrimary)
                .multilineTextAlignment(stacked ? .leading : .trailing)
                .frame(maxWidth: stacked ? .infinity : nil, alignment: stacked ? .leading : .trailing)
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
    }
}

/// `ChecklistList` · short statements with a glyph, e.g. what Themis does and doesn't do.
struct ChecklistList: View {
    enum Mark {
        /// ✓ something that is true or included.
        case yes
        /// ✕ something Themis does not do.
        case no
        /// • neutral fact.
        case note

        var symbol: String {
            switch self {
            case .yes: return "checkmark"
            case .no: return "xmark"
            case .note: return "circle.fill"
            }
        }

        var fill: Color {
            switch self {
            case .yes: return ThemisColor.statusSuccessSoft
            case .no: return ThemisColor.statusNeutral
            case .note: return ThemisColor.brandPrimaryTint
            }
        }
    }

    struct Item: Identifiable, Hashable {
        let id = UUID()
        let mark: Mark
        let text: String

        init(_ mark: Mark, _ text: String) {
            self.mark = mark
            self.text = text
        }
    }

    let items: [Item]

    @ScaledMetric(relativeTo: .body) private var glyph: CGFloat = 28

    var body: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
            ForEach(items) { item in
                HStack(alignment: .top, spacing: ThemisSpacing.inline12) {
                    Circle()
                        .fill(item.mark.fill)
                        .frame(width: glyph, height: glyph)
                        .overlay {
                            Image(systemName: item.mark.symbol)
                                .font(.system(size: glyph * (item.mark == .note ? 0.25 : 0.45), weight: .heavy))
                                .foregroundStyle(ThemisColor.textPrimary)
                        }
                        .accessibilityHidden(true)
                    Text(item.text)
                        .themisFont(.body)
                        .foregroundStyle(ThemisColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 1)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

