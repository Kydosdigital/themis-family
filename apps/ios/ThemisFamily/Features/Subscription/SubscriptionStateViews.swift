import SwiftUI

/// Renders one B-screen from content. Deterministic: used by previews and review.
struct SubscriptionStateView: View {
    let content: SubscriptionContent
    var rules: [RetainedRule] = []
    var primaryAction: () -> Void = {}
    var secondaryAction: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                if let kind = content.statusKind, let label = content.statusLabel {
                    StatusBadge(ThemisStatus(kind, label: label), size: .chip, accessibilityContext: "Subscription status")
                }
                Text(content.title)
                    .themisFont(.pageTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text(content.message)
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let banner = content.banner { bannerView(banner) }

                if !content.points.isEmpty {
                    ThemisCard {
                        VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                            ForEach(content.points, id: \.self) { point in
                                Text(point)
                                    .themisFont(.secondary)
                                    .foregroundStyle(ThemisColor.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .accessibilityElement(children: .combine)
                }

                if content.showsRules {
                    VStack(spacing: ThemisSpacing.inline10) {
                        ForEach(rules) { rule in ruleCard(rule) }
                    }
                }

                if let detail = content.detailLine {
                    Text(detail)
                        .themisFont(.meta)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: ThemisSpacing.inline10) {
                    if let primary = content.primaryAction {
                        ThemisButton(title: primary, style: .primary, action: primaryAction)
                    }
                    if let secondary = content.secondaryAction {
                        ThemisButton(title: secondary, style: .tertiary, action: secondaryAction)
                    }
                }
                .padding(.top, ThemisSpacing.sm)
            }
            .padding(ThemisSpacing.screen)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .themisAudience(.parent)
        .themisGround(.plain)
    }

    @ViewBuilder
    private func bannerView(_ banner: SubscriptionContent.Banner) -> some View {
        switch banner {
        case .success(let text): InlineBanner(.success, text)
        case .info(let text): InlineBanner(.info, text)
        case .warning(let text): InlineBanner(.warning, text)
        }
    }

    private func ruleCard(_ rule: RetainedRule) -> some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: 4) {
                Text(rule.childName)
                    .themisFont(.sectionLabel)
                    .foregroundStyle(ThemisColor.textSecondary)
                Text(rule.title)
                    .themisFont(.rowTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                Text(rule.detail)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                if rule.appsOrScope != rule.title {
                    Text(rule.appsOrScope)
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("B-001 Offer") { SubscriptionStateView(content: SubscriptionContentFactory.offer) }
#Preview("B-002 Active") { SubscriptionView(phase: .active) }
#Preview("B-002 Cancelled") { SubscriptionView(phase: .cancelledPaidThrough) }
#Preview("B-003 Billing grace") { SubscriptionView(phase: .billingGrace) }
#Preview("B-004 Expired") { SubscriptionView(phase: .protectionExpired) }
#Preview("B-005 Resubscribed") { SubscriptionView(phase: .resubscribedAwaitingReview) }
#Preview("B-006 Review rules") { SubscriptionView(phase: .reactivationReady) }
#Preview("B-007 Reactivation sent") { SubscriptionView(phase: .reactivationSent) }
#Preview("B-008 Protection active") { SubscriptionView(phase: .protectionActive) }
#Preview("B-003 AX3") { SubscriptionView(phase: .billingGrace).dynamicTypeSize(.accessibility3) }
#Preview("B-004 AX3") { SubscriptionView(phase: .protectionExpired).dynamicTypeSize(.accessibility3) }
#Preview("B-006 AX3") { SubscriptionView(phase: .reactivationReady).dynamicTypeSize(.accessibility3) }
