import SwiftUI

/// `ReasonField` · labelled multi-line text input with helper or validation text.
/// Native `TextField(axis: .vertical)`, restyled.
struct ReasonField: View {
    let label: String
    @Binding var text: String
    var prompt: String = ""
    var helper: String? = nil
    var error: String? = nil
    var lineLimit: ClosedRange<Int> = 1...5

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline6) {
            Text(label)
                .themisFont(.meta)
                .fontWeight(.bold)
                .foregroundStyle(ThemisColor.textSecondary)
            TextField(prompt, text: $text, axis: .vertical)
                .themisFont(.body)
                .foregroundStyle(ThemisColor.textPrimary)
                .lineLimit(lineLimit)
                .focused($isFocused)
                .padding(.vertical, 13)
                .padding(.horizontal, 14)
                .frame(minHeight: ThemisSize.inputMinimum, alignment: .topLeading)
                .background(ThemisColor.surface, in: RoundedRectangle(cornerRadius: ThemisRadius.input, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: ThemisRadius.input, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: ThemisBorder.input)
                }
                .accessibilityLabel(label)
                .accessibilityHint(error ?? helper ?? "")
            if let footnote = error ?? helper {
                Text(footnote)
                    .themisFont(.meta)
                    .fontWeight(.semibold)
                    .foregroundStyle(error == nil ? ThemisColor.textSecondary : ThemisColor.textDestructive)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var borderColor: Color {
        if error != nil { return ThemisColor.textDestructive }
        return isFocused ? ThemisColor.brandPrimary : ThemisColor.borderInput
    }
}

/// `ChoiceChips` · single-choice chips such as request durations. 44 pt minimum,
/// selected chip in navy with white text. Selection is also exposed to VoiceOver.
struct ChoiceChips<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option?
    let title: (Option) -> String

    @Environment(\.themisGround) private var ground

    var body: some View {
        FlowLayout(spacing: ThemisSpacing.inline8) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection
                Button {
                    selection = option
                } label: {
                    Text(title(option))
                        .themisFont(.secondary)
                        .fontWeight(.bold)
                        .foregroundStyle(isSelected ? ThemisColor.textOnPrimary : ThemisColor.textPrimary)
                        .padding(.horizontal, 16)
                        .frame(minHeight: ThemisSize.chipMinimum)
                        .background(
                            isSelected ? ThemisColor.brandSecondary : ground.surface,
                            in: RoundedRectangle(cornerRadius: ThemisRadius.sm, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: ThemisRadius.sm, style: .continuous)
                                .strokeBorder(isSelected ? ThemisColor.brandSecondary : ThemisColor.borderControl, lineWidth: ThemisBorder.control)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

/// `SegmentedChoice` · native segmented `Picker`.
struct SegmentedChoice<Option: Hashable>: View {
    let label: String
    let options: [Option]
    @Binding var selection: Option
    let title: (Option) -> String

    var body: some View {
        Picker(label, selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(title(option)).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
}

/// `TimeSelection` · native wheel `DatePicker` for a time of day, on a grouped surface.
struct TimeSelection: View {
    let label: String
    @Binding var time: Date

    @Environment(\.themisAudience) private var audience
    @Environment(\.themisGround) private var ground

    var body: some View {
        DatePicker(label, selection: $time, displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(ground.surface, in: RoundedRectangle(cornerRadius: audience.cardRadius, style: .continuous))
            .accessibilityLabel(label)
    }
}

/// `ChildSelector` · picks one child. Native segmented `Picker` for a small family;
/// the design shows at most a few children, so a list is not needed yet.
struct ChildSelector<ID: Hashable>: View {
    struct Child: Identifiable, Hashable {
        let id: ID
        let name: String
    }

    let children: [Child]
    @Binding var selection: ID

    var body: some View {
        SegmentedChoice(
            label: "Child",
            options: children.map(\.id),
            selection: $selection,
            title: { id in children.first(where: { $0.id == id })?.name ?? "" }
        )
    }
}

/// `StepProgress` · "Step 2 of 5" with a segmented bar. The label carries the meaning.
struct StepProgress: View {
    let current: Int
    let total: Int
    var label: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
            Text(label ?? "Step \(current) of \(total)")
                .themisFont(.meta)
                .fontWeight(.bold)
                .foregroundStyle(ThemisColor.textSecondary)
            HStack(spacing: 4) {
                ForEach(0..<max(total, 0), id: \.self) { index in
                    Capsule()
                        .fill(index < current ? ThemisColor.brandSecondary : ThemisColor.borderControl)
                        .frame(height: 4)
                }
            }
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue("Step \(current) of \(total)")
    }
}

/// Wraps children onto new lines, left aligned. Used by `ChoiceChips`.
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews: subviews, width: proposal.width ?? .infinity)
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(subviews: subviews, width: bounds.width) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func arrange(subviews: Subviews, width: CGFloat) -> [Row] {
        var rows: [Row] = [Row()]
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let proposedWidth = rows[rows.count - 1].indices.isEmpty
                ? size.width
                : rows[rows.count - 1].width + spacing + size.width
            if proposedWidth > width, !rows[rows.count - 1].indices.isEmpty {
                rows.append(Row())
            }
            var row = rows[rows.count - 1]
            row.width = row.indices.isEmpty ? size.width : row.width + spacing + size.width
            row.height = max(row.height, size.height)
            row.indices.append(index)
            rows[rows.count - 1] = row
        }
        return rows.filter { !$0.indices.isEmpty }
    }
}
