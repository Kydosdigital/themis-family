import XCTest
@testable import ThemisFamily

final class SettingsTests: XCTestCase {
    private let household = SettingsDemoData.household
    private let noGuardian = SettingsDemoData.householdWithoutGuardian
    private let pendingInvite = SettingsDemoData.householdWithPendingInvite

    @MainActor
    private func model(_ scenario: SettingsScenario) -> SettingsViewModel {
        SettingsViewModel(state: SettingsDemoData.state(for: scenario))
    }

    private func rows(_ sections: [SettingsRowSection]) -> [SettingsRowModel] {
        sections.flatMap(\.rows)
    }

    /// Every sentence the Settings copy can show.
    private var allCopy: [String] {
        let tupleCopy = [
            SettingsCopy.structuredHistoryRetention.label, SettingsCopy.structuredHistoryRetention.period,
            SettingsCopy.freeTextRetention.label, SettingsCopy.freeTextRetention.period,
            SettingsCopy.auditLogRetention.label, SettingsCopy.auditLogRetention.period
        ]
        return tupleCopy + [
            SettingsCopy.ownerOnlyBanner(ownerName: "Sarah"), SettingsCopy.guardianCan, SettingsCopy.guardianCannot,
            SettingsCopy.removeGuardianTitle("Alex"), SettingsCopy.removeGuardianLine("Alex"), SettingsCopy.inviteIntro,
            SettingsCopy.inviteSentNote, SettingsCopy.guardianSlotTaken, SettingsCopy.firstNameHelper,
            SettingsCopy.experiencePrinciple, SettingsCopy.removeDeviceLine, SettingsCopy.removingNote,
            SettingsCopy.notificationsPrivacyNote, SettingsCopy.notificationsLimitsNote, SettingsCopy.privacyKeepsHeading,
            SettingsCopy.privacyNeverHeading, SettingsCopy.neverHasAppUsage, SettingsCopy.neverHasMessagesAndHistory,
            SettingsCopy.privacyFooter, SettingsCopy.supportIntro, SettingsCopy.supportContactNote, SettingsCopy.supportSentNote,
            SettingsCopy.resyncRequestedNote, SettingsCopy.safeguardingTitle, SettingsCopy.safeguardingEmergency,
            SettingsCopy.safeguardingBody, SettingsCopy.safeguardingPrivacy, SettingsCopy.safeguardingAction,
            SettingsCopy.safeguardingPending, SettingsCopy.transferLoses, SettingsCopy.transferKeeps, SettingsCopy.leaveTitle,
            SettingsCopy.leaveRule, SettingsCopy.noGuardianInfo, SettingsCopy.deleteSubscriptionNote,
            SettingsCopy.deleteBody(childNames: ["Sam", "Maya"]), SettingsCopy.deleteFinalLine(childNames: ["Sam", "Maya"]),
            SettingsCopy.deletedNote(childNames: ["Sam", "Maya"]), SettingsCopy.signOutTitle,
            SettingsCopy.signOutLine(otherParent: "Alex")
        ]
    }

    // MARK: ST-001

    // TEST 1
    func testOwnerSettingsContainsTheCanonicalFamily() {
        let sections = SettingsPresentation.rootSections(household: household, viewerRole: .owner)
        let all = rows(sections)
        XCTAssertEqual(all.first { $0.id == "account" }?.title, "Sarah")
        XCTAssertEqual(all.first { $0.id == "account" }?.subtitle, "Owner · signed in with Apple")
        XCTAssertEqual(all.first { $0.id == "household" }?.subtitle, "Sarah’s family")
        XCTAssertEqual(all.first { $0.id == "children" }?.subtitle, "Sam, Maya")
        XCTAssertEqual(all.first { $0.id == "guardian" }?.subtitle, "Alex")
    }

    func testOwnerSettingsMatchesTheApprovedFrame() {
        let sections = SettingsPresentation.rootSections(household: household, viewerRole: .owner)
        XCTAssertEqual(sections.map(\.title), [nil, "Household", "Preferences", "Subscription", "Help"])
        XCTAssertEqual(
            sections.map { $0.rows.map(\.title) },
            [["Sarah"], ["Household", "Children & devices", "Guardian"], ["Notifications", "Privacy & transparency"],
             ["Subscription"], ["Support", "Safeguarding help"]]
        )
        XCTAssertEqual(rows(sections).first { $0.id == "subscription" }?.subtitle, "Active")
        XCTAssertEqual(rows(sections).first { $0.id == "support" }?.subtitle, "Fix a problem with Themis")
        XCTAssertEqual(rows(sections).first { $0.id == "safeguarding" }?.subtitle, "Worried about a child’s safety")
        XCTAssertEqual(rows(sections).first { $0.id == "account" }?.route, .account)
    }

    func testGuardianSettingsMatchesTheApprovedFrame() {
        let sections = SettingsPresentation.rootSections(household: household, viewerRole: .guardian)
        XCTAssertEqual(sections.map(\.title), [nil, "Household", "Owner only", "Help"])
        XCTAssertEqual(rows(sections).first { $0.id == "account" }?.title, "Alex")
        XCTAssertEqual(rows(sections).first { $0.id == "account" }?.subtitle, "Guardian · signed in with Apple")
        XCTAssertEqual(rows(sections).first { $0.id == "household" }?.subtitle, "Owner: Sarah")
        let ownerOnly = sections.first { $0.title == "Owner only" }?.rows
        XCTAssertEqual(ownerOnly?.map(\.title), ["Subscription", "Guardian and ownership"])
        XCTAssertEqual(ownerOnly?.map(\.subtitle), ["Sarah manages this", "Sarah manages this"])
    }

    // MARK: Permissions

    // TEST 2
    func testGuardianCannotManageSubscription() {
        XCTAssertFalse(SettingsRole.guardian.can(.manageSubscription))
        XCTAssertTrue(SettingsRole.owner.can(.manageSubscription))
        let subscription = rows(SettingsPresentation.rootSections(household: household, viewerRole: .guardian)).first { $0.id == "subscription" }
        XCTAssertEqual(subscription?.isOwnerOnlyLocked, true)
        XCTAssertNil(subscription?.route)
    }

    // TEST 3
    @MainActor
    func testGuardianCannotInviteAnotherGuardian() async {
        XCTAssertFalse(SettingsRole.guardian.can(.inviteGuardian))
        let guardianModel = model(.guardian)
        let before = guardianModel.household
        let invited = await guardianModel.inviteGuardian(contact: "someone@example.com")
        XCTAssertFalse(invited)
        XCTAssertEqual(guardianModel.household, before)
    }

    // TEST 4
    @MainActor
    func testGuardianCannotRemoveTheGuardian() async {
        XCTAssertFalse(SettingsRole.guardian.can(.removeGuardian))
        let guardianModel = model(.guardian)
        let removed = await guardianModel.removeGuardian()
        XCTAssertFalse(removed)
        XCTAssertNotNil(guardianModel.household.acceptedGuardian)
    }

    // TEST 5
    @MainActor
    func testGuardianCannotTransferOwnership() async {
        XCTAssertFalse(SettingsRole.guardian.can(.transferOwnership))
        let guardianModel = model(.guardian)
        let transferred = await guardianModel.transferOwnership()
        XCTAssertFalse(transferred)
        XCTAssertEqual(guardianModel.household.owner.id, "sarah")
        XCTAssertEqual(guardianModel.ownershipTransfer, .idle)
    }

    // TEST 6
    @MainActor
    func testGuardianCannotDeleteTheHousehold() async {
        XCTAssertFalse(SettingsRole.guardian.can(.deleteHousehold))
        let guardianModel = model(.guardian)
        let deleted = await guardianModel.deleteHousehold(typed: "DELETE")
        XCTAssertFalse(deleted)
        XCTAssertEqual(guardianModel.deletion, .idle)
    }

    // TEST 7
    @MainActor
    func testOwnerCanInviteAndRemoveAGuardian() async {
        XCTAssertTrue(SettingsRole.owner.can(.inviteGuardian))
        XCTAssertTrue(SettingsRole.owner.can(.removeGuardian))

        let invitingModel = model(.ownerNoGuardian)
        let invited = await invitingModel.inviteGuardian(contact: "alex@example.com")
        XCTAssertTrue(invited)
        XCTAssertEqual(invitingModel.household.guardian, .invited(name: "Alex", contact: "alex@example.com"))
        XCTAssertNil(invitingModel.household.acceptedGuardian, "A pending invite is not a household member")

        let removingModel = model(.owner)
        let removed = await removingModel.removeGuardian()
        XCTAssertTrue(removed)
        XCTAssertEqual(removingModel.household.guardian, .none)
        // Removing the Guardian does not move ownership or touch the children.
        XCTAssertEqual(removingModel.household.owner.id, "sarah")
        XCTAssertEqual(removingModel.household.children, household.children)
    }

    // TEST 8
    @MainActor
    func testV1CapsGuardiansAtOne() async {
        XCTAssertEqual(SettingsHousehold.maxGuardians, 1)
        XCTAssertFalse(household.canInviteGuardian)
        XCTAssertFalse(pendingInvite.canInviteGuardian, "A pending invite fills the single slot")
        XCTAssertTrue(noGuardian.canInviteGuardian)
        XCTAssertLessThanOrEqual(household.guardianCount, SettingsHousehold.maxGuardians)

        let ownerModel = model(.owner)
        let second = await ownerModel.inviteGuardian(contact: "second@example.com")
        XCTAssertFalse(second)
        XCTAssertEqual(ownerModel.household.acceptedGuardian?.id, "alex")

        let pendingModel = model(.ownerPendingInvite)
        let secondInvite = await pendingModel.inviteGuardian(contact: "second@example.com")
        XCTAssertFalse(secondInvite)
        XCTAssertEqual(pendingModel.household.pendingInvite?.name, "Alex")
    }

    // MARK: Children and devices

    // TEST 9
    @MainActor
    func testOwnerAndGuardianMayBothAddAChild() async {
        XCTAssertTrue(SettingsRole.owner.can(.addChild))
        XCTAssertTrue(SettingsRole.guardian.can(.addChild))
        for scenario in [SettingsScenario.owner, .guardian] {
            let viewModel = model(scenario)
            let added = await viewModel.addChild(NewChildDraft(firstName: "Leo", experience: .child))
            XCTAssertTrue(added, "\(scenario)")
            XCTAssertEqual(viewModel.household.children.last?.firstName, "Leo")
            XCTAssertEqual(viewModel.household.children.last?.experience, .child)
            XCTAssertNil(viewModel.household.children.last?.device, "A new child has no paired device yet")
        }
    }

    // TEST 10
    @MainActor
    func testAddChildStoresFirstNameAndExperienceOnly() async {
        let draftFields = Mirror(reflecting: NewChildDraft()).children.compactMap(\.label)
        XCTAssertEqual(draftFields, ["firstName", "experience"])

        let profileFields = Mirror(reflecting: SettingsDemoData.sam).children.compactMap(\.label)
        for forbidden in ["birth", "dob", "age", "school", "gender", "location", "appleAccount", "appleID"] {
            XCTAssertFalse(profileFields.contains { $0.lowercased().contains(forbidden.lowercased()) }, "Profile has a \(forbidden) field")
            XCTAssertFalse(draftFields.contains { $0.lowercased().contains(forbidden.lowercased()) }, "Draft has a \(forbidden) field")
        }
        // Both are required: a name and an explicit experience. Nothing is inferred.
        XCTAssertFalse(NewChildDraft(firstName: "Leo").isComplete)
        XCTAssertFalse(NewChildDraft(firstName: "  ", experience: .teen).isComplete)
        XCTAssertTrue(NewChildDraft(firstName: "Leo", experience: .teen).isComplete)

        let viewModel = model(.owner)
        let added = await viewModel.addChild(NewChildDraft(firstName: "Leo", experience: nil))
        XCTAssertFalse(added)
        XCTAssertEqual(SettingsCopy.firstNameHelper, "First name only. No date of birth needed.")
        XCTAssertEqual(SettingsCopy.experiencePrinciple, "Choose the experience that best fits your child. You can change this later.")
    }

    // TEST 11
    @MainActor
    func testOwnerAndGuardianMayBothAddAndRemoveChildDevices() async {
        for role in SettingsRole.allCases {
            XCTAssertTrue(role.can(.addChildDevice), "\(role)")
            XCTAssertTrue(role.can(.removeChildDevice), "\(role)")
        }
        let guardianModel = model(.guardian)
        let requested = await guardianModel.requestDeviceRemoval(childID: "sam")
        XCTAssertTrue(requested)
    }

    // TEST 12
    func testOneDevicePerChildV1AssumptionIsRepresented() {
        XCTAssertEqual(ChildProfilePresentation.assumedManagedDevicesPerChild, 1)
        // A single optional device, not a list.
        XCTAssertTrue(type(of: SettingsDemoData.sam.device) == Optional<ManagedDevicePresentation>.self)
        XCTAssertEqual(household.children.map { $0.device?.name }, ["Sam’s iPhone", "Maya’s iPhone"])
        // It is a scope assumption, not a cap: no copy states a device limit.
        for sentence in allCopy {
            XCTAssertFalse(sentence.localizedCaseInsensitiveContains("one device"), sentence)
            XCTAssertFalse(sentence.localizedCaseInsensitiveContains("only one"), sentence)
        }
    }

    // TEST 13
    func testDeviceRemovalHasSeparateRemoveRemovingAndRemovedStates() {
        let states: [DeviceRemovalState] = [.idle, .removeRequested, .removing, .removed]
        XCTAssertEqual(Set(states.map { "\($0)" }).count, 4)
        XCTAssertNotEqual(DeviceRemovalState.removeRequested, .removing)
        XCTAssertNotEqual(DeviceRemovalState.removing, .removed)
    }

    // TEST 14
    @MainActor
    func testRemovingIsNotReportedAsRemoved() async throws {
        let viewModel = model(.owner)
        let requested = await viewModel.requestDeviceRemoval(childID: "sam")
        XCTAssertTrue(requested)
        XCTAssertEqual(viewModel.removal(for: "sam"), .removing)
        XCTAssertFalse(viewModel.removal(for: "sam").isFinal)
        XCTAssertNotNil(viewModel.household.child(id: "sam")?.device, "The device stays until it confirms")
        let row = SettingsPresentation.deviceRow(for: try XCTUnwrap(viewModel.household.child(id: "sam")), removal: viewModel.removal(for: "sam"))
        XCTAssertEqual(row.status, .removing)
        XCTAssertEqual(row.subtitle, "Waiting for Sam’s iPhone to confirm")

        // Only an acknowledgement moves it to Removed, and the profile is kept.
        viewModel.acknowledgeDeviceRemoval(childID: "sam")
        XCTAssertEqual(viewModel.removal(for: "sam"), .removed)
        XCTAssertTrue(viewModel.removal(for: "sam").isFinal)
        XCTAssertNil(viewModel.household.child(id: "sam")?.device)
        XCTAssertEqual(viewModel.household.child(id: "sam")?.firstName, "Sam")
    }

    @MainActor
    func testAcknowledgementIsIgnoredUnlessRemovalWasRequested() {
        let viewModel = model(.owner)
        viewModel.acknowledgeDeviceRemoval(childID: "sam")
        XCTAssertEqual(viewModel.removal(for: "sam"), .idle)
        XCTAssertNotNil(viewModel.household.child(id: "sam")?.device)
    }

    func testChildrenAndDevicesMatchesTheApprovedFrame() {
        let sam = SettingsPresentation.deviceRow(for: SettingsDemoData.sam, removal: .idle)
        XCTAssertEqual(sam.title, "Sam’s iPhone")
        XCTAssertEqual(sam.subtitle, "Verified 2 min ago")
        XCTAssertEqual(sam.status, .protected)
        let maya = SettingsPresentation.deviceRow(for: SettingsDemoData.maya, removal: .idle)
        XCTAssertEqual(maya.subtitle, "Verified 14 min ago")
        XCTAssertEqual(maya.status?.kind, .syncPending)
        XCTAssertEqual(SettingsDemoData.sam.title, "Sam · Child")
        XCTAssertEqual(SettingsDemoData.maya.title, "Maya · Teen")
        XCTAssertEqual(SettingsDemoData.sam.device?.applePermission, "Given")
        XCTAssertEqual(SettingsDemoData.sam.device?.paired, "3 Sep")
    }

    func testChildAndDeviceCopyMatchesTheApprovedFrames() {
        XCTAssertEqual(SettingsCopy.removeChildTitle("Sam"), "Remove Sam from your household?")
        XCTAssertEqual(
            SettingsCopy.removeChildLine("Sam"),
            "Themis removes its restrictions from Sam’s iPhone and unpairs it. Sam’s history follows the normal retention periods."
        )
        XCTAssertEqual(SettingsCopy.removeDeviceTitle("Sam’s iPhone"), "Remove Sam’s iPhone?")
        XCTAssertEqual(SettingsCopy.removingTitle("Sam’s iPhone"), "Removing Sam’s iPhone")
        XCTAssertEqual(SettingsCopy.removedTitle("Sam’s iPhone"), "Sam’s iPhone removed")
        XCTAssertEqual(SettingsCopy.removedNote("Sam"), "Sam’s profile and rules are kept. Pair a device to protect Sam again.")
        XCTAssertEqual(
            SettingsCopy.experienceChangeNote("Sam"),
            "Changing the experience changes wording and layout on Sam’s iPhone. Rules stay the same."
        )
    }

    @MainActor
    func testRemovingAChildIsARequestNotAnAcknowledgedRemoval() async {
        let viewModel = model(.owner)
        let removed = await viewModel.removeChild(id: "sam")
        XCTAssertTrue(removed)
        XCTAssertEqual(viewModel.childRemoval["sam"], .requested)
        XCTAssertNotNil(viewModel.household.child(id: "sam"), "The profile stays until removal is acknowledged")
        XCTAssertNotNil(viewModel.household.child(id: "sam")?.device, "No device is claimed unbound")
    }

    // Child-profile removal authority is unresolved: Owner-canonical, no Guardian rule asserted.
    @MainActor
    func testChildProfileRemovalIsAConservativeOwnerCanonicalGate() async {
        XCTAssertTrue(SettingsRole.owner.can(.removeChildProfile), "P-033 · Remove stays for the canonical Owner")
        XCTAssertFalse(SettingsRole.guardian.can(.removeChildProfile), "Guardian authority is not confirmed")
        XCTAssertTrue(SettingsCapability.unresolvedAuthority.contains(.removeChildProfile))
        XCTAssertFalse(SettingsCapability.ownerOnly.contains(.removeChildProfile), "Not recorded as a confirmed Owner-only power")
        XCTAssertEqual(SettingsCapability.unresolvedAuthority, [.removeChildProfile])

        let guardianModel = model(.guardian)
        let removed = await guardianModel.removeChild(id: "sam")
        XCTAssertFalse(removed)
        XCTAssertNil(guardianModel.childRemoval["sam"])
        XCTAssertNotNil(guardianModel.household.child(id: "sam"))

        // The Guardian can still edit the profile and manage devices.
        XCTAssertTrue(SettingsRole.guardian.can(.editChildProfile))
        let saved = await guardianModel.saveChild(id: "sam", firstName: "Sam", experience: .teen)
        XCTAssertTrue(saved)
        XCTAssertTrue(SettingsRole.guardian.can(.addChildDevice))
        XCTAssertTrue(SettingsRole.guardian.can(.removeChildDevice))
        let deviceRemoval = await guardianModel.requestDeviceRemoval(childID: "sam")
        XCTAssertTrue(deviceRemoval)
    }

    func testGuardianCopyNamesOnlyConfirmedOwnerOnlyPowers() {
        let copy = SettingsCopy.guardianCannot
        XCTAssertFalse(copy.lowercased().contains("remove anyone"))
        for phrase in ["subscription", "invite or remove the Guardian", "transfer ownership", "delete the household"] {
            XCTAssertTrue(copy.contains(phrase), phrase)
        }
        XCTAssertFalse(copy.lowercased().contains("device"), "Guardians may remove child devices")
        XCTAssertFalse(copy.lowercased().contains("child"))
    }

    @MainActor
    func testEditingAChildChangesOnlyNameAndExperience() async {
        let viewModel = model(.owner)
        let saved = await viewModel.saveChild(id: "sam", firstName: "Samuel", experience: .teen)
        XCTAssertTrue(saved)
        XCTAssertEqual(viewModel.household.child(id: "sam")?.firstName, "Samuel")
        XCTAssertEqual(viewModel.household.child(id: "sam")?.experience, .teen)
        XCTAssertEqual(viewModel.household.child(id: "sam")?.device, SettingsDemoData.sam.device)
        let blank = await viewModel.saveChild(id: "sam", firstName: " ", experience: .child)
        XCTAssertFalse(blank)
    }

    // MARK: ST-006 Privacy

    // TEST 15
    func testPrivacyMakesNoSurveillanceClaim() {
        let keeps = [
            SettingsCopy.structuredHistoryRetention.label, SettingsCopy.freeTextRetention.label, SettingsCopy.auditLogRetention.label
        ].joined(separator: " ").lowercased()
        for word in ["message", "chat", "browsing", "search", "screen time", "location", "usage", "domain"] {
            XCTAssertFalse(keeps.contains(word), "“What Themis keeps” mentions \(word)")
        }
        // Those words appear only under "What Themis never has".
        XCTAssertTrue(SettingsCopy.neverHasMessagesAndHistory.contains("Messages, chats, browsing or search history"))
        XCTAssertEqual(SettingsCopy.neverHasAppUsage, "Which apps your children use, or for how long")
        XCTAssertTrue(SettingsCopy.privacyFooter.contains("never stored by Themis"))
        XCTAssertTrue(SettingsCopy.privacyFooter.contains("shown by Apple"))
        let claims = ["themis receives", "themis stores your", "themis can see", "themis tracks", "themis monitors", "we read", "we collect"]
        for sentence in allCopy {
            for claim in claims { XCTAssertFalse(sentence.lowercased().contains(claim), sentence) }
        }
    }

    // TEST 16
    func testPrivacyDistinguishesStructuredAndFreeTextRetention() {
        XCTAssertEqual(SettingsCopy.structuredHistoryRetention.label, "Rules, tasks, requests, passes")
        XCTAssertEqual(SettingsCopy.structuredHistoryRetention.period, "12 months")
        XCTAssertEqual(SettingsCopy.freeTextRetention.label, "Request reasons and notes")
        XCTAssertEqual(SettingsCopy.freeTextRetention.period, "90 days")
        XCTAssertEqual(SettingsCopy.auditLogRetention.period, "12 months")
        // 90 days belongs to free-text only.
        XCTAssertNotEqual(SettingsCopy.structuredHistoryRetention.period, SettingsCopy.freeTextRetention.period)
        XCTAssertFalse(SettingsCopy.structuredHistoryRetention.label.lowercased().contains("reason"))
        XCTAssertTrue(SettingsCopy.privacyFooter.contains("subject to final legal review"))
        for sentence in allCopy {
            XCTAssertFalse(sentence.lowercased().contains("lawful basis"), "No lawful basis is invented: \(sentence)")
        }
    }

    func testNotificationsCopyKeepsPushContentGeneric() {
        XCTAssertEqual(
            SettingsCopy.notificationsPrivacyNote,
            "Notifications show a name and an event only. Reasons, notes and details open after you unlock and open Themis."
        )
        XCTAssertEqual(SettingsDemoData.notificationPreferences.map(\.title), ["Tasks sent for review", "Requests", "Protection problems", "Billing"])
        XCTAssertTrue(SettingsDemoData.notificationPreferences.allSatisfy(\.isOn))
    }

    @MainActor
    func testNotificationTogglesAreLocalAndRequestNoPermission() {
        let viewModel = model(.owner)
        viewModel.notifications[1].isOn = false
        XCTAssertFalse(viewModel.notifications[1].isOn)
        XCTAssertEqual(viewModel.notifications.map(\.id), ["tasks", "requests", "protection", "billing"])
    }

    // MARK: Support and safeguarding

    // TEST 17
    func testSupportCannotEditRules() {
        XCTAssertFalse(SupportBoundary.canPerform(.editRules))
    }

    // TEST 18
    func testSupportCannotApproveOrRejectTasksOrRequests() {
        XCTAssertFalse(SupportBoundary.canPerform(.approveOrRejectTask))
        XCTAssertFalse(SupportBoundary.canPerform(.approveOrDeclineRequest))
    }

    // TEST 19
    func testSupportCannotGrantOrRevokeFreePasses() {
        XCTAssertFalse(SupportBoundary.canPerform(.grantFreePass))
        XCTAssertFalse(SupportBoundary.canPerform(.revokeFreePass))
    }

    // TEST 20
    func testSupportCannotRewriteBillingState() {
        XCTAssertFalse(SupportBoundary.canPerform(.rewriteBillingState))
    }

    func testSupportMayOnlyDiagnoseGuideAndReceiveMessages() {
        XCTAssertEqual(
            SupportBoundary.allowed,
            [.diagnoseDevice, .requestSafeResync, .accountRecoveryHelp, .restorePurchaseGuidance, .receiveSupportMessage]
        )
        XCTAssertFalse(SupportBoundary.canPerform(.changeRestrictions))
        XCTAssertFalse(SupportBoundary.canPerform(.impersonateParent))
        for capability in SupportCapability.allCases where !SupportBoundary.allowed.contains(capability) {
            XCTAssertFalse(SupportBoundary.canPerform(capability))
        }
        XCTAssertEqual(
            SettingsCopy.supportIntro,
            "Support can check your devices and guide you through fixes. Support can’t change your rules, approve requests or make decisions for your family."
        )
    }

    func testSupportStatesMatchTheApprovedFrames() {
        XCTAssertEqual(SettingsCopy.resyncSheetTitle("Sam’s iPhone"), "Ask support to resync Sam’s iPhone?")
        XCTAssertEqual(SettingsCopy.resyncSheetLine("Sam’s iPhone"), "Sam’s iPhone re-applies the rules you already set. Your rules don’t change.")
        XCTAssertEqual(SettingsCopy.resyncRequestedNote, "Support’s action is logged. It restores what you set; it never makes a new decision.")
        XCTAssertEqual(SettingsCopy.supportContactNote, "Support sees device and sync status for this issue only. They don’t see your children’s requests or notes.")
        XCTAssertEqual(SettingsCopy.supportSentNote, "We’ll reply in the Themis app and by email.")
        XCTAssertEqual(SettingsDemoData.sampleSupportMessage, "Bedtime didn’t start on Sam’s iPhone last night.")
    }

    @MainActor
    func testResyncIsARequestAndNotLabelledApplying() async {
        let viewModel = model(.owner)
        let requested = await viewModel.requestResync(childID: "sam")
        XCTAssertTrue(requested)
        XCTAssertTrue(viewModel.resyncRequested.contains("sam"))
        XCTAssertEqual(ThemisStatus(.applying, label: "Requested").label, "Requested")
    }

    @MainActor
    func testBillingRowInSupportIsOwnerOnlyForAGuardian() {
        XCTAssertFalse(model(.guardian).can(.manageSubscription))
    }

    // TEST 21
    func testSafeguardingCopyInventsNoContactIdentity() {
        XCTAssertFalse(SafeguardingPlaceholder.hasOperationalContact)
        let copy = [
            SettingsCopy.safeguardingTitle, SettingsCopy.safeguardingEmergency, SettingsCopy.safeguardingBody,
            SettingsCopy.safeguardingPrivacy, SettingsCopy.safeguardingAction, SettingsCopy.safeguardingPending
        ]
        for sentence in copy {
            XCTAssertNil(sentence.rangeOfCharacter(from: .decimalDigits), "A number (phone, hours or time) appears: \(sentence)")
            XCTAssertFalse(sentence.contains("@"), sentence)
            XCTAssertFalse(sentence.lowercased().contains("http"), sentence)
            XCTAssertFalse(sentence.lowercased().contains("www"), sentence)
            XCTAssertFalse(sentence.lowercased().contains("within"), "No response-time promise: \(sentence)")
            XCTAssertFalse(sentence.lowercased().contains("officer"), "No named role invented: \(sentence)")
        }
        XCTAssertEqual(SettingsCopy.safeguardingEmergency, "If someone is in immediate danger, contact emergency services now.")
        XCTAssertEqual(SettingsCopy.safeguardingPending, "Procedure and contact details to be confirmed before launch.")
        XCTAssertEqual(SettingsCopy.safeguardingBody, "This goes to a trained safeguarding reviewer, separate from ordinary support.")
    }

    // MARK: ST-009 Subscription boundary

    // TEST 22
    func testSubscriptionIsOnlyASettingsIntegrationBoundary() {
        let boundary = SettingsDemoData.subscriptionBoundary
        XCTAssertEqual(boundary.statusLabel, "Active")
        XCTAssertTrue(boundary.requiresOwner)
        XCTAssertEqual(Mirror(reflecting: boundary).children.compactMap(\.label), ["statusLabel", "requiresOwner"])

        let owner = rows(SettingsPresentation.rootSections(household: household, viewerRole: .owner))
        XCTAssertEqual(owner.first { $0.id == "subscription" }?.route, .external(.subscriptionSettings))
        XCTAssertEqual(SettingsExternalDestination.subscriptionSettings.screenID, "B-002")

        // The only Subscription-related destination Settings knows is the hand-off; B-001 to B-008 are not here.
        let destinations: [SettingsExternalDestination] = [
            .subscriptionSettings, .fixProtection(childID: "sam"), .pairDevice(childID: "sam"), .childTransparency(childID: "sam"), .welcome
        ]
        XCTAssertEqual(destinations.filter { $0.screenID.hasPrefix("B-") }.map(\.screenID), ["B-002"])
    }

    // MARK: Ownership

    // TEST 23
    func testTransferTargetMustAlreadyBeAnAcceptedGuardian() {
        XCTAssertEqual(household.acceptedGuardian?.name, "Alex")
        XCTAssertNotNil(try? household.transferringOwnership(to: "alex").get())
        XCTAssertEqual(pendingInvite.transferringOwnership(to: "alex"), .failure(.noAcceptedGuardian), "An unaccepted invite cannot receive ownership")
        XCTAssertEqual(household.transferringOwnership(to: "someone-new"), .failure(.targetNotAnAcceptedGuardian))
        XCTAssertEqual(household.transferringOwnership(to: "sarah"), .failure(.targetIsAlreadyOwner))
    }

    // TEST 24
    func testTransferCannotTargetAChildOrTeen() {
        XCTAssertEqual(household.transferringOwnership(to: "sam"), .failure(.targetIsAChild))
        XCTAssertEqual(household.transferringOwnership(to: "maya"), .failure(.targetIsAChild))
        XCTAssertEqual(noGuardian.transferringOwnership(to: "sam"), .failure(.targetIsAChild))
    }

    // TEST 25
    func testTransferNeverCreatesAZeroOwnerState() {
        XCTAssertEqual(household.ownerCount, 1)
        for target in ["alex", "sarah", "sam", "maya", "someone-new"] {
            switch household.transferringOwnership(to: target) {
            case let .success(updated):
                XCTAssertEqual(updated.ownerCount, 1)
                XCTAssertEqual(updated.children, household.children)
            case .failure:
                break
            }
        }
        // A failed transfer leaves the household as it was.
        XCTAssertEqual(household.owner.id, "sarah")
        // Exactly one member holds the Owner role after a successful transfer.
        let updated = try? household.transferringOwnership(to: "alex").get()
        let owners = [updated?.owner, updated?.acceptedGuardian].compactMap { $0 }.filter { $0.role == .owner }
        XCTAssertEqual(owners.count, 1)
    }

    // TEST 26
    func testConfirmedTransferMakesAlexOwnerAndSarahGuardian() throws {
        let updated = try household.transferringOwnership(to: "alex").get()
        XCTAssertEqual(updated.owner.id, "alex")
        XCTAssertEqual(updated.owner.role, .owner)
        XCTAssertEqual(updated.acceptedGuardian?.id, "sarah")
        XCTAssertEqual(updated.acceptedGuardian?.role, .guardian)
        XCTAssertEqual(updated.role(of: "alex"), .owner)
        XCTAssertEqual(updated.role(of: "sarah"), .guardian)
        XCTAssertEqual(updated.name, "Sarah’s family")
    }

    @MainActor
    func testTransferThroughTheViewModelIsAtomicAndPresentationOnly() async {
        let viewModel = model(.owner)
        let transferred = await viewModel.transferOwnership()
        XCTAssertTrue(transferred)
        XCTAssertEqual(viewModel.household.owner.name, "Alex")
        XCTAssertEqual(viewModel.household.acceptedGuardian?.name, "Sarah")
        XCTAssertEqual(viewModel.viewerRole, .guardian, "Sarah is now a Guardian")
        XCTAssertEqual(viewModel.ownershipTransfer, .completed)
    }

    func testOwnershipCopyMatchesTheApprovedFrames() {
        XCTAssertEqual(SettingsCopy.transferTitle("Alex"), "Make Alex the Owner?")
        XCTAssertEqual(SettingsCopy.transferBody("Alex"), "Alex becomes the Owner and you become a Guardian, in one step.")
        XCTAssertEqual(SettingsCopy.transferLoses, "Subscription, Guardian management, deleting the household")
        XCTAssertEqual(SettingsCopy.transferKeeps, "Approvals, Free Passes, rules, devices")
        XCTAssertEqual(SettingsCopy.transferSheetTitle("Alex"), "Transfer ownership to Alex?")
        XCTAssertEqual(SettingsCopy.transferSheetLine("Alex"), "This takes effect straight away. Only Alex can transfer it back.")
        XCTAssertEqual(SettingsCopy.transferredTitle("Alex"), "Alex is now the Owner")
        XCTAssertEqual(SettingsCopy.transferredNote(household: "Sarah’s family"), "You’re a Guardian in Sarah’s family.")
        XCTAssertEqual(SettingsCopy.leaveNowTitle(household: "Sarah’s family"), "Leave Sarah’s family?")
        XCTAssertEqual(SettingsCopy.leaveNowLine("Alex"), "Alex keeps managing the household. Anything waiting for you goes to Alex.")
    }

    // TEST 27
    func testOwnerLeaveSupportsExactlyTransferThenLeaveOrDelete() {
        XCTAssertEqual(OwnerExitRoute.allCases, [.transferThenLeave, .deleteHousehold])
        XCTAssertEqual(household.availableOwnerExitRoutes, [.transferThenLeave, .deleteHousehold])
        XCTAssertEqual(SettingsCopy.leaveTitle, "A household always needs an Owner")
        XCTAssertEqual(SettingsCopy.leaveChoose, "To leave, choose one:")
        XCTAssertEqual(SettingsCopy.leaveRule, "Ownership can’t go to a child, and a household can’t be left without an Owner.")
    }

    // TEST 28
    @MainActor
    func testNoGuardianStateCannotTransferOwnership() async {
        XCTAssertEqual(noGuardian.availableOwnerExitRoutes, [.deleteHousehold])
        XCTAssertEqual(noGuardian.transferringOwnership(to: "alex"), .failure(.noAcceptedGuardian))
        XCTAssertEqual(pendingInvite.availableOwnerExitRoutes, [.deleteHousehold], "A pending invite is not an accepted Guardian")
        let viewModel = model(.ownerNoGuardian)
        let transferred = await viewModel.transferOwnership()
        XCTAssertFalse(transferred)
        XCTAssertEqual(viewModel.household.owner.id, "sarah")
        XCTAssertEqual(SettingsCopy.noGuardianInfo, "There’s no Guardian to transfer to yet.")
        XCTAssertEqual(SettingsCopy.inviteFirstTitle, "Invite a Guardian first")
        XCTAssertEqual(SettingsCopy.inviteFirstSubtitle, "Once they accept, transfer ownership, then leave")
    }

    @MainActor
    func testOnlyAGuardianCanLeaveAndTheOwnerCannotJustLeave() async {
        let owner = model(.owner)
        let ownerLeft = await owner.leaveHousehold()
        XCTAssertFalse(ownerLeft, "An Owner leaves by transferring ownership or deleting")
        let former = model(.ownerAfterTransfer)
        let formerLeft = await former.leaveHousehold()
        XCTAssertTrue(formerLeft)
    }

    // MARK: ST-011 Delete household

    // TEST 29
    func testDeleteHouseholdIsOwnerOnly() {
        XCTAssertTrue(SettingsCapability.ownerOnly.contains(.deleteHousehold))
        XCTAssertTrue(SettingsRole.owner.can(.deleteHousehold))
        XCTAssertFalse(SettingsRole.guardian.can(.deleteHousehold))
    }

    // TEST 30
    @MainActor
    func testDeleteHouseholdRequiresTypedDelete() async {
        XCTAssertEqual(DeleteConfirmation.phrase, "DELETE")
        XCTAssertTrue(DeleteConfirmation.isSatisfied(by: "DELETE"))
        for wrong in ["", "delete", "Delete", "DELET", "DELETE IT", "yes"] {
            XCTAssertFalse(DeleteConfirmation.isSatisfied(by: wrong), wrong)
        }
        let viewModel = model(.owner)
        let refused = await viewModel.deleteHousehold(typed: "delete")
        XCTAssertFalse(refused)
        XCTAssertEqual(viewModel.deletion, .idle)
        let accepted = await viewModel.deleteHousehold(typed: "DELETE")
        XCTAssertTrue(accepted)
        XCTAssertEqual(viewModel.deletion, .deletedPresentationOnly)
    }

    // TEST 31
    func testDeleteCopyWarnsThatTheSubscriptionIsNotCancelledAutomatically() {
        XCTAssertEqual(
            SettingsCopy.deleteSubscriptionNote,
            "Your App Store subscription isn’t cancelled automatically. Manage it in the App Store."
        )
        XCTAssertEqual(SettingsCopy.deleteTitle(household: "Sarah’s family"), "Delete Sarah’s family?")
        XCTAssertEqual(
            SettingsCopy.deleteBody(childNames: ["Sam", "Maya"]),
            "This deletes all rules, history and devices, and removes Themis restrictions from Sam’s and Maya’s iPhones. It can’t be undone."
        )
        XCTAssertEqual(SettingsCopy.deleteFieldLabel, "Type DELETE to confirm")
        XCTAssertEqual(SettingsCopy.deleteFinalTitle, "Delete everything now?")
        XCTAssertEqual(
            SettingsCopy.deleteFinalLine(childNames: ["Sam", "Maya"]),
            "Sam and Maya will see that Themis is no longer set up on their iPhones."
        )
        XCTAssertEqual(
            SettingsCopy.deletedNote(childNames: ["Sam", "Maya"]),
            "Restrictions are being removed from Sam’s and Maya’s iPhones as they connect."
        )
    }

    func testNaturalListCopyHelpers() {
        XCTAssertEqual(SettingsCopy.naturalList(["Sam"]), "Sam")
        XCTAssertEqual(SettingsCopy.naturalList(["Sam", "Maya", "Leo"]), "Sam, Maya and Leo")
        XCTAssertEqual(SettingsCopy.possessiveIPhones(["Sam"]), "Sam’s iPhone")
        XCTAssertEqual(SettingsCopy.possessiveIPhones(["Sam", "Maya", "Leo"]), "Sam’s, Maya’s and Leo’s iPhones")
    }

    // MARK: ST-012 Account

    // TEST 33
    func testSignOutPresentationDoesNotClaimAuthOrSessionRevocation() {
        XCTAssertEqual(SettingsCopy.signOutTitle, "Sign out of Themis?")
        XCTAssertEqual(
            SettingsCopy.signOutLine(otherParent: "Alex"),
            "Rules keep running on your children’s iPhones. Alex still gets approvals."
        )
        XCTAssertEqual(SettingsCopy.signOutLine(otherParent: nil), "Rules keep running on your children’s iPhones.")
        for sentence in [SettingsCopy.signOutTitle, SettingsCopy.signOutLine(otherParent: "Alex")] {
            for word in ["revoke", "revoked", "token", "session", "invalidated", "signed out everywhere"] {
                XCTAssertFalse(sentence.lowercased().contains(word), sentence)
            }
        }
    }

    // MARK: Guardian accessibility and honesty

    // TEST 34
    func testGuardianOwnerOnlyRowsExposeAnOwnerOnlyMeaning() {
        let guardianRows = SettingsPresentation.rootSections(household: household, viewerRole: .guardian)
        let locked = rows(guardianRows).filter(\.isOwnerOnlyLocked)
        XCTAssertEqual(locked.map(\.id), ["subscription", "guardian-ownership"])
        for row in locked {
            XCTAssertTrue(row.accessibilityDescription.contains("Owner only"), row.accessibilityDescription)
            XCTAssertTrue(row.accessibilityHint?.contains("Owner only") ?? false)
            XCTAssertEqual(row.value, "Owner only", "Said in words, not only by dimming")
            XCTAssertNil(row.route, "Not actionable")
        }
        // A row that is not locked says nothing about Owner only.
        XCTAssertNil(rows(guardianRows).first { $0.id == "household" }?.accessibilityHint)
    }

    // TEST 35
    @MainActor
    func testNoStateClaimsARealMutationFromATap() async {
        let repository = MockSettingsRepository()
        XCTAssertFalse(repository.performsRealMutations)
        let actions: [SettingsAction] = [
            .inviteGuardian(contact: "a@b.c"), .cancelGuardianInvite, .removeGuardian, .addChild(NewChildDraft(firstName: "Leo", experience: .child)),
            .saveChild(id: "sam", firstName: "Sam", experience: .child), .removeChild(id: "sam"), .requestDeviceRemoval(childID: "sam"),
            .requestResync(childID: "sam"), .sendSupportMessage("hello"), .transferOwnership(toID: "alex"), .leaveHousehold,
            .deleteHousehold, .signOut
        ]
        for action in actions {
            let outcome = await repository.perform(action)
            XCTAssertEqual(outcome, .accepted(isPresentationOnly: true), "\(action)")
        }
        // The deletion state is named for what it is.
        XCTAssertEqual(HouseholdDeletionState.deletedPresentationOnly, .deletedPresentationOnly)
    }

    @MainActor
    func testARejectedActionChangesNothing() async {
        struct RejectingRepository: SettingsRepository {
            func state(for scenario: SettingsScenario) async throws -> SettingsPresentationState { SettingsDemoData.state(for: scenario) }
            func perform(_ action: SettingsAction) async -> SettingsActionOutcome { .rejected(reason: "Offline") }
        }
        let viewModel = SettingsViewModel(repository: RejectingRepository(), state: SettingsDemoData.state(for: .owner))
        let before = viewModel.household
        let removed = await viewModel.removeGuardian()
        XCTAssertFalse(removed)
        XCTAssertEqual(viewModel.household, before)
        XCTAssertEqual(viewModel.lastRefusal, "Offline")
        let requested = await viewModel.requestDeviceRemoval(childID: "sam")
        XCTAssertFalse(requested)
        XCTAssertEqual(viewModel.removal(for: "sam"), .idle)
        let deleted = await viewModel.deleteHousehold(typed: "DELETE")
        XCTAssertFalse(deleted)
        XCTAssertEqual(viewModel.deletion, .idle)
    }

    // MARK: ST-002 to ST-004 frames

    func testHouseholdItemsMatchTheApprovedFrames() {
        let owner = SettingsPresentation.householdItems(household: household, viewerRole: .owner)
        XCTAssertEqual(owner.map(\.key), ["Name", "Owner", "Guardian", "Children"])
        XCTAssertEqual(owner.map(\.value), ["Sarah’s family", "Sarah (you)", "Alex", "Sam (Child), Maya (Teen)"])

        let guardian = SettingsPresentation.householdItems(household: household, viewerRole: .guardian)
        XCTAssertEqual(guardian.map(\.key), ["Owner", "Guardian", "Children"])
        XCTAssertEqual(guardian.map(\.value), ["Sarah", "Alex (you)", "Sam (Child), Maya (Teen)"])
        XCTAssertEqual(
            SettingsCopy.ownerOnlyBanner(ownerName: "Sarah"),
            "Only Sarah can transfer ownership, manage the Guardian or delete the household."
        )
    }

    func testOwnerHouseholdOffersOwnershipRowsAndGuardianDoesNot() {
        let ownership = SettingsPresentation.ownershipRows(household: household)
        XCTAssertEqual(ownership.map(\.title), ["Transfer ownership", "Leave household"])
        XCTAssertEqual(ownership.first?.subtitle, "To Alex")
        XCTAssertEqual(ownership.first?.route, .transferOwnership)
        XCTAssertEqual(ownership.last?.route, .leaveHousehold)
        // Without an accepted Guardian, "Transfer ownership" points to inviting one first.
        XCTAssertEqual(SettingsPresentation.ownershipRows(household: noGuardian).first?.route, .inviteGuardian)
    }

    func testGuardianAndInviteCopyMatchTheApprovedFrames() {
        XCTAssertEqual(SettingsCopy.guardianCan, "Approve tasks and requests, give Free Passes, edit rules, manage devices")
        XCTAssertEqual(
            SettingsCopy.guardianCannot,
            "Change the subscription, invite or remove the Guardian, transfer ownership, or delete the household"
        )
        XCTAssertEqual(SettingsCopy.removeGuardianTitle("Alex"), "Remove Alex as Guardian?")
        XCTAssertEqual(SettingsCopy.removeGuardianLine("Alex"), "Anything waiting for Alex stays waiting for you.")
        XCTAssertEqual(SettingsCopy.inviteFieldLabel, "Their email or phone number")
        XCTAssertEqual(SettingsCopy.inviteSentNote, "A pending invite doesn’t count as a household member until it’s accepted.")
        XCTAssertEqual(SettingsDemoData.alex.joined, "3 Sep")
    }

    func testRemovingTheGuardianDoesNotImplyApprovalsAreCancelled() {
        let line = SettingsCopy.removeGuardianLine("Alex").lowercased()
        XCTAssertTrue(line.contains("stays waiting"))
        for word in ["cancel", "cleared", "removed", "deleted"] {
            XCTAssertFalse(line.contains(word), line)
        }
    }

    func testInviteDisplayNameComesFromTheContactOnly() {
        XCTAssertEqual(MockSettingsRepository.displayName(forContact: "alex@example.com"), "Alex")
        XCTAssertEqual(MockSettingsRepository.displayName(forContact: "  "), "Guardian")
    }

    // MARK: Navigation

    @MainActor
    func testNavigatorPushReplacePopAndRoot() {
        let navigator = SettingsNavigator()
        navigator.push(.childrenAndDevices)
        navigator.push(.device("sam"))
        navigator.push(.leaveHousehold)
        XCTAssertEqual(navigator.routes, [.childrenAndDevices, .device("sam"), .leaveHousehold])
        navigator.replaceTop(with: .deleteHousehold)
        XCTAssertEqual(navigator.route(at: 2), .deleteHousehold)
        navigator.pop(toRoute: .childrenAndDevices)
        XCTAssertEqual(navigator.routes, [.childrenAndDevices])
        navigator.pop(to: 0)
        XCTAssertTrue(navigator.routes.isEmpty)
        navigator.push(.account)
        navigator.popToRoot()
        XCTAssertTrue(navigator.routes.isEmpty)
        XCTAssertNil(navigator.route(at: 3))
    }

    @MainActor
    func testExternalDestinationsUseTheMainLaneHookOrAPlaceholder() {
        var opened: [SettingsExternalDestination] = []
        let hooked = SettingsNavigator(integration: SettingsIntegration(onExternal: { opened.append($0) }))
        hooked.open(.subscriptionSettings)
        XCTAssertEqual(opened, [.subscriptionSettings])
        XCTAssertTrue(hooked.routes.isEmpty, "A connected hook handles it; nothing is pushed")

        let standalone = SettingsNavigator()
        standalone.open(.fixProtection(childID: "sam"))
        XCTAssertEqual(standalone.routes, [.external(.fixProtection(childID: "sam"))])
        XCTAssertEqual(SettingsExternalDestination.fixProtection(childID: "sam").screenID, "P-031")
        XCTAssertEqual(SettingsExternalDestination.pairDevice(childID: "sam").screenID, "P-009")
        XCTAssertEqual(SettingsExternalDestination.childTransparency(childID: "sam").screenID, "C-013")
        XCTAssertEqual(SettingsExternalDestination.welcome.screenID, "P-002")
    }

    func testEveryScenarioHasExactlyOneOwner() {
        for scenario in SettingsScenario.allCases {
            let state = SettingsDemoData.state(for: scenario)
            XCTAssertEqual(state.household.ownerCount, 1, "\(scenario)")
            XCTAssertNotNil(state.household.role(of: state.viewerID), "\(scenario)")
        }
        XCTAssertEqual(SettingsDemoData.state(for: .ownerAfterTransfer).household.owner.name, "Alex")
        XCTAssertEqual(SettingsDemoData.state(for: .guardian).viewerID, "alex")
    }

    // MARK: Roles

    func testSharedCapabilitiesBelongToBothRolesAndOwnerOnlyOnesDoNot() {
        let shared: [SettingsCapability] = [
            .addChild, .editChildProfile, .addChildDevice, .removeChildDevice,
            .viewReporting, .editRules, .grantFreePass, .approveTasks, .changeSchoolAllowlist
        ]
        for capability in shared {
            XCTAssertTrue(SettingsRole.owner.can(capability), "\(capability)")
            XCTAssertTrue(SettingsRole.guardian.can(capability), "\(capability)")
        }
        XCTAssertEqual(
            SettingsCapability.ownerOnly,
            [.inviteGuardian, .removeGuardian, .manageSubscription, .transferOwnership, .deleteHousehold]
        )
        for capability in SettingsCapability.ownerOnly {
            XCTAssertFalse(SettingsRole.guardian.can(capability), "\(capability)")
        }
    }
}
