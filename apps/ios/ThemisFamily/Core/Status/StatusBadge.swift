import SwiftUI

/// Tinted glyph circle used by every status component.
struct StatusGlyph: View {
    let kind: StatusKind
    var diameter: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isRotating = false

    var body: some View {
        Circle()
            .fill(kind.tone.fill)
            .frame(width: diameter, height: diameter)
            .overlay {
                Image(systemName: kind.glyphSymbol)
                    .font(.system(size: diameter * 0.46, weight: .heavy))
                    .foregroundStyle(kind.tone.glyphColor)
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
            }
            .accessibilityHidden(true)
            .onAppear { updateRotation() }
            .onChange(of: kind) { _, _ in updateRotation() }
    }

    /// Applying rotates while shown; Reduce Motion keeps it still.
    private func updateRotation() {
        let shouldRotate = kind == .applying && !reduceMotion
        guard shouldRotate != isRotating else { return }
        if shouldRotate {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                isRotating = true
            }
        } else {
            isRotating = false
        }
    }
}

/// `StatusBadge` · glyph + label chip. Never colour-only.
///
/// `.chip` sits on its own line (prototype `chip`); `.compact` sits inside rows and cards.
/// Pass `onSurface: .white` for chips drawn inside a tinted task panel.
struct StatusBadge: View {
    enum Size {
        case chip
        case compact
    }

    let status: ThemisStatus
    var size: Size = .compact
    /// Overrides the tone tint as the chip background (task panel uses white).
    var background: Color? = nil
    /// Context read before the label by VoiceOver, e.g. "Protection status".
    var accessibilityContext: String? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .footnote) private var glyphChip: CGFloat = 22
    @ScaledMetric(relativeTo: .footnote) private var glyphCompact: CGFloat = 21

    init(
        _ status: ThemisStatus,
        size: Size = .compact,
        background: Color? = nil,
        accessibilityContext: String? = nil
    ) {
        self.status = status
        self.size = size
        self.background = background
        self.accessibilityContext = accessibilityContext
    }

    var body: some View {
        HStack(spacing: size == .chip ? 7 : ThemisSpacing.inline6) {
            StatusGlyph(kind: status.kind, diameter: size == .chip ? glyphChip : glyphCompact)
            Text(status.label)
                .themisFont(.caption)
                .foregroundStyle(ThemisColor.textPrimary)
                // Approved accessibility rule: status chips never wrap.
                // Parent Home rows move the whole chip under the text at accessibility sizes
                // so the label can remain intact without squeezing adjacent content.
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.leading, size == .chip ? 4 : 3)
        .padding(.trailing, size == .chip ? 12 : 10)
        .padding(.vertical, size == .chip ? 4 : 3)
        .background(background ?? status.tone.tint, in: Capsule())
        .animation(ThemisMotion.animation(.statusChange, reduceMotion: reduceMotion), value: status)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        if let accessibilityContext {
            return "\(accessibilityContext): \(status.label)"
        }
        return status.label
    }
}

/// `StatusHeader` · large status for the P-030 family: 44 pt glyph, title and explanation.
struct StatusHeader: View {
    let status: ThemisStatus
    let explanation: String
    /// Always shown next to protection status ("Last verified 2 min ago").
    var lastVerified: String? = nil

    @ScaledMetric(relativeTo: .title2) private var glyph: CGFloat = ThemisSize.statusHeaderGlyph

    var body: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
            HStack(spacing: ThemisSpacing.inline12) {
                StatusGlyph(kind: status.kind, diameter: glyph)
                Text(status.label)
                    .themisFont(.screenTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
            }
            Text(explanation)
                .themisFont(.body)
                .foregroundStyle(ThemisColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if let lastVerified {
                Text(lastVerified)
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
        .padding(.bottom, 2)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Status system") {
    ScrollView {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(ThemisStatus.allApproved, id: \.self) { status in
                StatusBadge(status, size: .chip)
            }
            StatusHeader(
                status: .deviceOffline,
                explanation: "Sam’s iPhone hasn’t checked in. Its last-synced protection plan may continue while valid, but new changes can’t reach it and Themis can’t confirm the current state.",
                lastVerified: "Last verified 3 hr ago"
            )
        }
        .padding(ThemisSpacing.screen)
    }
    .themisGround(.plain)
}
