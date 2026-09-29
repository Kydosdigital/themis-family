import SwiftUI

/// `EmptyStateView` · calm message when there is nothing to show (A-001 · Empty, T-001 · Empty).
struct EmptyStateView: View {
    let title: String
    var message: String? = nil
    var systemImage: String = "checkmark"
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @ScaledMetric(relativeTo: .title) private var glyph: CGFloat = 56

    var body: some View {
        VStack(spacing: ThemisSpacing.block) {
            Circle()
                .fill(ThemisColor.statusBgSuccess)
                .frame(width: glyph, height: glyph)
                .overlay {
                    Image(systemName: systemImage)
                        .font(.system(size: glyph * 0.4, weight: .heavy))
                        .foregroundStyle(ThemisColor.textPrimary)
                }
                .accessibilityHidden(true)
            Text(title)
                .themisFont(.headline)
                .foregroundStyle(ThemisColor.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            if let message {
                Text(message)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let actionTitle, let action {
                ThemisButton(title: actionTitle, style: .secondary, action: action)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, ThemisSpacing.screen)
    }
}

/// `LoadingStateView` · in-progress state (P-020 · Testing, P-031 · Checking).
/// The label is announced so VoiceOver users know something is happening.
struct LoadingStateView: View {
    let label: String
    var detail: String? = nil

    var body: some View {
        VStack(spacing: ThemisSpacing.block) {
            ProgressView()
                .controlSize(.large)
                .tint(ThemisColor.brandPrimary)
            Text(label)
                .themisFont(.headline)
                .foregroundStyle(ThemisColor.textPrimary)
                .multilineTextAlignment(.center)
            if let detail {
                Text(detail)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, ThemisSpacing.screen)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

/// `ErrorStateView` · something didn't work, with a retry (A-004 · Send failed,
/// P-010 · Interrupted). Honest and calm; never implies protection is in place.
struct ErrorStateView: View {
    let title: String
    var message: String? = nil
    var retryTitle: String = "Try again"
    var retry: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            InlineBanner(.error, title)
            if let message {
                Text(message)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let retry {
                ThemisButton(title: retryTitle, action: retry)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// `CountdownRing` · remaining time for grace, Free Pass and sessions.
/// Countdowns show whole minutes only; session timers may show mm:ss.
/// Reduce Motion: the ring doesn't animate, the text still updates.
struct CountdownRing: View {
    enum Tone {
        case cobalt
        case mint
        case aqua
        case grey

        var color: Color {
            switch self {
            case .cobalt: return ThemisColor.brandPrimary
            case .mint: return ThemisColor.statusSuccess
            case .aqua: return ThemisColor.statusInfo
            case .grey: return ThemisColor.statusOffline
            }
        }
    }

    let value: String
    let caption: String
    /// Remaining fraction, 0…1.
    let fraction: Double
    var tone: Tone = .cobalt

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.themisGround) private var ground
    @ScaledMetric(relativeTo: .largeTitle) private var diameter: CGFloat = 196

    var body: some View {
        let lineWidth = diameter * 0.07
        ZStack {
            Circle()
                .stroke(ThemisColor.controlTrack, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(fraction, 0), 1))
                .stroke(tone.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                .rotationEffect(.degrees(-90))
                .animation(ThemisMotion.animation(.countdownTick, reduceMotion: reduceMotion), value: fraction)
            VStack(spacing: 2) {
                Text(value)
                    .themisFont(.screenTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .monospacedDigit()
                Text(caption)
                    .themisFont(.meta)
                    .fontWeight(.semibold)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(lineWidth * 2)
        }
        .frame(width: diameter, height: diameter)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(value), \(caption)")
    }
}

/// `ThemisSheet` · confirmation content for a native `.sheet` with detents.
/// Present with `.themisConfirmationSheet`. Destructive confirmations use the
/// destructive treatment; Cancel is always available.
struct ThemisConfirmationSheet: View {
    let title: String
    var lines: [String] = []
    let confirmTitle: String
    var isDestructive: Bool = false
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
            Text(title)
                .themisFont(.headline)
                .foregroundStyle(ThemisColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer().frame(height: 4)
            ThemisButton(title: confirmTitle, style: isDestructive ? .destructiveConfirm : .primary, action: onConfirm)
            ThemisButton(title: "Cancel", style: .tertiary, action: onCancel)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 22)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    /// Presents a Themis confirmation in a native sheet that sizes to its content.
    func themisConfirmationSheet(
        isPresented: Binding<Bool>,
        title: String,
        lines: [String] = [],
        confirmTitle: String,
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void
    ) -> some View {
        sheet(isPresented: isPresented) {
            ThemisConfirmationSheet(
                title: title,
                lines: lines,
                confirmTitle: confirmTitle,
                isDestructive: isDestructive,
                onConfirm: {
                    isPresented.wrappedValue = false
                    onConfirm()
                },
                onCancel: { isPresented.wrappedValue = false }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(ThemisRadius.sheet)
        }
    }
}
