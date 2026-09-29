import SwiftUI

/// Action card in the Needs You position for P-023 · Setup incomplete
/// (`SetupIncompleteCard`) and P-023 · Protection problem.
///
/// Avatar, title, message and status chip, then one primary action.
/// A plain surface, not elevated: only the Needs You card carries a shadow.
struct HomeActionCard: View {
    let content: HomeActionCardContent
    let open: (ParentHomeRoute) -> Void

    var body: some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                HStack(alignment: .top, spacing: ThemisSpacing.inline12) {
                    AvatarTile(initial: content.avatar.initial, tone: content.avatar.tone, size: .large)
                    VStack(alignment: .leading, spacing: 4) {
                        // Prototype: 17 pt bold. `button` is the approved role with those metrics.
                        Text(content.title)
                            .themisFont(.button)
                            .foregroundStyle(ThemisColor.textPrimary)
                            .accessibilityAddTraits(.isHeader)
                        Text(content.message)
                            .themisFont(.secondary)
                            .foregroundStyle(ThemisColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        StatusBadge(content.status)
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .combine)

                ThemisButton(title: content.actionTitle) {
                    open(content.destination)
                }
            }
        }
    }
}

typealias SetupIncompleteCard = HomeActionCard
