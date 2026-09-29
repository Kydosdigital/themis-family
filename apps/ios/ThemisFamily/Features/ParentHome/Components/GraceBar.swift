import SwiftUI

/// `GraceBar` · remaining Provisional Approval Grace Period (DEC-40).
///
/// Label and whole-minute value above a thin track. The fill shows time already
/// used; the navy tick marks the end of grace. At accessibility sizes the value
/// wraps under the label rather than truncating.
struct GraceBar: View {
    let label: String
    let window: ApprovalGraceWindow

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: ThemisSpacing.inline8) {
                    labelText
                    Spacer(minLength: 0)
                    valueText
                }
                VStack(alignment: .leading, spacing: 2) {
                    labelText
                    valueText
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(ThemisColor.brandPrimaryTint)
                        .frame(height: 6)
                    Capsule()
                        .fill(ThemisColor.brandPrimary)
                        .frame(width: proxy.size.width * CGFloat(window.elapsedFraction), height: 6)
                        .animation(ThemisMotion.animation(.countdownTick, reduceMotion: reduceMotion), value: window)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(ThemisColor.brandSecondary)
                        .frame(width: 2, height: 14)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .frame(height: 14)
            }
            .frame(height: 14)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(window.remainingText)")
    }

    private var labelText: some View {
        Text(label)
            .themisFont(.secondary)
            .fontWeight(.semibold)
            .foregroundStyle(ThemisColor.textSecondary)
    }

    private var valueText: some View {
        // Prototype sets the value at 22 pt heavy; the nearest approved role is headline.
        Text(window.remainingText)
            .themisFont(.headline)
            .fontWeight(.heavy)
            .foregroundStyle(ThemisColor.textPrimary)
            .monospacedDigit()
            .fixedSize()
    }
}
