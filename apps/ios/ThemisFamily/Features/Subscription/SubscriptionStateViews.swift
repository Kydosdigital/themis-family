import SwiftUI

/// Per-screen content for UI-12 (B-001…B-008). Each view takes a `SubscriptionPresentation`
/// and renders using only shared `ThemisCard`/`ThemisButton`/`StatusBadge`/`InlineBanner`
/// primitives — no new shared components, no custom payment forms.
///
/// Approved copy lives here as named constants (rather than inline string literals) so
/// `SubscriptionTests.swift` can assert on exact wording without any SwiftUI dependency,
/// and so a regression such as B-004 reverting to "this device" language fails a test
/// immediately instead of only being caught by visual review.
enum SubscriptionCopy {
    static func dateText(_ date: Date) -> String {
        date.formatted(date: .long, time: .omitted)
    }

    // MARK: B-003 · Apple Billing Grace Period

    static let billingGraceStatusLabel = "Billing issue"
    static let billingGraceExplanation = "Apple couldn't take payment."
    static let billingGraceReassurance = "Protection stays on while Apple retries."
    static let billingGraceCallToAction = "Update payment in the App Store."
    static let billingGraceAction = "Update payment in App Store"

    // MARK: B-004 · Protection Expired

    static let protectionExpiredStatusLabel = "Protection has ended"

    /// Approved meaning: the subscription lapsed and Themis cleared restrictions on the
    /// CHILDREN's managed devices — never phrased as if the Parent's own phone (where
    /// this screen is shown) was the restricted device.
    static let protectionExpiredRestrictionsCleared =
        "Your subscription lapsed, so Themis cleared all restrictions on Sam's and Maya's devices."
    static let protectionExpiredRulesSaved = "Your rules are saved."
    static let protectionExpiredPrimaryAction = "Resubscribe"
    /// The Resubscribe action is an Apple-owned, system-owned hand-off — never a fake
    /// in-app App Store sheet, never StoreKit called from this isolated slice.
    static let protectionExpiredResubscribeExplanation = "Opens the App Store subscription sheet."

    // MARK: B-005 · Ready to turn protection back on? / Not now

    static let readyToReactivateStatusLabel = "Subscription active"
    static let readyToReactivateTitle = "Ready to turn protection back on?"
    static let readyToReactivateExplanation = "Nothing is restricted until you confirm."
    static let readyToReactivatePrimaryAction = "Review rules first"
    static let readyToReactivateSecondaryAction = "Not now"
    static let readyToReactivateReviewPrompt =
        "Your previous rules are still saved. Nothing has been re-applied to the device yet — review them first, since things may have changed."

    /// B-005 · Not now: a calm confirmation that deferring changed nothing — payment
    /// stays active, protection stays cleared, rules stay retained.
    static let notNowExplanation =
        "Protection stays off for now. Your rules are still saved, and nothing has been sent to Sam's or Maya's devices. Review them whenever you're ready."

    // MARK: B-006 · Review old rules

    static let reviewRulesTitle = "Review rules"
    static let reviewRulesSupportingCopy = "Edit any rule before turning protection on."
    static let reviewRulesPrimaryAction = "Turn protection back on"

    // MARK: B-006 · Confirm

    static let confirmTitle = "Turn protection back on?"
    static let confirmExplanation =
        "The reviewed, saved rules will be sent to Sam's and Maya's managed devices. Protection isn't active on those devices until they acknowledge the rules were applied."
    static let confirmPrimaryAction = "Turn protection back on"
    static let confirmSecondaryAction = "Cancel"

    // MARK: B-007 · Reactivation sent

    static let reactivationSentStatusLabel = "Reactivation sent"
    /// Deliberately an applying/sending status, never "Protected" or "Protection
    /// active" — the device has not acknowledged yet.
    static let reactivationSentBadgeLabel = "Sending"
    static let reactivationSentExplanation = "Waiting for Sam's and Maya's devices."
    static let reactivationSentDetail =
        "Your rules have been sent. This screen will update once both devices confirm the plan is in effect."

    // MARK: B-008 · Protection active on device

    static let protectionActiveStatusLabel = "Protection active on device"
    static let protectionActiveExplanation =
        "Protection is being enforced normally, the same as before your subscription lapsed."
}

/// B-001 · Trial / subscription offer. Calm, premium, no invented pricing or trial length.
/// Shown before any entitlement exists — deliberately takes no `SubscriptionPresentation`,
/// since there is no lifecycle or protection state to represent yet.
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
/// fully active; there is no reduced-enforcement tier, no countdown, no grace-days-
/// remaining figure, and no child-facing billing language. The two canonical rows
/// visually reinforce: billing problem ≠ reduced protection.
struct SubscriptionBillingGraceView: View {
    var children: [ChildProtectionDuringBilling] = []
    let onUpdatePaymentMethod: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StatusHeader(
                    status: ThemisStatus(.needsAttention, label: SubscriptionCopy.billingGraceStatusLabel),
                    explanation: SubscriptionCopy.billingGraceExplanation
                )

                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        Text(SubscriptionCopy.billingGraceReassurance)
                            .themisFont(.body)
                            .foregroundStyle(ThemisColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(SubscriptionCopy.billingGraceCallToAction)
                            .themisFont(.secondary)
                            .foregroundStyle(ThemisColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if !children.isEmpty {
                    ThemisGroupedSection(data: children) { child in
                        ThemisRow(title: child.title, subtitle: child.lastVerifiedText, status: .protected)
                    }
                }

                ThemisButton(title: SubscriptionCopy.billingGraceAction, action: onUpdatePaymentMethod)
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}

/// B-004 · Protection Expired. Not punitive, not phrased as deletion — rules are
/// retained. The Parent views this on their own phone, so the copy is explicit that it
/// is Sam's and Maya's devices that had restrictions cleared, never "this device". The
/// primary action is an Apple-owned, system-owned hand-off — never a fake in-app App
/// Store sheet, never a call into StoreKit from this isolated slice.
struct SubscriptionProtectionExpiredView: View {
    let onResubscribe: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StatusHeader(
                    status: ThemisStatus(.notActiveYet, label: SubscriptionCopy.protectionExpiredStatusLabel),
                    explanation: SubscriptionCopy.protectionExpiredRestrictionsCleared
                )

                ThemisCard {
                    Text(SubscriptionCopy.protectionExpiredRulesSaved)
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ThemisButton(title: SubscriptionCopy.protectionExpiredPrimaryAction, action: onResubscribe)
                Text(SubscriptionCopy.protectionExpiredResubscribeExplanation)
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}

/// B-005 · Resubscribed — "Ready to turn protection back on?", and its approved
/// secondary result, B-005 · Not now. Payment is active again in both; protection is
/// never automatically reinstated.
struct SubscriptionReadyToReactivateView: View {
    /// `true` renders the B-005 · Not now result instead of the initial B-005 ask.
    var isDeferred: Bool = false
    let onReviewRules: () -> Void
    var onNotNow: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StatusBadge(ThemisStatus(.active, label: SubscriptionCopy.readyToReactivateStatusLabel), size: .chip)

                Text(SubscriptionCopy.readyToReactivateTitle)
                    .themisFont(.pageTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        Text(SubscriptionCopy.readyToReactivateExplanation)
                            .themisFont(.body)
                            .foregroundStyle(ThemisColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(isDeferred ? SubscriptionCopy.notNowExplanation : SubscriptionCopy.readyToReactivateReviewPrompt)
                            .themisFont(.secondary)
                            .foregroundStyle(ThemisColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                ThemisButton(title: SubscriptionCopy.readyToReactivatePrimaryAction, action: onReviewRules)
                if !isDeferred {
                    ThemisButton(title: SubscriptionCopy.readyToReactivateSecondaryAction, style: .tertiary, action: onNotNow)
                }
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}

/// B-006 · Review existing rules. Review only — not the UI-05 rule editor. There are no
/// per-rule activation toggles; a row tap is an inert, feature-local "Edit" callback
/// suitable for later integration, never wired into UI-05 from this isolated slice.
struct SubscriptionReviewRulesView: View {
    let rules: [RetainedRule]
    let onTurnProtectionBackOn: () -> Void
    var onEditRule: (RetainedRule) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                Text(SubscriptionCopy.reviewRulesTitle)
                    .themisFont(.pageTitle)
                    .foregroundStyle(ThemisColor.textPrimary)

                Text(SubscriptionCopy.reviewRulesSupportingCopy)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                ThemisGroupedSection(data: rules) { rule in
                    Button {
                        onEditRule(rule)
                    } label: {
                        ThemisRow(title: "\(rule.childName) · \(rule.title)", subtitle: rule.detail, showsChevron: true)
                    }
                    .buttonStyle(.plain)
                }

                ThemisButton(title: SubscriptionCopy.reviewRulesPrimaryAction, action: onTurnProtectionBackOn)
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}

/// B-006 · Confirm. Sits strictly between B-006 review and B-007 send. Confirming here
/// does not mean protection is active — only that the rules will be sent and the device
/// has not yet acknowledged them.
struct SubscriptionReviewConfirmView: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                Text(SubscriptionCopy.confirmTitle)
                    .themisFont(.pageTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                ThemisCard {
                    Text(SubscriptionCopy.confirmExplanation)
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ThemisButton(title: SubscriptionCopy.confirmPrimaryAction, action: onConfirm)
                ThemisButton(title: SubscriptionCopy.confirmSecondaryAction, style: .tertiary, action: onCancel)
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}

/// B-007 · Reactivation sent. Not the final success state — the device hasn't
/// acknowledged yet, so this never says "Protected" or "Protection active".
struct SubscriptionReactivationSentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StatusHeader(
                    status: ThemisStatus(.applying, label: SubscriptionCopy.reactivationSentStatusLabel),
                    explanation: SubscriptionCopy.reactivationSentExplanation
                )

                StatusBadge(ThemisStatus(.applying, label: SubscriptionCopy.reactivationSentBadgeLabel), size: .chip)

                ThemisCard {
                    Text(SubscriptionCopy.reactivationSentDetail)
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

/// B-008 · Protection active on device. Only reached after every managed device has
/// acknowledged — `reactivationStep == .acknowledgedOnDevice` and `protection ==
/// .enforcing`. Shows per-device acknowledgement evidence, deterministic demo data only.
struct SubscriptionProtectionActiveView: View {
    var acknowledgements: [DeviceProtectionAcknowledgement] = []
    var onDone: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StatusHeader(
                    status: ThemisStatus(.applied, label: SubscriptionCopy.protectionActiveStatusLabel),
                    explanation: SubscriptionCopy.protectionActiveExplanation
                )

                if !acknowledgements.isEmpty {
                    ThemisGroupedSection(data: acknowledgements) { device in
                        ThemisRow(title: device.deviceName, subtitle: device.confirmedAtText, status: .protected)
                    }
                }

                ThemisButton(title: "Done", style: .secondary, action: onDone)
            }
            .padding(ThemisSpacing.screen)
        }
        .accessibilityElement(children: .contain)
    }
}
