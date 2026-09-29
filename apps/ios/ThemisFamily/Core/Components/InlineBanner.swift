import SwiftUI

/// `InlineBanner` · success, info, warning or error message with a glyph. Never colour-only.
struct InlineBanner: View {
    enum Kind: CaseIterable {
        case success
        case info
        case warning
        case error

        var tone: StatusTone {
            switch self {
            case .success: return .success
            case .info: return .info
            case .warning: return .warning
            case .error: return .error
            }
        }

        var glyphSymbol: String {
            switch self {
            case .success: return "checkmark"
            case .info: return "info"
            case .warning, .error: return "exclamationmark"
            }
        }

        /// Read before the message by VoiceOver so meaning never depends on colour.
        var accessibilityPrefix: String? {
            switch self {
            case .success, .info: return nil
            case .warning: return "Warning"
            case .error: return "Error"
            }
        }
    }

    let kind: Kind
    let message: String

    @ScaledMetric(relativeTo: .subheadline) private var glyph: CGFloat = 22

    init(_ kind: Kind, _ message: String) {
        self.kind = kind
        self.message = message
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: ThemisSpacing.inline10) {
            Circle()
                .fill(kind.tone.fill)
                .frame(width: glyph, height: glyph)
                .overlay {
                    Image(systemName: kind.glyphSymbol)
                        .font(.system(size: glyph * 0.5, weight: .heavy))
                        .foregroundStyle(kind.tone.glyphColor)
                }
                .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 5 }
            Text(message)
                .themisFont(.secondary)
                .fontWeight(.semibold)
                .foregroundStyle(ThemisColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(kind.tone.tint, in: RoundedRectangle(cornerRadius: ThemisRadius.banner, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel([kind.accessibilityPrefix, message].compactMap { $0 }.joined(separator: ": "))
    }
}

/// `ConsequenceNote` · what happens if a task isn't done. Calm, never punitive.
struct ConsequenceNote: View {
    let text: String
    var background: Color? = nil

    @Environment(\.themisGround) private var ground
    @ScaledMetric(relativeTo: .subheadline) private var glyph: CGFloat = 32

    var body: some View {
        HStack(spacing: ThemisSpacing.inline12) {
            Circle()
                .fill(ThemisColor.statusWarning)
                .frame(width: glyph, height: glyph)
                .overlay {
                    Image(systemName: "pause.fill")
                        .font(.system(size: glyph * 0.4, weight: .heavy))
                        .foregroundStyle(ThemisColor.textPrimary)
                }
                .accessibilityHidden(true)
            Text(text)
                .themisFont(.secondary)
                .fontWeight(.semibold)
                .foregroundStyle(ThemisColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(background ?? ground.surface, in: RoundedRectangle(cornerRadius: ThemisRadius.inner, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
