import AuthenticationServices
import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @State private var welcomeReveal = 0.0
    @State private var activationVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let onComplete: () -> Void
    private let onDefer: () -> Void

    init(
        initialStep: OnboardingStep = .launch,
        pairingVariant: PairingPresentationVariant = .code,
        testResult: ProtectionTestPresentationResult = .success,
        permissionDeclined: Bool = false,
        onComplete: @escaping () -> Void = {},
        onDefer: @escaping () -> Void = {}
    ) {
        let model = OnboardingViewModel(initialStep: initialStep)
        model.pairingVariant = pairingVariant
        model.testResult = testResult
        model.applePermissionDeclined = permissionDeclined
        _viewModel = StateObject(wrappedValue: model)
        self.onComplete = onComplete
        self.onDefer = onDefer
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.step {
                case .launch:
                    launchScreen
                case .welcome:
                    welcomeScreen
                case .activated:
                    activationScreen
                default:
                    standardScreen
                }
            }
            .toolbar {
                if showsBackButton {
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
            .toolbar(showsNavigationBar ? .visible : .hidden, for: .navigationBar)
        }
        .themisAudience(currentAudience)
        .themisGround(currentGround)
        .task(id: viewModel.step) {
            await prepareCurrentStep()
        }
    }

    // MARK: - Dedicated screens

    private var launchScreen: some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.block) {
            Spacer()
            Text("Themis Family")
                .themisFont(.display)
                .foregroundStyle(ThemisColor.textPrimary)
            Text("Clear digital boundaries without the daily arguments.")
                .themisFont(.body)
                .foregroundStyle(ThemisColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            ThemisButton(title: "Continue") {
                viewModel.advance()
            }
        }
        .padding(ThemisSpacing.screen)
        .accessibilityElement(children: .contain)
    }

    private var welcomeScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                Text("Themis Family")
                    .themisFont(.meta)
                    .fontWeight(.bold)
                    .foregroundStyle(ThemisColor.textPrimary)

                AgreementTimeline(
                    model: OnboardingDemoData.welcomeTimeline,
                    revealProgress: reduceMotion ? 1 : welcomeReveal
                )

                Text("Set clear digital rules once, and let the phone enforce them.")
                    .themisFont(.display)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Clear digital boundaries without the daily arguments.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: ThemisSpacing.inline8) {
                    ThemisButton(title: "Get started") {
                        viewModel.advance()
                    }
                    ThemisButton(title: "This is my child's iPhone", style: .tertiary) {
                        viewModel.pairingVariant = .childDevice
                        viewModel.step = .pairing
                    }
                }
            }
            .padding(ThemisSpacing.screen)
        }
    }

    private var activationScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                HStack(spacing: ThemisSpacing.inline12) {
                    StatusGlyph(kind: .protected, diameter: ThemisSize.statusHeaderGlyph)
                        .scaleEffect(activationVisible ? 1 : 0.86)
                        .opacity(activationVisible ? 1 : 0)
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline6) {
                        StatusBadge(.protected, size: .chip)
                        Text("Verified on \(viewModel.safeChildName)'s iPhone just now.")
                            .themisFont(.meta)
                            .foregroundStyle(ThemisColor.textSecondary)
                    }
                }

                Text("Themis Protection is on for \(viewModel.safeChildName)")
                    .themisFont(.display)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                AgreementTimeline(
                    model: OnboardingDemoData.homeworkTimeline,
                    revealProgress: activationVisible ? 1 : 0
                )

                Text("The homework rule starts today at \(viewModel.canonicalDraft.deadlineDisplay).")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(ThemisSpacing.screen)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack {
                ThemisButton(
                    title: "Go to Home",
                    isDisabled: !viewModel.activationReadiness.canActivateProtection
                ) {
                    onComplete()
                }
            }
            .padding(.horizontal, ThemisSpacing.screen)
            .padding(.vertical, ThemisSpacing.inline10)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Standard onboarding shell

    private var standardScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ThemisSpacing.block) {
                if let current = viewModel.progressStep,
                   let label = viewModel.progressLabel {
                    StepProgress(current: current, total: 5, label: label)
                }

                if let eyebrow {
                    Text(eyebrow)
                        .themisFont(.sectionLabel)
                        .foregroundStyle(ThemisColor.textSecondary)
                }

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
            .padding(.bottom, 28)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if showsActionBar {
                actionBar
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case .launch, .welcome, .activated:
            EmptyView()

        case .signInWithApple:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                appleOwnedPlaceholder(
                    title: "Sign in with Apple",
                    detail: "Apple's button and sheet are system-owned."
                )
                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    // UI-04 remains mock-first. A failed Apple result must never
                    // advance into an "Account created" state.
                    if case .success = result {
                        viewModel.advance()
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(minHeight: 52)
                .accessibilityHint("Creates or signs in to the household Owner account")
            }

        case .accountCreated:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.success, "Account created")
                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        Text("Themis Protection")
                            .themisFont(.headline)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text(OnboardingDemoData.accountProtectionStatus)
                            .themisFont(.body)
                            .foregroundStyle(ThemisColor.textSecondary)
                        StatusBadge(.notActiveYet, size: .chip)
                        Divider()
                        numberedRow(1, "Add your child")
                        numberedRow(2, "Pair their iPhone and give Apple permission")
                        numberedRow(3, "Set and test a first rule")
                    }
                }
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
                    .background(
                        ThemisColor.surface,
                        in: RoundedRectangle(cornerRadius: ThemisRadius.input, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: ThemisRadius.input, style: .continuous)
                            .strokeBorder(ThemisColor.borderInput, lineWidth: ThemisBorder.input)
                    }
                Text("First name only. No date of birth needed.")
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
            }

        case .chooseExperience:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                experienceCard(
                    .child,
                    detail: "Simpler words and bigger buttons. Usually 8-12."
                )
                experienceCard(
                    .teen,
                    detail: "More autonomy and fuller detail. Usually 13-15."
                )
                Text("Both show the same rules and the same privacy facts. You can change this later.")
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

        case .childCreated:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                StatusGlyph(kind: .approved, diameter: ThemisSize.statusHeaderGlyph)
                Text("\(viewModel.safeChildName)'s profile is ready")
                    .themisFont(.screenTitle)
                    .foregroundStyle(ThemisColor.textPrimary)
                Text("Next, connect \(viewModel.safeChildName)'s iPhone...")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
            }

        case .pairDeviceIntro:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                numberedRow(1, "Install Themis on \(viewModel.safeChildName)'s iPhone")
                numberedRow(2, "Open it and tap \"This is my child's iPhone\"")
                numberedRow(3, "Scan or type the code from this screen")
                Text("Rules only apply once \(viewModel.safeChildName)'s iPhone is paired and Apple permission is given. This device should be used by \(viewModel.safeChildName), not shared between child profiles.")
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

        case .pairing:
            pairingContent

        case .familyControlsExplanation:
            ChecklistList(items: [
                .init(.yes, "Pause the apps you choose, at agreed times"),
                .init(.yes, "Keep Always Allowed apps available where supported"),
                .init(.no, "Read messages or browsing")
            ])

        case .appleAuthorisationHandoff:
            if viewModel.applePermissionDeclined {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    InlineBanner(.warning, "Apple permission wasn't given on \(viewModel.safeChildName)'s iPhone.")
                    Text("Themis can't pause apps without it. Protection stays not active.")
                        .themisFont(.body)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
            } else {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    appleOwnedPlaceholder(
                        title: "Family Controls permission",
                        detail: "Shown by iOS. Themis does not draw or imitate Apple's permission screen."
                    )
                    InlineBanner(.info, "Sarah's iPhone updates when this is done.")
                }
            }

        case .starterRule:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                ruleCard(
                    title: "Homework Deadline",
                    detail: "Games pause if homework isn't approved by a set time.",
                    badge: "Suggested",
                    selected: false
                )
                ruleCard(
                    title: "Bedtime",
                    detail: "Chosen apps pause overnight.",
                    badge: nil,
                    selected: false
                )
                ruleCard(
                    title: "Earn First",
                    detail: "Finish an activity, then access opens.",
                    badge: nil,
                    selected: false
                )
            }

        case .homeworkDeadlineStarter:
            ThemisCard(isSelected: true) {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    HStack {
                        Text("Homework Deadline")
                            .themisFont(.headline)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Spacer()
                        StatusBadge(ThemisStatus(.selected))
                    }
                    Text("Games pause if homework isn't approved by a set time.")
                        .themisFont(.body)
                        .foregroundStyle(ThemisColor.textSecondary)
                    Divider()
                    numberedRow(1, "Homework is due at a set time")
                    numberedRow(2, "Not approved by then? Chosen games pause")
                    numberedRow(3, "Always Allowed apps stay available where supported")
                    numberedRow(4, "\(viewModel.safeChildName) can ask for more time")
                }
            }

        case .controlledApps:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                appleOwnedPlaceholder(
                    title: "App & website picker",
                    detail: "Apple-owned sheet. Choose the games only."
                )
                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline6) {
                        Text("Selected")
                            .themisFont(.meta)
                            .foregroundStyle(ThemisColor.textSecondary)
                        Text("Roblox, Minecraft")
                            .themisFont(.headline)
                            .foregroundStyle(ThemisColor.textPrimary)
                    }
                }
            }

        case .deadline:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                TimeSelection(label: "Homework deadline", time: $viewModel.deadline)
                SegmentedChoice(
                    label: "Applies on",
                    options: OnboardingSchedule.allCases,
                    selection: $viewModel.schedule,
                    title: { $0.rawValue }
                )
                AgreementTimeline(model: OnboardingDemoData.homeworkTimeline)
            }

        case .verification:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                ThemisCard(isSelected: true) {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline10) {
                        HStack {
                            Text("Parent Approval")
                                .themisFont(.headline)
                                .foregroundStyle(ThemisColor.textPrimary)
                            Spacer()
                            StatusBadge(ThemisStatus(.selected))
                        }
                        Text("\(viewModel.safeChildName) marks it done. You or a Guardian approve.")
                            .themisFont(.body)
                            .foregroundStyle(ThemisColor.textSecondary)
                    }
                }
                Text("Automatic verification is available for supported Themis sessions.")
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                InlineBanner(
                    .info,
                    "If \(viewModel.safeChildName) sends it before 6:00 PM, games stay open for up to 30 minutes while you review."
                )
            }

        case .essentialAccess:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                accessRow("Phone", subtitle: "Recommended Always Allowed", trailing: "On")
                accessRow("Messages", subtitle: "Recommended Always Allowed", trailing: "On")
                accessRow("Maps", subtitle: "Recommended Always Allowed", trailing: "On")
                accessRow("School apps", subtitle: "Choose in Apple's picker", trailing: "Add")
                Text("Configured to stay available where supported.")
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                Text(OnboardingDemoData.emergencyAccessMessage)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
            }

        case .agreementReview:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                AgreementTimeline(model: OnboardingDemoData.homeworkTimeline)
                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        ForEach(OnboardingDemoData.agreementFacts, id: \.self) { fact in
                            factRow(fact)
                        }
                    }
                }
            }

        case .protectionTest:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                Text("We'll pause Roblox for a moment, then remove the pause. This has to pass before protection turns on.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                ThemisCard {
                    VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                        numberedRow(1, "Apply a test pause")
                        numberedRow(2, "Remove it")
                        numberedRow(3, "Confirm \(viewModel.safeChildName)'s iPhone reports back")
                    }
                }
                if viewModel.isTestingProtection {
                    InlineBanner(.info, "Testing on \(viewModel.safeChildName)'s iPhone...")
                } else {
                    InlineBanner(.info, "This UI uses a deterministic review result until production Apple enforcement is proven and wired.")
                }
            }

        case .protectionTestResult:
            protectionTestResultContent
        }
    }

    // MARK: - Pairing states

    @ViewBuilder
    private var pairingContent: some View {
        switch viewModel.pairingVariant {
        case .code:
            ThemisCard {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                    HStack {
                        Text("K7F 29Q")
                            .themisFont(.numeral)
                            .foregroundStyle(ThemisColor.textPrimary)
                            .accessibilityLabel("Pairing code K 7 F, 2 9 Q")
                        Spacer()
                        Image(systemName: "qrcode")
                            .font(.system(size: 62, weight: .regular))
                            .foregroundStyle(ThemisColor.textPrimary)
                            .accessibilityLabel("QR code")
                    }
                    Text("Code expires soon.")
                        .themisFont(.caption)
                        .foregroundStyle(ThemisColor.textSecondary)
                    InlineBanner(.info, "Waiting for \(viewModel.safeChildName)'s iPhone...")
                }
            }

        case .childDevice:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                Text("Scan the code on your parent or carer's iPhone, or type it here.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                Text("Pairing code")
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
                Text("K7F 29Q")
                    .themisFont(.numeral)
                    .foregroundStyle(ThemisColor.textPrimary)
                    .accessibilityLabel("Pairing code K 7 F, 2 9 Q")
            }

        case .codeExpired:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.warning, "This code has expired.")
                Text("Codes stop working after a short time to keep pairing secure.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
            }

        case .alreadyPaired:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.warning, "This device already belongs to another Themis household.")
                Text("Ask your parent or carer to remove it, or use secure recovery.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                Text("An Owner or Guardian of the other household has to remove or transfer it first. This iPhone can't remove itself.")
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
            }

        case .recoveryRequired:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                Text("We need to confirm you're allowed to take over this device before it leaves the other household.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                appleOwnedPlaceholder(
                    title: "Identity check",
                    detail: "Mechanism to be set by security design."
                )
                InlineBanner(
                    .info,
                    "\(viewModel.safeChildName)'s iPhone stays with its current household until recovery is approved."
                )
            }
        }
    }

    // MARK: - Result states

    @ViewBuilder
    private var protectionTestResultContent: some View {
        switch viewModel.testResult {
        case .success:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                HStack(spacing: ThemisSpacing.inline12) {
                    StatusGlyph(kind: .protected, diameter: ThemisSize.statusHeaderGlyph)
                    Text("Test passed")
                        .themisFont(.screenTitle)
                        .foregroundStyle(ThemisColor.textPrimary)
                }
                Text("Roblox paused and resumed on \(viewModel.safeChildName)'s iPhone.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                Text("Verified just now.")
                    .themisFont(.meta)
                    .foregroundStyle(ThemisColor.textSecondary)
            }

        case .retry:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.warning, "The test didn't complete.")
                Text("\(viewModel.safeChildName)'s iPhone didn't confirm the test pause.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
                Text("Setup stays not protected until a test passes.")
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
            }

        case .permissionRequired:
            VStack(alignment: .leading, spacing: ThemisSpacing.inline12) {
                InlineBanner(.warning, "Apple permission needs attention.")
                Text("Protection stays not active until Family Controls permission is available and the test passes.")
                    .themisFont(.body)
                    .foregroundStyle(ThemisColor.textSecondary)
            }
        }
    }

    // MARK: - Bottom actions

    private var actionBar: some View {
        VStack(spacing: ThemisSpacing.inline8) {
            ThemisButton(
                title: primaryActionTitle,
                isLoading: viewModel.step == .protectionTest && viewModel.isTestingProtection,
                isDisabled: primaryActionDisabled,
                action: primaryAction
            )
            if let secondaryActionTitle {
                ThemisButton(
                    title: secondaryActionTitle,
                    style: .tertiary,
                    action: secondaryAction
                )
            }
        }
        .padding(.horizontal, ThemisSpacing.screen)
        .padding(.top, ThemisSpacing.inline10)
        .padding(.bottom, ThemisSpacing.inline8)
        .background(.ultraThinMaterial)
    }

    private var primaryActionTitle: String {
        switch viewModel.step {
        case .accountCreated: return "Continue setup"
        case .goal, .addChild, .chooseExperience: return "Continue"
        case .pairDeviceIntro: return "Show pairing code"
        case .pairing:
            switch viewModel.pairingVariant {
            case .code: return "Continue on \(viewModel.safeChildName)'s iPhone"
            case .childDevice: return "Pair this iPhone"
            case .codeExpired: return "Get a new code"
            case .alreadyPaired: return "Try pairing again"
            case .recoveryRequired: return "Start secure recovery"
            }
        case .familyControlsExplanation:
            return "Continue on \(viewModel.safeChildName)'s iPhone"
        case .appleAuthorisationHandoff:
            return viewModel.applePermissionDeclined ? "Try again on \(viewModel.safeChildName)'s iPhone" : "Continue after Apple permission"
        case .starterRule, .homeworkDeadlineStarter:
            return "Use Homework Deadline"
        case .controlledApps, .deadline, .verification, .essentialAccess:
            return "Continue"
        case .agreementReview:
            return "Looks good"
        case .protectionTest:
            return viewModel.isTestingProtection ? "Testing..." : "Run test"
        case .protectionTestResult:
            switch viewModel.testResult {
            case .success: return "Turn on protection"
            case .retry: return "Run test again"
            case .permissionRequired: return "Check Apple permission"
            }
        case .launch, .welcome, .signInWithApple, .childCreated, .activated:
            return "Continue"
        }
    }

    private var secondaryActionTitle: String? {
        switch viewModel.step {
        case .goal:
            return "Skip"
        case .pairDeviceIntro:
            return "Do this later"
        case .pairing:
            switch viewModel.pairingVariant {
            case .code: return "Get a new code"
            case .childDevice: return "Scan the code instead"
            case .alreadyPaired: return "Use secure recovery"
            case .codeExpired, .recoveryRequired: return nil
            }
        case .appleAuthorisationHandoff:
            return viewModel.applePermissionDeclined ? "Why this is needed" : "Permission was declined?"
        case .protectionTestResult:
            return viewModel.testResult == .retry ? "Check Apple permission" : nil
        default:
            return nil
        }
    }

    private var primaryActionDisabled: Bool {
        switch viewModel.step {
        case .addChild:
            return viewModel.childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default:
            return false
        }
    }

    private func primaryAction() {
        switch viewModel.step {
        case .pairDeviceIntro:
            viewModel.pairingVariant = .code
            viewModel.advance()

        case .pairing:
            switch viewModel.pairingVariant {
            case .code:
                viewModel.pairingVariant = .childDevice
            case .childDevice:
                viewModel.pairingVariant = .code
                viewModel.advance()
            case .codeExpired, .alreadyPaired:
                viewModel.pairingVariant = .code
            case .recoveryRequired:
                // Secure recovery is intentionally not simulated as successful.
                // The device stays with its current household until an authorised
                // recovery mechanism exists.
                break
            }

        case .appleAuthorisationHandoff:
            if viewModel.applePermissionDeclined {
                viewModel.applePermissionDeclined = false
            } else {
                viewModel.advance()
            }

        case .homeworkDeadlineStarter:
            viewModel.step = .controlledApps

        case .protectionTest:
            Task { await viewModel.runProtectionTest() }

        case .protectionTestResult:
            switch viewModel.testResult {
            case .success:
                viewModel.advance()
            case .retry:
                viewModel.retryProtectionTest()
            case .permissionRequired:
                viewModel.step = .familyControlsExplanation
            }

        default:
            viewModel.advance()
        }
    }

    private func secondaryAction() {
        switch viewModel.step {
        case .goal:
            viewModel.advance()
        case .pairDeviceIntro:
            onDefer()
        case .pairing:
            switch viewModel.pairingVariant {
            case .code:
                viewModel.pairingVariant = .code
            case .childDevice:
                break
            case .alreadyPaired:
                viewModel.pairingVariant = .recoveryRequired
            case .codeExpired, .recoveryRequired:
                break
            }
        case .appleAuthorisationHandoff:
            if viewModel.applePermissionDeclined {
                viewModel.step = .familyControlsExplanation
            } else {
                viewModel.applePermissionDeclined = true
            }
        case .protectionTestResult:
            if viewModel.testResult == .retry {
                viewModel.testResult = .permissionRequired
            }
        default:
            break
        }
    }

    // MARK: - Copy and context

    private var currentAudience: ThemisAudience {
        if viewModel.step == .appleAuthorisationHandoff {
            return .child
        }
        if viewModel.step == .pairing && viewModel.pairingVariant == .childDevice {
            return .child
        }
        return .parent
    }

    private var currentGround: ThemisGround {
        currentAudience == .child ? .warm : .plain
    }

    private var showsNavigationBar: Bool {
        ![OnboardingStep.launch, .welcome, .childCreated, .activated].contains(viewModel.step)
    }

    private var showsBackButton: Bool {
        showsNavigationBar && viewModel.canGoBack
    }

    private var showsActionBar: Bool {
        ![OnboardingStep.launch, .welcome, .signInWithApple, .childCreated, .activated].contains(viewModel.step)
    }

    private var eyebrow: String? {
        switch viewModel.step {
        case .controlledApps: return "Games to pause"
        case .deadline: return "Deadline"
        case .verification: return "How it's checked"
        case .essentialAccess: return "Always Allowed"
        case .agreementReview: return "Review"
        case .protectionTest, .protectionTestResult: return "Test"
        case .appleAuthorisationHandoff where !viewModel.applePermissionDeclined:
            return "On \(viewModel.safeChildName)'s iPhone"
        default: return nil
        }
    }

    private var title: String {
        switch viewModel.step {
        case .launch: return "Themis Family"
        case .welcome: return "Set clear digital rules once, and let the phone enforce them."
        case .signInWithApple: return "Create your family account"
        case .accountCreated: return OnboardingDemoData.accountCreatedTitle
        case .goal: return "What are you struggling with?"
        case .addChild: return "Who are we setting up?"
        case .chooseExperience: return "Which experience suits \(viewModel.safeChildName)?"
        case .childCreated: return "\(viewModel.safeChildName)'s profile is ready"
        case .pairDeviceIntro: return "Pair \(viewModel.safeChildName)'s iPhone"
        case .pairing:
            switch viewModel.pairingVariant {
            case .code, .codeExpired: return "Pairing code"
            case .childDevice: return "Pair with your family"
            case .alreadyPaired: return "Pairing"
            case .recoveryRequired: return "Secure recovery"
            }
        case .familyControlsExplanation: return "Why Apple asks for permission"
        case .appleAuthorisationHandoff:
            return viewModel.applePermissionDeclined
                ? "Apple permission wasn't given"
                : "One more step from Apple"
        case .starterRule, .homeworkDeadlineStarter: return "Choose a first rule"
        case .controlledApps: return "Which apps pause if homework isn't done?"
        case .deadline: return "When is homework due?"
        case .verification: return "How do you confirm it's done?"
        case .essentialAccess: return "What should stay available?"
        case .agreementReview: return "\(viewModel.safeChildName)'s family agreement"
        case .protectionTest: return "Let's test it on \(viewModel.safeChildName)'s iPhone"
        case .protectionTestResult:
            switch viewModel.testResult {
            case .success: return "Test passed"
            case .retry: return "The test didn't complete."
            case .permissionRequired: return "Apple permission needs attention"
            }
        case .activated: return "Themis Protection is on for \(viewModel.safeChildName)"
        }
    }

    private var message: String? {
        switch viewModel.step {
        case .signInWithApple:
            return "You'll be the Owner of your household. Apple handles your password."
        case .goal:
            return "Pick any. We'll suggest where to start."
        case .familyControlsExplanation:
            return "Apple's Screen Time controls let Themis pause the apps you choose. Apple asks on \(viewModel.safeChildName)'s iPhone."
        case .starterRule, .homeworkDeadlineStarter:
            return nil
        case .controlledApps:
            return "Apple's picker opens next. Choose the games only."
        case .appleAuthorisationHandoff where !viewModel.applePermissionDeclined:
            return "Family Controls permission is provided by iOS, not by Themis."
        default:
            return nil
        }
    }

    // MARK: - Reusable local presentation

    private func experienceCard(_ experience: OnboardingExperience, detail: String) -> some View {
        Button {
            viewModel.experience = experience
        } label: {
            ThemisCard(isSelected: viewModel.experience == experience) {
                VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
                    HStack {
                        Text(experience.rawValue)
                            .themisFont(.headline)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Spacer()
                        if viewModel.experience == experience {
                            StatusBadge(ThemisStatus(.selected))
                        }
                    }
                    Text(detail)
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(viewModel.experience == experience ? .isSelected : [])
    }

    private func ruleCard(
        title: String,
        detail: String,
        badge: String?,
        selected: Bool
    ) -> some View {
        ThemisCard(isSelected: selected) {
            VStack(alignment: .leading, spacing: ThemisSpacing.inline8) {
                HStack(alignment: .top) {
                    Text(title)
                        .themisFont(.headline)
                        .foregroundStyle(ThemisColor.textPrimary)
                    Spacer()
                    if selected {
                        StatusBadge(ThemisStatus(.selected))
                    } else if let badge {
                        StatusBadge(ThemisStatus(.suggested, label: badge))
                    }
                }
                Text(detail)
                    .themisFont(.secondary)
                    .foregroundStyle(ThemisColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func numberedRow(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: ThemisSpacing.inline12) {
            Text("\(number)")
                .themisFont(.caption)
                .foregroundStyle(ThemisColor.textOnPrimary)
                .frame(width: 26, height: 26)
                .background(ThemisColor.brandSecondary, in: Circle())
                .accessibilityHidden(true)
            Text(text)
                .themisFont(.body)
                .foregroundStyle(ThemisColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(number), \(text)")
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

    private func accessRow(
        _ title: String,
        subtitle: String,
        trailing: String
    ) -> some View {
        ThemisCard {
            HStack(alignment: .center, spacing: ThemisSpacing.inline12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .themisFont(.rowTitle)
                        .foregroundStyle(ThemisColor.textPrimary)
                    Text(subtitle)
                        .themisFont(.meta)
                        .foregroundStyle(ThemisColor.textSecondary)
                }
                Spacer(minLength: ThemisSpacing.inline8)
                Text(trailing)
                    .themisFont(.caption)
                    .foregroundStyle(trailing == "On" ? ThemisColor.brandPrimary : ThemisColor.textPrimary)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func appleOwnedPlaceholder(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: ThemisSpacing.inline10) {
            Text("APPLE-OWNED UI · NOT DRAWN")
                .themisFont(.sectionLabel)
                .foregroundStyle(ThemisColor.textSecondary)
            HStack(alignment: .top, spacing: ThemisSpacing.inline12) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(ThemisColor.textPrimary)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: ThemisSpacing.inline6) {
                    Text(title)
                        .themisFont(.headline)
                        .foregroundStyle(ThemisColor.textPrimary)
                    Text(detail)
                        .themisFont(.secondary)
                        .foregroundStyle(ThemisColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(ThemisSpacing.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ThemisColor.surface,
            in: RoundedRectangle(cornerRadius: currentAudience.cardRadius, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: currentAudience.cardRadius, style: .continuous)
                .strokeBorder(
                    ThemisColor.borderInput,
                    style: StrokeStyle(lineWidth: ThemisBorder.input, dash: [6, 5])
                )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Apple-owned interface. \(title). \(detail)")
    }

    // MARK: - Step lifecycle

    @MainActor
    private func prepareCurrentStep() async {
        switch viewModel.step {
        case .welcome:
            if reduceMotion {
                welcomeReveal = 1
            } else {
                welcomeReveal = 0
                withAnimation(.linear(duration: ThemisMotion.revealDuration)) {
                    welcomeReveal = 1
                }
            }

        case .childCreated:
            try? await Task.sleep(for: .milliseconds(700))
            guard !Task.isCancelled, viewModel.step == .childCreated else { return }
            withAnimation(ThemisMotion.animation(.lightweightAdvance, reduceMotion: reduceMotion)) {
                viewModel.advance()
            }

        case .activated:
            activationVisible = false
            withAnimation(ThemisMotion.animation(.protectionActivated, reduceMotion: reduceMotion)) {
                activationVisible = true
            }

        default:
            activationVisible = false
        }
    }
}

// MARK: - Deterministic review states

#Preview("P-002 · Welcome") {
    OnboardingView(initialStep: .welcome)
}

#Preview("P-004 · Account created") {
    OnboardingView(initialStep: .accountCreated)
}

#Preview("P-010 · Pairing code") {
    OnboardingView(initialStep: .pairing, pairingVariant: .code)
}

#Preview("P-010 · Child device") {
    OnboardingView(initialStep: .pairing, pairingVariant: .childDevice)
}

#Preview("P-010 · Code expired") {
    OnboardingView(initialStep: .pairing, pairingVariant: .codeExpired)
}

#Preview("P-010 · Already paired") {
    OnboardingView(initialStep: .pairing, pairingVariant: .alreadyPaired)
}

#Preview("P-010 · Recovery required") {
    OnboardingView(initialStep: .pairing, pairingVariant: .recoveryRequired)
}

#Preview("P-012 · Apple handoff") {
    OnboardingView(initialStep: .appleAuthorisationHandoff)
}

#Preview("P-012 · Declined") {
    OnboardingView(initialStep: .appleAuthorisationHandoff, permissionDeclined: true)
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
