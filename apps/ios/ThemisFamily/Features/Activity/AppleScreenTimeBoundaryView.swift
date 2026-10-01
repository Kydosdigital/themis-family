import SwiftUI

/// T-006 Apple Screen Time.
///
/// A presentation boundary only. Apple's `DeviceActivityReport` runs in Apple's sandbox,
/// and whether it renders on the parent's iPhone is the Priority 8 real-device spike.
/// This view therefore draws NO usage figures, bars, apps, websites or categories, and it
/// imports no Family Controls or DeviceActivity framework.
struct AppleScreenTimeBoundaryView: View {
    let state: AppleScreenTimeReportState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                SectionHeader(title: AppleScreenTimeCopy.sectionLabel)

                switch state {
                case .systemOwnedReportArea:
                    AppleOwnedReportArea()
                case .unavailable:
                    InlineBanner(.info, AppleScreenTimeCopy.unavailableMessage)
                    Text(AppleScreenTimeCopy.unavailableSupport)
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(AppleScreenTimeCopy.privacy)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(AppleScreenTimeCopy.separation)
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.top, ThemisSpacing.inline8)
            .padding(.bottom, ThemisSpacing.lg)
        }
        .themisAudience(.parent)
        .themisGround(.plain)
        .navigationTitle(AppleScreenTimeCopy.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// The bounded, hatched, dashed-outline area that stands for Apple's own report. Nothing
/// of Themis's goes inside it, which keeps the two data categories visibly apart.
struct AppleOwnedReportArea: View {
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: ThemisRadius.inner, style: .continuous)

        VStack(spacing: ThemisSpacing.inline8) {
            Text(AppleScreenTimeCopy.areaLabel.uppercased())
                .font(.system(.caption2, design: .monospaced).weight(.bold))
                .tracking(0.9)
                .foregroundStyle(ThemisColor.textDisabled)
                .multilineTextAlignment(.center)
            Text(AppleScreenTimeCopy.areaTitle)
                .themisFont(.rowTitle)
                .foregroundStyle(ThemisColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(AppleScreenTimeCopy.reportExpectation)
                .themisFont(.secondary)
                .foregroundStyle(ThemisColor.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(AppleScreenTimeCopy.areaDetail)
                .themisFont(.meta)
                .foregroundStyle(ThemisColor.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(ThemisSpacing.cardTask)
        .frame(maxWidth: .infinity, minHeight: 200)
        // The nearer background is drawn in front: hatch over the white base.
        .background(HatchBackground().clipShape(shape))
        .background(ThemisColor.surface, in: shape)
        .overlay {
            shape.stroke(
                ThemisColor.textTertiary,
                style: StrokeStyle(lineWidth: ThemisBorder.conditional, dash: [6, 5])
            )
        }
        .accessibilityElement(children: .combine)
    }
}

/// Diagonal hatch marking a system-owned area.
private struct HatchBackground: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            let step: CGFloat = 14
            var x = -size.height
            while x < size.width {
                path.move(to: CGPoint(x: x, y: size.height))
                path.addLine(to: CGPoint(x: x + size.height, y: 0))
                x += step
            }
            context.stroke(path, with: .color(ThemisColor.borderHairline), lineWidth: 6)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Previews (deterministic)

#Preview("T-006 · Apple-owned report boundary") {
    NavigationStack {
        AppleScreenTimeBoundaryView(state: .systemOwnedReportArea)
    }
}

#Preview("T-006 · Unavailable") {
    NavigationStack {
        AppleScreenTimeBoundaryView(state: .unavailable)
    }
}

#Preview("T-006 · Unavailable · AX3") {
    NavigationStack {
        AppleScreenTimeBoundaryView(state: .unavailable)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}
