import SwiftUI

/// Per-screen content for UI-12 (B-001…B-008). Each view takes a `SubscriptionPresentation`
/// and renders using only shared `ThemisCard`/`ThemisButton`/`StatusBadge`/`InlineBanner`
/// primitives — no new shared components, no custom payment forms.
enum SubscriptionCopy {
    static func dateText(_ date: Date) -> String {
        date.formatted(date: .long, time: .omitted)
    }
}

/// B-001 · Trial / subscription offer. Calm, premium, no invented pricing or trial length.
struct SubscriptionOfferView: View {
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                Text("Themis Family")
                    .themisFont(.display)
                    .foregroundStyle(ThemisColor.textPrimary)

                Text("Clear family rules, calmly enforced. Set the boundaries once, and let the phone handle the rest — without the daily arguments.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                ThemisCard {
                    ChecklistList(items: [
                        .init(.yes, "Clear, parent-set family rules"),
                        .init(.yes, "Parent-controlled exceptions, like a Free Pass"),
                        .init(.yes, "Protection-status visibility, always honest about what's applied"),
                        .init(.yes, "A respectful Child and Teen experience")
                    ])
                }

                InlineBanner(.info, "Subscription details will be shown here once confirmed.")

                Spacer(minLength: ThemisSpacing.block)

                ThemisButton(title: "Continue", action: onContinue)
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}

/// B-002 · Manage subscription. App Store ownership is explicit; Themis never implies
/// it processes payment directly.
struct SubscriptionManageView: View {
    let presentation: SubscriptionPresentation
    let onManageInAppStore: () -> Void

    private var isCancelled: Bool { presentation.lifecycle == .cancelledPaidThrough }

    private var status: ThemisStatus {
        isCancelled ? .cancelled : .subscriptionActive
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StatusHeader(
                    status: status,
                    explanation: isCancelled
                        ? "Protection stays active until \(paidThroughText)."
                        : "Themis Family protection is fully active."
                )

                ThemisCard {
                    KeyValueList(items: [
                        .init("Plan", "Themis Family"),
                        .init("Managed by", "App Store"),
                        .init("Status", status.label)
                    ])
                }

                InlineBanner(.info, "Your subscription is managed through the App Store.")

                ThemisButton(title: "Manage in App Store", style: .secondary, action: onManageInAppStore)
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }

    private var paidThroughText: String {
        presentation.paidThroughDate.map(SubscriptionCopy.dateText) ?? "the end of the paid period"
    }
}

/// B-003 · Apple Billing Grace Period. Calm, Parent-facing only. Protection remains
/// fully active; there is no reduced-enforcement tier.
struct SubscriptionBillingGraceView: View {
    let onUpdatePaymentMethod: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StatusHeader(
                    status: ThemisStatus(.needsAttention, label: "Billing issue"),
                    explanation: "Your payment didn't go through."
                )

                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        Text("Protection is still active while Apple retries payment.")
                            .themisFont(.body)
                            .foregroundStyle(ThemisColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Update your payment method to keep protection active.")
                            .themisFont(.secondary)
                            .foregroundStyle(ThemisColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                ThemisButton(title: "Update payment method", action: onUpdatePaymentMethod)
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}

/// B-004 · Protection Expired. Not punitive, not phrased as deletion — rules are retained.
struct SubscriptionProtectionExpiredView: View {
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StatusHeader(
                    status: .protectionEnded,
                    explanation: "Themis Protection is no longer active."
                )

                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        Text("Themis-managed restrictions have been cleared on this device.")
                            .themisFont(.body)
                            .foregroundStyle(ThemisColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Your existing rules are saved and ready for whenever you're ready to turn protection back on.")
                            .themisFont(.secondary)
                            .foregroundStyle(ThemisColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                ThemisButton(title: "Continue", style: .secondary, action: onContinue)
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}

/// B-005 · Resubscribed — "Ready to turn protection back on?" Payment active again;
/// protection is not automatically reinstated.
struct SubscriptionReadyToReactivateView: View {
    let onReviewRules: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                Text("Ready to turn protection back on?")
                    .themisFont(.pageTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        Text("Your subscription is active again.")
                            .themisFont(.body)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text("Your previous rules are still saved. Nothing has been re-applied to the device yet — review them first, since things may have changed.")
                            .themisFont(.secondary)
                            .foregroundStyle(ThemisColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                ThemisButton(title: "Review rules", action: onReviewRules)
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}

/// B-006 · Review existing rules. Review only — not the UI-05 rule editor.
struct SubscriptionReviewRulesView: View {
    let rules: [RetainedRule]
    let onTurnProtectionBackOn: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                Text("Review your rules")
                    .themisFont(.pageTitle)
                    .foregroundStyle(ThemisColor.textPrimary)

                Text("These are the rules Themis last had saved. Make sure they still make sense before protection turns back on.")
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                ThemisGroupedSection(data: rules) { rule in
                    ThemisRow(title: rule.title, subtitle: "\(rule.childName) · \(rule.detail)")
                }

                ThemisButton(title: "Turn protection back on", action: onTurnProtectionBackOn)
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}

/// B-007 · Reactivation sent. Not the final success state — the device hasn't
/// acknowledged yet, so this never says "Protection active".
struct SubscriptionReactivationSentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StatusHeader(
                    status: ThemisStatus(.applying, label: "Reactivation sent"),
                    explanation: "Themis is waiting for the child's device to confirm."
                )

                ThemisCard {
                    Text("Your rules have been sent to the device. This screen will update once the device confirms protection is applied.")
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}

/// B-008 · Protection active on device. Only reached after device acknowledgement.
struct SubscriptionProtectionActiveView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StatusHeader(
                    status: ThemisStatus(.applied, label: "Protection active on device"),
                    explanation: "The device has confirmed your rules are applied again."
                )

                ThemisCard {
                    Text("Protection is being enforced normally, the same as before your subscription lapsed.")
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}
