import XCTest
@testable import ThemisFamily

final class ActivityTests: XCTestCase {
    private let snapshot = ActivityDemoData.snapshot

    private func event(_ id: String) throws -> ActivityEvent {
        try XCTUnwrap(snapshot.event(id: id), "Missing demo event \(id)")
    }

    /// Every sentence the Activity demo can show.
    private var allDemoCopy: [String] {
        var copy: [String] = [ActivityCopy.overviewIntro, ActivityCopy.overviewFooter, ActivityCopy.emptyTitle,
                              ActivityCopy.emptyMessage, ActivityCopy.protectionFooter, ActivityCopy.timingExplanation]
        for event in snapshot.events {
            copy.append(contentsOf: [event.title, event.outcome.label])
            copy.append(contentsOf: [event.detail, event.resolverText].compactMap { $0 })
        }
        copy.append(contentsOf: snapshot.protectionNow.flatMap { [$0.status.label, $0.evidence] })
        copy.append(contentsOf: ActivityChild.allCases.map(ActivityCopy.appUsageNote(for:)))
        for state in AppleScreenTimeReportState.allCases {
            copy.append(contentsOf: AppleScreenTimeCopy.allCopy(for: state))
        }
        return copy
    }

    // TEST 1
    func testActivitySupportsExactlyTheThemisOwnedCategories() {
        XCTAssertEqual(
            Set(ActivityCategory.allCases.map(\.rawValue)),
            ["rule", "task", "request", "temporaryAccess", "protection", "session"]
        )
        XCTAssertEqual(ActivityCategory.allCases.count, 6)
    }

    // TEST 2
    func testCanonicalDemoDataContainsSamAndMaya() {
        XCTAssertEqual(Set(snapshot.events.map(\.child)), [.sam, .maya])
        XCTAssertEqual(ActivityChild.sam.title, "Sam · Child")
        XCTAssertEqual(ActivityChild.maya.title, "Maya · Teen")
        XCTAssertEqual(snapshot.protectionNow.map(\.child), [.sam, .maya])
    }

    // TEST 3
    func testThemisActivityCoversEveryCategoryAndHasNoRawAppleUsageRecords() {
        XCTAssertEqual(Set(snapshot.events.map(\.category)), Set(ActivityCategory.allCases))

        let forbiddenFieldNames = ["usage", "bundle", "domain", "website", "minutesused", "apps"]
        let reflected = [
            Mirror(reflecting: snapshot.events[0]),
            Mirror(reflecting: snapshot),
            Mirror(reflecting: snapshot.protectionNow[0])
        ]
        for mirror in reflected {
            for label in mirror.children.compactMap(\.label) {
                for forbidden in forbiddenFieldNames {
                    XCTAssertFalse(label.lowercased().contains(forbidden), "Field \(label) looks like Apple usage data")
                }
            }
        }
        // Apple report availability is not part of the Themis-owned snapshot.
        XCTAssertFalse(Mirror(reflecting: snapshot).children.contains { $0.value is AppleScreenTimeReportState })
    }

    // TEST 4
    func testAppleScreenTimeStateCarriesNoUsagePayload() {
        XCTAssertEqual(Set(AppleScreenTimeReportState.allCases.map(\.rawValue)), ["systemOwnedReportArea", "unavailable"])
        for state in AppleScreenTimeReportState.allCases {
            XCTAssertTrue(Mirror(reflecting: state).children.isEmpty, "\(state) must not carry a payload")
        }
        // The T-006 copy contains no figures, so no usage numbers can be drawn from it.
        for state in AppleScreenTimeReportState.allCases {
            for sentence in AppleScreenTimeCopy.allCopy(for: state) {
                XCTAssertNil(sentence.rangeOfCharacter(from: .decimalDigits), "T-006 copy contains a figure: \(sentence)")
            }
        }
    }

    // TEST 5
    func testT006CopyStatesThemisDoesNotReceiveStoreOrExportAppleUsageData() {
        let privacy = AppleScreenTimeCopy.privacy
        XCTAssertEqual(privacy, "Themis does not receive, store or export the underlying app and website usage data.")
        for state in AppleScreenTimeReportState.allCases {
            XCTAssertTrue(AppleScreenTimeCopy.allCopy(for: state).contains(privacy), "\(state) must keep the privacy explanation")
        }
        XCTAssertEqual(
            AppleScreenTimeCopy.reportExpectation,
            "When available, Apple’s Screen Time report appears here."
        )
    }

    // TEST 6
    func testUnavailableStateIsNeitherPermanentNorAPromiseOfLaterAvailability() {
        XCTAssertEqual(AppleScreenTimeCopy.unavailableMessage, "Screen Time report isn’t available on this device right now.")
        XCTAssertEqual(
            AppleScreenTimeCopy.unavailableSupport,
            "Your Themis activity history still shows rule, task, request, temporary-access and protection outcomes."
        )
        let unavailable = AppleScreenTimeCopy.allCopy(for: .unavailable).joined(separator: " ").lowercased()
        for phrase in ["permanent", "never", "forever", "will be available", "will become", "soon", "later", "coming", "yet", "we’ll fix", "themis can fix", "try again"] {
            XCTAssertFalse(unavailable.contains(phrase), "Unavailable copy must not say “\(phrase)”")
        }
    }

    // TEST 7
    func testTimingUnverifiedUsesTheExactOutcomeAndNeverOnTimeOrLate() throws {
        let timing = try event("sam-homework-timing-unverified")
        XCTAssertEqual(timing.outcome.label, "Approved, timing unverified")
        XCTAssertEqual(timing.outcome, .approvedTimingUnverified)
        XCTAssertEqual(timing.resolver, "Sarah")
        XCTAssertEqual(timing.detail, "Themis could not verify which submission time should be trusted.")

        let text = [timing.title, timing.outcome.label, timing.detail ?? ""].joined(separator: " ").lowercased()
        XCTAssertFalse(text.contains("on time"))
        XCTAssertNil(text.range(of: "\\blate\\b", options: .regularExpression))
        XCTAssertNotEqual(timing.outcome, .approved)
    }

    // TEST 8
    func testTimingUnverifiedExampleKeepsBothTimes() throws {
        let timing = try XCTUnwrap(try event("sam-homework-timing-unverified").timing)
        XCTAssertEqual(timing.claimedText, "5:58 PM")
        XCTAssertEqual(timing.serverReceivedText, "6:02 PM")
        // No other event carries timing evidence.
        XCTAssertEqual(snapshot.events.filter { $0.timing != nil }.count, 1)
    }

    // TEST 9
    func testFocusSessionDescribesSystemEvidenceHonestly() throws {
        let focus = try event("maya-focus-30")
        XCTAssertEqual(focus.category, .session)
        XCTAssertEqual(focus.title, "30-minute Focus Session completed")
        XCTAssertEqual(focus.child, .maya)
        for sentence in allDemoCopy {
            XCTAssertFalse(sentence.localizedCaseInsensitiveContains("focused for"), "Overclaims a real-world activity: \(sentence)")
        }
    }

    // TEST 10
    func testProtectionHistoryRepresentsAllFiveApprovedStates() {
        let protectionEvents = snapshot.events.filter { $0.category == .protection }
        XCTAssertEqual(
            Set(protectionEvents.map { $0.outcome.kind }),
            [.protected, .syncPending, .deviceOffline, .needsAttention, .protectionUnavailable]
        )
        // Each is the existing project status, never a new one.
        let labels = Set(protectionEvents.map { $0.outcome.label })
        XCTAssertEqual(labels, ["Protected", "Sync pending", "Device offline", "Needs attention", "Protection unavailable"])
    }

    func testProtectedIsNeverShownWithoutEvidenceWording() {
        for now in snapshot.protectionNow {
            XCTAssertFalse(now.evidence.isEmpty)
        }
        let sam = snapshot.protectionNow.first { $0.child == .sam }
        XCTAssertEqual(sam?.status, .protected)
        XCTAssertEqual(sam?.evidence, "Verified 2 min ago")
        let maya = snapshot.protectionNow.first { $0.child == .maya }
        XCTAssertEqual(maya?.status.kind, .syncPending)
        XCTAssertEqual(maya?.evidence, "Change waiting to reach device")
        for event in snapshot.events where event.outcome == .protected {
            XCTAssertTrue(event.detail?.hasPrefix("Verified") ?? false, "Protected event without evidence")
        }
    }

    // TEST 11
    func testActivitySortsNewestFirstDeterministically() {
        let sorted = snapshot.events(for: .all)
        XCTAssertEqual(sorted.count, snapshot.events.count)
        XCTAssertEqual(sorted.first?.id, "sam-homework-deadline-met")
        XCTAssertEqual(sorted.last?.id, "maya-protection-offline")
        for (newer, older) in zip(sorted, sorted.dropFirst()) {
            XCTAssertGreaterThanOrEqual(newer.occurredAt, older.occurredAt)
        }
        XCTAssertEqual(sorted.map(\.id), snapshot.events(for: .all).map(\.id))

        // Equal times fall back to id order.
        let tied = [
            ActivityEvent(id: "b", child: .sam, occurredAt: ActivityDemoData.referenceDate, category: .rule, title: "B", outcome: .approved, detail: nil, resolver: nil),
            ActivityEvent(id: "a", child: .sam, occurredAt: ActivityDemoData.referenceDate, category: .rule, title: "A", outcome: .approved, detail: nil, resolver: nil)
        ]
        XCTAssertEqual(ActivitySnapshot(referenceDate: ActivityDemoData.referenceDate, events: tied, protectionNow: []).events(for: .all).map(\.id), ["a", "b"])
    }

    func testDayGroupsUseTodayYesterdayAndWeekdays() {
        let groups = snapshot.dayGroups(for: snapshot.events(for: .all))
        XCTAssertEqual(groups.map(\.title), ["Today", "Yesterday", "Monday", "Sunday", "Saturday"])
        XCTAssertEqual(groups.first?.events.count, 6)
        XCTAssertEqual(groups.map { $0.events.count }.reduce(0, +), snapshot.events.count)
    }

    // TEST 12
    func testScopeFilteringIsDeterministic() {
        let all = snapshot.events(for: .all)
        let sam = snapshot.events(for: .sam)
        let maya = snapshot.events(for: .maya)

        XCTAssertEqual(all.count, 15)
        XCTAssertEqual(sam.count, 10)
        XCTAssertEqual(maya.count, 5)
        XCTAssertTrue(sam.allSatisfy { $0.child == .sam })
        XCTAssertTrue(maya.allSatisfy { $0.child == .maya })
        XCTAssertEqual(Set(sam.map(\.id)).union(maya.map(\.id)), Set(all.map(\.id)))
        XCTAssertEqual(ActivityScope.allCases.map(\.title), ["All", "Sam", "Maya"])

        let samRequests = snapshot.events(for: .sam, categories: [.request])
        XCTAssertEqual(samRequests.map(\.id), ["sam-roblox-plus30", "sam-youtube-plus15"])
    }

    // TEST 13
    func testRequestHistoryRepresentsApprovedPartiallyApprovedAndDeclined() throws {
        let requests = snapshot.events(for: .all, categories: [.request])
        XCTAssertEqual(requests.count, 3)

        XCTAssertEqual(try event("maya-instagram-plus15").outcome, .approved)
        XCTAssertEqual(try event("sam-roblox-plus30").outcome, .partiallyApproved)
        XCTAssertEqual(try event("sam-youtube-plus15").outcome, .declined)
        XCTAssertEqual(try event("sam-roblox-plus30").detail, "Requested +30 min · Approved +15 min")
        XCTAssertEqual(Set(requests.map(\.outcome.label)), ["Approved", "Partially approved", "Declined"])
    }

    // TEST 14
    func testNoActivityCopyClaimsAccessToMessagesSearchHistoryMinuteLevelOrRawAppleData() {
        let forbidden = [
            "message content", "messages", "chat", "search history", "browsing history",
            "browsing/search", "minute-by-minute", "minute by minute", "raw apple",
            "screen time data", "visited", "location"
        ]
        for sentence in allDemoCopy {
            let lowered = sentence.lowercased()
            for phrase in forbidden {
                XCTAssertFalse(lowered.contains(phrase), "Copy claims or mentions “\(phrase)”: \(sentence)")
            }
        }
    }

    // MARK: Supporting checks

    func testOutcomesAlwaysCarryGlyphAndLabel() {
        for event in snapshot.events {
            XCTAssertFalse(event.outcome.label.isEmpty, event.id)
            XCTAssertFalse(event.outcome.kind.glyphSymbol.isEmpty, event.id)
        }
    }

    func testResolverWording() throws {
        XCTAssertEqual(try event("sam-homework-approved").resolverText, "Resolved by Sarah")
        XCTAssertEqual(try event("sam-free-pass-games").resolverText, "Granted by Sarah")
        XCTAssertNil(try event("sam-homework-deadline-met").resolverText)
    }

    func testDemoCalendarFormattingIsLocaleIndependent() {
        XCTAssertEqual(ActivityCalendar.timeText(ActivityCalendar.date(2026, 9, 30, 17, 48)), "5:48 PM")
        XCTAssertEqual(ActivityCalendar.timeText(ActivityCalendar.date(2026, 9, 30, 0, 5)), "12:05 AM")
        XCTAssertEqual(ActivityCalendar.timeText(ActivityCalendar.date(2026, 9, 30, 12, 0)), "12:00 PM")
        XCTAssertEqual(ActivityCalendar.dayLabel(for: ActivityCalendar.date(2026, 9, 20, 9, 0), relativeTo: ActivityDemoData.referenceDate), "20 Sep")
    }

    func testRoutesCoverEveryT00xScreen() {
        let routes: [ActivityRoute] = [
            .child(.sam), .ruleHistory(.all), .requestHistory(.all), .protectionHistory(.all), .appleScreenTime, .eventDetail("x")
        ]
        XCTAssertEqual(Set(routes).count, 6)
    }

    @MainActor
    func testViewModelLoadsThemisActivityAndAppleStateSeparately() async {
        let viewModel = ActivityViewModel(repository: MockActivityRepository(reportState: .unavailable))
        await viewModel.load()
        XCTAssertEqual(viewModel.screen?.snapshot, ActivityDemoData.snapshot)
        XCTAssertEqual(viewModel.screen?.appleReport, .unavailable)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.scope, .all)
    }
}
