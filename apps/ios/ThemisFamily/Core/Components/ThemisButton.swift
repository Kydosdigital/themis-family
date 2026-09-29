import SwiftUI

/// `ThemisButton` · primary, secondary, tertiary (text) and destructive, with loading and
/// disabled states. Height and radius follow the audience (Parent 52, Teen 50, Child 58).
struct ThemisButton: View {
    enum Style {
        case primary
        case secondary
        case tertiary
        case destructive
        /// Destructive confirmation inside a sheet: error tint fill, no border.
        case destructiveConfirm
    }

    let title: String
    var systemImage: String? = nil
    var style: Style = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    @Environment(\.themisAudience) private var audience
    @Environment(\.themisGround) private var ground

    init(
        title: String,
        systemImage: String? = nil,
        style: Style = .primary,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: ThemisSpacing.inline10) {
                if isLoading {
                    ProgressView()
                        .tint(ThemisColor.textOnPrimary)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .themisFont(style == .tertiary ? .rowTitle : .button)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(
            ThemisButtonStyle(
                style: style,
                state: isLoading ? .loading : (isDisabled ? .disabled : .enabled),
                audience: audience,
                surface: ground.surface
            )
        )
        .disabled(isDisabled || isLoading)
        .accessibilityValue(loadingDescription)
    }

    private var loadingDescription: String {
        isLoading ? "In progress" : ""
    }
}

struct ThemisButtonStyle: ButtonStyle {
    enum Phase {
        case enabled
        case loading
        case disabled
    }

    let style: ThemisButton.Style
    let state: Phase
    let audience: ThemisAudience
    let surface: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: audience.buttonRadius, style: .continuous)
        let pressed = configuration.isPressed

        return configuration.label
            .foregroundStyle(foreground)
            .frame(maxWidth: style == .tertiary ? nil : .infinity)
            .frame(minHeight: style == .tertiary ? ThemisSize.tapMinimum : audience.buttonHeight)
            .padding(.horizontal, style == .tertiary ? 0 : 18)
            .padding(.vertical, style == .tertiary ? 0 : 10)
            .background(background(pressed: pressed), in: shape)
            .overlay {
                if let border {
                    shape.strokeBorder(border, lineWidth: ThemisBorder.control)
                }
            }
            .contentShape(shape)
            .opacity(state == .loading ? 0.88 : 1)
            // Button press: scale 0.98 with a light haptic. Reduce Motion: opacity only.
            .scaleEffect(pressed && !reduceMotion ? 0.98 : 1)
            .opacity(pressed && reduceMotion ? 0.8 : 1)
            .animation(ThemisMotion.animation(.buttonPress, reduceMotion: reduceMotion), value: pressed)
            .sensoryFeedback(.impact(weight: .light), trigger: pressed) { _, isPressed in isPressed }
    }

    private var foreground: Color {
        if state == .disabled { return ThemisColor.textDisabled }
        switch style {
        case .primary: return ThemisColor.textOnPrimary
        case .secondary: return ThemisColor.textPrimary
        case .tertiary: return ThemisColor.brandPrimary
        case .destructive, .destructiveConfirm: return ThemisColor.textDestructive
        }
    }

    private func background(pressed: Bool) -> Color {
        if state == .disabled { return style == .tertiary ? .clear : ThemisColor.controlTrack }
        switch style {
        case .primary: return pressed ? ThemisColor.brandPrimaryPressed : ThemisColor.brandPrimary
        case .secondary, .destructive: return surface
        case .destructiveConfirm: return ThemisColor.statusBgError
        case .tertiary: return .clear
        }
    }

    private var border: Color? {
        guard state != .disabled else { return nil }
        switch style {
        case .secondary: return ThemisColor.borderControl
        case .destructive: return ThemisColor.borderDestructive
        case .primary, .tertiary, .destructiveConfirm: return nil
        }
    }
}

#Preview("Buttons") {
    VStack(spacing: ThemisSpacing.block) {
        ThemisButton(title: "Review") {}
        ThemisButton(title: "Give a Free Pass", style: .secondary) {}
        ThemisButton(title: "Check Apple permission", style: .tertiary) {}
        ThemisButton(title: "Remove this iPhone", style: .destructive) {}
        ThemisButton(title: "Sending", isLoading: true) {}
        ThemisButton(title: "Send request", isDisabled: true) {}
        ThemisButton(title: "I’ve finished my homework") {}
            .themisAudience(.child)
    }
    .padding(ThemisSpacing.screen)
    .themisGround(.plain)
}
