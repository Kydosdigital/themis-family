import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    private let onComplete: () -> Void

    init(
        initialStep: OnboardingStep = .launch,
        pairingVariant: PairingPresentationVariant = .code,
        testResult: ProtectionTestPresentationResult = .success,
        onComplete: @escaping () -> Void = {}
    ) {
        let model = OnboardingViewModel(initialStep: initialStep)
        model.pairingVariant = pairingVariant
        model.testResult = testResult
        _viewModel = StateObject(wrappedValue: model)
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.step == .launch {
                    launchScreen
                } else {
                    onboardingScreen
                }
            }
            .toolbar {
                if viewModel.canGoBack {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            viewModel.retreat()
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                        .accessibilityLabel("Back")
                    }
                }
            }
            .toolbar(viewModel.step == .launch ? .hidden : .visible, for: .navigationBar)
        }
        .themisAudience(.parent)
        .themisGround(.plain)
    }

    private var launchScreen: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            Spacer()
            Image(systemName: "greaterthan")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(ThemisColor.brandPrimary)
                .accessibilityHidden(true)
            Text("Themis Family")
                .themisFont(.display)
                .foregroundStyle(ThemisColor.textPrimary)
            Text("Family rules that stay clear, calm and visible.")
                .themisFont(.body)
                .foregroundStyle(ThemisColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            ThemisButton(title: "Continue") {
                viewModel.advance()
            }
        }
        .padding(ThemisSpacing.screen)
        .themisGround(.plain)
        .accessibilityElement(children: .contain)
    }

    private var onboardingScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                StepProgress(current: viewModel.phase, total: 5, label: viewModel.phaseLabel)

                VStack(alignment: .leading, spacing: ThemisSpacing.inline10) {
                    Text(title)
                        .themisFont(.pageTitle)
                        .foregroundStyle(ThemisColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let message {
                        Text(message)
                            .themisFont(.body)
                            .foregroundStyle(ThemisColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                stepContent
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.bottom, 32)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            actionBar
        }
        .themisGround(.plain)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case .launch:
            EmptyView()

        case .welcome:
            ThemisCard {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    featureRow("Set rules together", systemImage: "checklist")
                    featureRow("Keep important access in mind", systemImage: "graduationcap")
                    featureRow("See whether protection is current", systemImage: "checkmark.circle")
                }
            }

        case .signInWithApple:
            ThemisCard {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(ThemisColor.textPrimary)
                        .accessibilityHidden(true)
                    Text("Use your Apple account to create the Owner account for this household.")
                        .themisFont(.body)
                        .foregroundStyle(ThemisColor.textPrimary)
                }
            }

        case .accountCreated:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.success, "Account creation complete")
                InlineBanner(.info, OnboardingDemoData.accountCreatedMessage)
            }

        case .goal:
            ChoiceChips(
                options: OnboardingGoal.allCases,
                selection: $viewModel.goal,
                title: { $0.rawValue }
            )

        case .addChild:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                Text("First name")
                    .themisFont(.meta)
                    .fontWeight(.bold)
                    .foregroundStyle(ThemisColor.textSecondary)
                TextField("Sam", text: $viewModel.childName)
                    .textContentType(.givenName)
                    .themisFont(.body)
                    .padding(.horizontal, 14)
                    .frame(minHeight: ThemisSize.inputMinimum)
                    .background(ThemisColor.surface, in: RoundedRectangle(cornerRadius: ThemisRadius.input, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: ThemisRadius.input, style: .continuous)
                            .strokeBorder(ThemisColor.borderInput, lineWidth: ThemisBorder.input)
                    }
                Text("No date of birth is needed to choose the experience.")
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
            }

        case .chooseExperience:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                SegmentedChoice(
                    label: "Experience",
                    options: OnboardingExperience.allCases,
                    selection: $viewModel.experience,
                    title: { $0.rawValue }
                )
                ThemisCard {
                    Text(experienceExplanation)
                        .themisFont(.body)
                        .foregroundStyle(ThemisColor.textPrimary)
                }
            }

        case .childCreated:
            InlineBanner(.success, "\(safeChildName)'s \(viewModel.experience.rawValue) experience is ready")

        case .pairDeviceIntro:
            ThemisCard {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    featureRow("Pair one device to \(safeChildName)", systemImage: "iphone")
                    featureRow("The pairing code is one-time", systemImage: "number")
                    featureRow("Family Controls permission happens separately on the managed device", systemImage: "hand.raised")
                }
            }

        case .pairing:
            pairingContent

        case .familyControlsExplanation:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(ThemisColor.brandPrimary)
                            .accessibilityHidden(true)
                        Text("Family Controls is Apple's permission for family-management features on \(safeChildName)'s managed device.")
                            .themisFont(.body)
                            .foregroundStyle(ThemisColor.textPrimary)
                    }
                }
                InlineBanner(.info, "This Apple permission is separate from signing in to Themis.")
            }

        case .appleAuthorisationHandoff:
            systemOwnedCard(
                title: "Provided by Apple",
                detail: OnboardingDemoData.systemOwnedAppleAuthorisationMessage,
                symbol: "apple.logo"
            )

        case .starterRule:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                selectableCard(title: "Homework deadline", detail: "Pause selected distractions when homework reaches its deadline.", selected: true)
                selectableCard(title: "Bedtime", detail: "A scheduled evening pause.", selected: false)
                selectableCard(title: "Earn First", detail: "Complete something first, then unlock access.", selected: false)
            }

        case .homeworkDeadlineStarter:
            ThemisCard(isSelected: true) {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    Text("Homework deadline")
                        .themisFont(.headline)
                        .foregroundStyle(ThemisColor.textPrimary)
                    Text("Due at 6:00 PM. Parent Approval confirms completion. Roblox and Minecraft are the canonical controlled apps.")
                        .themisFont(.body)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

        case .controlledApps:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                systemOwnedCard(
                    title: "Apple app and website picker",
                    detail: OnboardingDemoData.systemOwnedPickerMessage,
                    symbol: "square.grid.2x2"
                )
                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline6) {
                        Text("Current selection")
                            .themisFont(.meta)
                            .fontWeight(.bold)
                            .foregroundStyle(ThemisColor.textSecondary)
                        Text("Roblox · Minecraft")
                            .themisFont(.headline)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text("2 apps selected")
                            .themisFont(.meta)
                            .foregroundStyle(ThemisColor.textSecondary)
                    }
                }
            }

        case .deadline:
            TimeSelection(label: "Homework deadline", time: $viewModel.deadline)

        case .verification:
            ThemisCard(isSelected: true) {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline10) {
                    HStack {
                        Text("Parent Approval")
                            .themisFont(.headline)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(ThemisColor.brandPrimary)
                            .accessibilityLabel("Selected")
                    }
                    Text("Recommended for homework. \(safeChildName) submits completion and a parent or carer confirms it.")
                        .themisFont(.body)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

        case .essentialAccess:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.success, "School access is kept in the family agreement")
                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        factRow("School apps and sites can be kept Always Allowed.")
                        factRow("Phone, Messages and Maps can be configured to stay available where supported.")
                        factRow(OnboardingDemoData.emergencyAccessMessage)
                    }
                }
            }

        case .agreementReview:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        Text("\(safeChildName)'s first agreement")
                            .themisFont(.headline)
                            .foregroundStyle(ThemisColor.textPrimary)
                        ForEach(OnboardingDemoData.agreementFacts, id: \.self) { fact in
                            factRow(fact)
                        }
                    }
                }
                InlineBanner(.info, "Protection is still not active. The test comes next.")
            }

        case .protectionTest:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        factRow("Apply a temporary test restriction.")
                        factRow("Remove the test restriction.")
                        factRow("Verify the resulting device state.")
                    }
                }
                InlineBanner(.info, "UI-04 uses deterministic mock results until production Apple enforcement is proven and wired.")
            }

        case .protectionTestResult:
            protectionTestResultContent

        case .activated:
            if viewModel.activationReadiness.canActivateProtection {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    InlineBanner(.success, "Themis Protection Activated")
                    ThemisCard {
                        VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                            factRow("\(safeChildName)'s managed device is authorised.")
                            factRow("The Homework rule has a controlled target.")
                            factRow("The protection test applied, removed and verified successfully.")
                        }
                    }
                }
            } else {
                InlineBanner(.warning, "Protection is not active yet. Finish the required test and permission steps first.")
            }
        }
    }

    @ViewBuilder
    private var pairingContent: some View {
        switch viewModel.pairingVariant {
        case .code:
            ThemisCard {
                VStack(spacing: ThemisSpacing.block) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 112, weight: .regular))
                        .foregroundStyle(ThemisColor.textPrimary)
                        .accessibilityHidden(true)
                    Text("472 918")
                        .themisFont(.numeral)
                        .foregroundStyle(ThemisColor.textPrimary)
                        .accessibilityLabel("Pairing code 4 7 2 9 1 8")
                    Text("Use this one-time code on \(safeChildName)'s device.")
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }

        case .alreadyPaired:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.success, "This device is already paired to \(safeChildName)")
                Text("Continue with the existing household binding. Themis never silently pairs one device to two households.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
            }

        case .recoveryRequired:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.warning, "Recovery is required before this device can be paired")
                Text("The device already has a household binding that cannot be silently replaced. Use the authorised recovery path.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var protectionTestResultContent: some View {
        switch viewModel.testResult {
        case .success:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.success, "Protection test succeeded")
                Text("The test restriction was applied, removed and the resulting state was verified.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
            }
        case .retry:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.warning, "The test could not be verified")
                Text("Protection remains not active. Try the test again before continuing.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
            }
        case .permissionRequired:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.warning, "Apple permission needs attention")
                Text("Protection remains not active. Review Family Controls permission on the managed device.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
            }
        }
    }

    private var actionBar: some View {
        VStack(spacing: ThemisSpacing.inline8) {
            ThemisButton(
                title: primaryActionTitle,
                systemImage: viewModel.step == .signInWithApple ? "apple.logo" : nil,
                isDisabled: primaryActionDisabled,
                action: primaryAction
            )
            if let secondaryActionTitle {
                ThemisButton(title: secondaryActionTitle, style: .tertiary, action: secondaryAction)
            }
        }
        .padding(.horizontal, ThemisSpacing.screen)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    private var primaryActionTitle: String {
        switch viewModel.step {
        case .welcome: return "Get started"
        case .signInWithApple: return "Continue with Apple"
        case .accountCreated: return "Set up protection"
        case .goal, .addChild, .chooseExperience, .familyControlsExplanation,
             .appleAuthorisationHandoff, .homeworkDeadlineStarter, .deadline,
             .verification, .essentialAccess:
            return "Continue"
        case .childCreated: return "Pair \(safeChildName)'s device"
        case .pairDeviceIntro: return "Show pairing code"
        case .pairing:
            switch viewModel.pairingVariant {
            case .code: return "I've paired this device"
            case .alreadyPaired: return "Continue"
            case .recoveryRequired: return "Continue to recovery"
            }
        case .starterRule: return "Use Homework"
        case .controlledApps: return "Use this selection"
        case .agreementReview: return "Test protection"
        case .protectionTest: return "Run protection test"
        case .protectionTestResult:
            switch viewModel.testResult {
            case .success: return "Continue"
            case .retry: return "Try again"
            case .permissionRequired: return "Review Apple permission"
            }
        case .activated: return "Go to family home"
        case .launch: return "Continue"
        }
    }

    private var secondaryActionTitle: String? {
        switch viewModel.step {
        case .goal: return "I'll choose later"
        default: return nil
        }
    }

    private var primaryActionDisabled: Bool {
        switch viewModel.step {
        case .addChild:
            return viewModel.childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .activated:
            return !viewModel.activationReadiness.canActivateProtection
        default:
            return false
        }
    }

    private func primaryAction() {
        switch viewModel.step {
        case .protectionTestResult:
            switch viewModel.testResult {
            case .success:
                viewModel.advance()
            case .retry:
                viewModel.retryProtectionTest()
            case .permissionRequired:
                viewModel.go(to: "P-011")
            }
        case .activated:
            onComplete()
        default:
            viewModel.advance()
        }
    }

    private func secondaryAction() {
        if viewModel.step == .goal {
            viewModel.advance()
        }
    }

    private var title: String {
        switch viewModel.step {
        case .launch: return "Themis Family"
        case .welcome: return "Family rules, made clearer"
        case .signInWithApple: return "Create your Owner account"
        case .accountCreated: return "Your account is ready"
        case .goal: return "What are you struggling with?"
        case .addChild: return "Add your child"
        case .chooseExperience: return "Choose the experience"
        case .childCreated: return "\(safeChildName) is ready"
        case .pairDeviceIntro: return "Pair \(safeChildName)'s device"
        case .pairing: return pairingTitle
        case .familyControlsExplanation: return "Why Themis needs Apple permission"
        case .appleAuthorisationHandoff: return "Continue with Family Controls"
        case .starterRule: return "Choose your first rule"
        case .homeworkDeadlineStarter: return "Start with Homework"
        case .controlledApps: return "Choose what pauses"
        case .deadline: return "When is homework due?"
        case .verification: return "How is homework confirmed?"
        case .essentialAccess: return "Keep important access available"
        case .agreementReview: return "Review your family agreement"
        case .protectionTest: return "Test protection before activation"
        case .protectionTestResult: return "Protection test"
        case .activated: return "Themis Protection Activated"
        }
    }

    private var message: String? {
        switch viewModel.step {
        case .welcome:
            return "Set up one clear agreement, pair \(safeChildName)'s device, then test protection before anything is described as active."
        case .signInWithApple:
            return "Owner and Guardian identity is separate from Family Controls permission on a child's device."
        case .accountCreated:
            return "The household exists, but no child is protected yet."
        case .goal:
            return "Choose the area you'd most like help with first."
        case .addChild:
            return "Use a first name only. Choose Child or Teen on the next screen."
        case .chooseExperience:
            return "Pick the experience that best fits \(safeChildName). You can change this later."
        case .childCreated:
            return "Next, connect the device Themis will manage for \(safeChildName)."
        case .pairDeviceIntro:
            return "Pairing identifies the managed device. Apple Family Controls authorisation is a separate step."
        case .pairing:
            return pairingMessage
        case .familyControlsExplanation:
            return "Themis uses Apple's family-management frameworks to apply the rules you choose. Apple owns the permission screen."
        case .appleAuthorisationHandoff:
            return "The next permission interaction is system-provided. Themis does not imitate Apple's authorisation UI."
        case .starterRule:
            return "Use an approved starter and adjust its details before activation."
        case .homeworkDeadlineStarter:
            return "The canonical first rule keeps homework simple and parent-confirmed."
        case .controlledApps:
            return "Selection belongs to Apple's system picker. This review state shows the canonical result."
        case .deadline:
            return "The canonical agreement uses 6:00 PM."
        case .verification:
            return "Generic homework uses Parent Approval. Automatic Verification is not offered as an ordinary homework alternative."
        case .essentialAccess:
            return "Always Allowed and school access are parent-configured. Apple-dependent availability is described conservatively."
        case .agreementReview:
            return "Check the rule with \(safeChildName) before testing protection."
        case .protectionTest:
            return "Activation waits until a real protection test can apply a restriction, remove it and verify the resulting state."
        case .protectionTestResult:
            return nil
        case .activated:
            return "The activation state is only reachable after every required setup and test condition is satisfied."
        case .launch:
            return nil
        }
    }

    private var pairingTitle: String {
        switch viewModel.pairingVariant {
        case .code: return "Pair with this one-time code"
        case .alreadyPaired: return "Device already paired"
        case .recoveryRequired: return "Pairing needs recovery"
        }
    }

    private var pairingMessage: String {
        switch viewModel.pairingVariant {
        case .code: return "Open Themis on \(safeChildName)'s device and enter the code."
        case .alreadyPaired: return "The existing household binding is preserved."
        case .recoveryRequired: return "A device cannot be silently reassigned from another household."
        }
    }

    private var experienceExplanation: String {
        switch viewModel.experience {
        case .child:
            return "Child uses simpler copy, larger controls and a warmer visual treatment."
        case .teen:
            return "Teen uses a more mature, autonomy-respecting presentation while keeping the same family rules."
        }
    }

    private var safeChildName: String {
        let trimmed = viewModel.childName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Sam" : trimmed
    }

    private func featureRow(_ text: String, systemImage: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: ThemisSpacing.inline12) {
            Image(systemName: systemImage)
                .foregroundStyle(ThemisColor.brandPrimary)
                .accessibilityHidden(true)
            Text(text)
                .themisFont(.body)
                .foregroundStyle(ThemisColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func factRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: ThemisSpacing.inline10) {
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ThemisColor.brandPrimary)
                .accessibilityHidden(true)
                .padding(.top, 4)
            Text(text)
                .themisFont(.body)
                .foregroundStyle(ThemisColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func selectableCard(title: String, detail: String, selected: Bool) -> some View {
        ThemisCard(isSelected: selected) {
            VStack(alignment: .leading, spacing: ThemisSpacing.inline6) {
                HStack {
                    Text(title)
                        .themisFont(.headline)
                        .foregroundStyle(ThemisColor.textPrimary)
                    Spacer()
                    if selected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(ThemisColor.brandPrimary)
                            .accessibilityLabel("Selected")
                    }
                }
                Text(detail)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func systemOwnedCard(title: String, detail: String, symbol: String) -> some View {
        ThemisCard {
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                HStack(spacing: ThemisSpacing.inline10) {
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(ThemisColor.textPrimary)
                        .accessibilityHidden(true)
                    Text(title)
                        .themisFont(.headline)
                        .foregroundStyle(ThemisColor.textPrimary)
                }
                Text(detail)
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Deterministic review states

#Preview("P-002 · Welcome") {
    OnboardingView(initialStep: .welcome)
}

#Preview("P-010 · Pairing code") {
    OnboardingView(initialStep: .pairing, pairingVariant: .code)
}

#Preview("P-010 · Already paired") {
    OnboardingView(initialStep: .pairing, pairingVariant: .alreadyPaired)
}

#Preview("P-010 · Recovery required") {
    OnboardingView(initialStep: .pairing, pairingVariant: .recoveryRequired)
}

#Preview("P-019 · Agreement") {
    OnboardingView(initialStep: .agreementReview)
}

#Preview("P-019 · Agreement · AX3") {
    OnboardingView(initialStep: .agreementReview)
        .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("P-021 · Success") {
    OnboardingView(initialStep: .protectionTestResult, testResult: .success)
}

#Preview("P-021 · Retry") {
    OnboardingView(initialStep: .protectionTestResult, testResult: .retry)
}

#Preview("P-021 · Permission") {
    OnboardingView(initialStep: .protectionTestResult, testResult: .permissionRequired)
}

#Preview("P-022 · Activated") {
    OnboardingView(initialStep: .activated, testResult: .success)
}
