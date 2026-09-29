import SwiftUI

/// `QuickActionDock` · Add rule and Free Pass.
///
/// `.floating`: a white dock with `shadow.dock`, inset above the tab bar with
/// `safeAreaInset`, so scrolling content always ends above it and is never covered.
/// `.inline`: full-width buttons in the page, used at accessibility text sizes and
/// on iPad, where a floating dock would crowd content.
struct QuickActionDock: View {
    enum Placement {
        case floating
        case inline
    }

    let actions: [ParentQuickAction]
    let placement: Placement
    let perform: (ParentQuickAction) -> Void

    @Environment(\.themisAudience) private var audience
    @Environment(\.themisGround) private var ground

    var body: some View {
        switch placement {
        case .floating:
            HStack(spacing: ThemisSpacing.inline8) {
                ForEach(actions) { action in
                    Button { perform(action) } label: {
                        label(for: action)
                            .themisFont(.rowTitle)
                            .foregroundStyle(action.isPrimary ? ThemisColor.textOnPrimary : ThemisColor.textPrimary)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .padding(.horizontal, 8)
                            .background(
                                action.isPrimary ? ThemisColor.brandPrimary : ThemisColor.dockSecondary,
                                in: RoundedRectangle(cornerRadius: ThemisRadius.dockButton, style: .continuous)
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(ThemisSpacing.inline8)
            .background(ThemisColor.surface, in: RoundedRectangle(cornerRadius: audience.panelRadius, style: .continuous))
            .themisShadow(ThemisShadow.dock)
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Quick actions")

        case .inline:
            VStack(spacing: ThemisSpacing.inline8) {
                ForEach(actions) { action in
                    Button { perform(action) } label: {
                        label(for: action)
                            .themisFont(.button)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(action.isPrimary ? ThemisColor.textOnPrimary : ThemisColor.textPrimary)
                            .frame(maxWidth: .infinity, minHeight: audience.buttonHeight)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                action.isPrimary ? ThemisColor.brandPrimary : ground.surface,
                                in: RoundedRectangle(cornerRadius: audience.buttonRadius, style: .continuous)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: audience.buttonRadius, style: .continuous)
                                    .strokeBorder(ThemisColor.borderControl, lineWidth: ThemisBorder.control)
                            }
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 4)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Quick actions")
        }
    }

    @ViewBuilder
    private func label(for action: ParentQuickAction) -> some View {
        if action == .addRule {
            // Prototype label "＋ Add rule"; VoiceOver reads "Add rule".
            Label(action.title, systemImage: "plus")
                .labelStyle(.titleAndIcon)
        } else {
            Text(action.title)
        }
    }
}
