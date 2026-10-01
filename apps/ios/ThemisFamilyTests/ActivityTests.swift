import XCTest
@testable import ThemisFamily

final class ActivityTests: XCTestCase {
    private let snapshot = ActivityDemoData.snapshot

    private func event(_ id: String) throws -> ActivityEvent {
        try XCTUnwrap(snapshot.event(id: id), "Missing demo event \(id)")
    }

    private func summary(_ scope: ActivityScope, _ period: ActivityPeriod = .thisWeek) -> ActivityWeeklySummary {
        snapshot.summary(for: scope, period: period)
    }

    /// Every sentence the Activity demo can show.
    private var allDemoCopy: [String] {
        var copy: [String] = [ActivityCopy.overviewFooter, ActivityCopy.emptyTitle, ActivityCopy.emptyMessage,
                              ActivityCopy.timingExplanation, ActivityRetention.ruleChangesFooter,
                              ActivityRetention.requestsFooter]
        for event in snapshot.events + ActivityDemoData.allProtectionStatesSnapshot.events {
            copy.append(contentsOf: [event.title, event.outcome.label])
            copy.append(contentsOf: [event.detail, event.resolverText, event.weekdayText].compactMap { $0 })
        }
        copy.append(contentsOf: snapshot.protectionNow.flatMap { [$0.status.label, $0.evidence] })
        copy.append(contentsOf: ActivityChild.allCases.map(ActivityCopy.appUsageNote(for:)))
        for state in AppleScreenTimeReportState.allCases {
            copy.append(contentsOf: AppleScreenTimeCopy.allCopy(for: state))
        }
        for period in ActivityPeriod.allCases {
            for scope in ActivityScope.allCases {
                let weekly = summary(scope, period)
                copy.append(ActivityPresentation.overviewLine(weekly))
                copy.append(contentsOf: ActivityPresentation.summaryItems(weekly).flatMap { [$0.key, $0.value] })
            }
        }
        return copy
    }

    // MARK: Categories and canonical data

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
            Mirror(reflecting: snapshot.protectionNow[0]),
            Mirror(reflecting: summary(.all))
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

    // MARK: Apple Screen Time (Category B boundary)

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
    func testT006CopyStatesThemisCannotReadStoreOrShareAppleReport() {
        XCTAssertEqual(
            AppleScreenTimeCopy.availableNotice,
            "Apple draws this report on this iPhone. Themis can’t read, store or share it."
        )
        XCTAssertTrue(AppleScreenTimeCopy.allCopy(for: .systemOwnedReportArea).contains(AppleScreenTimeCopy.availableNotice))
        XCTAssertEqual(AppleScreenTimeCopy.areaDetail, "Rendered by Apple. What appears depends on Apple and the device.")
        XCTAssertEqual(
            AppleScreenTimeCopy.separation,
            "Themis activity (tasks, requests, passes, protection) is separate and stays in the Activity tab."
        )
    }

    // TEST 6
    func testUnavailableStateIsNeitherPermanentNorAPromiseOfLaterAvailability() {
        XCTAssertEqual(AppleScreenTimeCopy.unavailableNotice, "Apple’s report isn’t available on this iPhone right now.")
        XCTAssertEqual(
            AppleScreenTimeCopy.unavailableSupport,
            "This depends on Apple and the device. Themis activity is still available in the Activity tab."
        )
        let unavailable = AppleScreenTimeCopy.allCopy(for: .unavailable).joined(separator: " ").lowercased()
        for phrase in ["permanent", "never", "forever", "will be available", "will become", "soon", "later", "coming", "yet", "we’ll fix", "themis can fix", "try again"] {
            XCTAssertFalse(unavailable.contains(phrase), "Unavailable copy must not say “\(phrase)”")
        }
    }

    func testAppleReportNeverSharesAContainerWithThemisSummaries() {
        // The Apple-owned area holds Apple's own copy only: no Themis count or outcome text.
        let areaCopy = [AppleScreenTimeCopy.areaLabel, AppleScreenTimeCopy.areaTitle, AppleScreenTimeCopy.areaDetail]
        for sentence in areaCopy {
            XCTAssertFalse(sentence.localizedCaseInsensitiveContains("homework"))
            XCTAssertFalse(sentence.localizedCaseInsensitiveContains("request"))
            XCTAssertFalse(sentence.localizedCaseInsensitiveContains("Focus Session"))
        }
        // A weekly summary never mentions Apple or Screen Time.
        for period in ActivityPeriod.allCases {
            for scope in ActivityScope.allCases {
                let weekly = summary(scope, period)
                let text = ([ActivityPresentation.overviewLine(weekly)] + ActivityPresentation.summaryItems(weekly).flatMap { [$0.key, $0.value] })
                    .joined(separator: " ")
                XCTAssertFalse(text.localizedCaseInsensitiveContains("apple"))
                XCTAssertFalse(text.localizedCaseInsensitiveContains("screen time"))
            }
        }
    }

    // MARK: Timing unverified

    // TEST 7
    func testTimingUnverifiedUsesTheExactOutcomeAndNeverOnTimeOrLate() throws {
        let timing = try event("sam-homework-timing-unverified")
        XCTAssertEqual(timing.outcome.label, "Approved, timing unverified")
        XCTAssertEqual(timing.outcome, .approvedTimingUnverified)
        XCTAssertEqual(timing.taskTiming, .timingUnverified)
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

    func testTimingUnverifiedWeekdayRowReadsApprovedTimingUnverifiedAndOpensTheDetail() throws {
        let rows = ActivityPresentation.weekRows(for: .sam, snapshot: snapshot)
        let thursday = try XCTUnwrap(rows.first { $0.title == "Thursday" })
        XCTAssertEqual(thursday.subtitle, "Approved, timing unverified")
        XCTAssertEqual(thursday.detailEventID, "sam-homework-timing-unverified")
        XCTAssertEqual(rows.filter { $0.detailEventID != nil }.count, 1)
    }

    func testTimingUnverifiedIsNotCountedOnTimeAndNotLabelledLate() {
        let sam = summary(.sam)
        XCTAssertEqual(sam.homeworkDays, 5)
        XCTAssertEqual(sam.homeworkOnTime, 4)
        XCTAssertLessThan(sam.homeworkOnTime, sam.homeworkDays, "The timing-unverified day is the one not counted on time")
        let items = ActivityPresentation.summaryItems(sam)
        XCTAssertFalse(items.contains { $0.value.localizedCaseInsensitiveContains("late") })
    }

    // MARK: Focus Sessions and protection

    // TEST 9
    func testFocusSessionDescribesSystemEvidenceHonestly() throws {
        let focus = try event("maya-focus-2026-09-28")
        XCTAssertEqual(focus.category, .session)
        XCTAssertEqual(focus.title, "Focus Session · 30 min")
        XCTAssertEqual(focus.outcome, .completed)
        XCTAssertEqual(focus.durationMinutes, 30)
        XCTAssertEqual(focus.child, .maya)
        for sentence in allDemoCopy {
            XCTAssertFalse(sentence.localizedCaseInsensitiveContains("focused for"), "Overclaims a real-world activity: \(sentence)")
        }
    }

    // TEST 10
    func testProtectionHistoryCanRepresentAllFiveApprovedStates() {
        let review = ActivityDemoData.allProtectionStatesSnapshot
        let states = Set(review.events.compactMap(\.protectionState).map(\.rawValue))
        XCTAssertEqual(states, ["protected", "syncPending", "deviceOffline", "needsAttention", "protectionUnavailable"])

        let reviewLabels = Set(review.events.filter { $0.id.hasPrefix("review-") }.map { $0.outcome.label })
        XCTAssertEqual(reviewLabels, ["Protected", "Sync pending", "Device offline", "Needs attention", "Protection unavailable"])
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
        XCTAssertEqual(maya?.evidence, "Verified 14 min ago")
        for event in ActivityDemoData.allProtectionStatesSnapshot.events where event.outcome == .protected {
            XCTAssertTrue(event.detail?.hasPrefix("Verified") ?? false, "Protected event without evidence")
        }
    }

    // MARK: Sorting and filtering

    // TEST 11
    func testActivitySortsNewestFirstDeterministically() {
        let sorted = snapshot.events(for: .all)
        XCTAssertEqual(sorted.count, snapshot.events.count)
        XCTAssertEqual(sorted.first?.id, "sam-homework-2026-10-02")
        XCTAssertEqual(sorted.last?.id, "rule-social-apps-edited")
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
        XCTAssertEqual(Array(groups.map(\.title).prefix(3)), ["Today", "Yesterday", "Wednesday"])
        XCTAssertEqual(groups.map { $0.events.count }.reduce(0, +), snapshot.events.count)
    }

    // TEST 12
    func testScopeFilteringIsDeterministic() {
        let all = snapshot.events(for: .all)
        let sam = snapshot.events(for: .sam)
        let maya = snapshot.events(for: .maya)

        XCTAssertEqual(all.count, 30)
        XCTAssertEqual(sam.count, 16)
        XCTAssertEqual(maya.count, 14)
        XCTAssertTrue(sam.allSatisfy { $0.child == .sam })
        XCTAssertTrue(maya.allSatisfy { $0.child == .maya })
        XCTAssertEqual(Set(sam.map(\.id)).union(maya.map(\.id)), Set(all.map(\.id)))
        XCTAssertEqual(ActivityScope.allCases.map(\.title), ["All", "Sam", "Maya"])

        let samRequests = snapshot.events(for: .sam, categories: [.request])
        XCTAssertEqual(samRequests.map(\.id), ["sam-roblox-30", "sam-youtube-school-20"])
    }

    // TEST 13
    func testRequestHistoryRepresentsApprovedPartiallyApprovedDeclinedAndExpired() throws {
        let requests = snapshot.events(for: .all, categories: [.request])
        XCTAssertEqual(requests.count, 7)

        XCTAssertEqual(try event("maya-instagram-15-wed").outcome, .approved)
        XCTAssertEqual(try event("sam-roblox-30").outcome, .partiallyApproved)
        XCTAssertEqual(try event("maya-youtube-15").outcome, .declined)
        XCTAssertEqual(try event("maya-tiktok-15").outcome, .expired)
        XCTAssertEqual(Set(requests.map(\.outcome.label)), ["Approved", "Partially approved", "Declined", "Expired"])
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

    // MARK: Weekly summaries (Category A only)

    func testWeeklySummaryLinesMatchTheApprovedFrame() {
        XCTAssertEqual(ActivityPresentation.overviewLine(summary(.sam)), "Homework on time 4 of 5 · 2 requests")
        XCTAssertEqual(ActivityPresentation.overviewLine(summary(.maya)), "3 Focus Sessions · 3 requests")
    }

    func testWeeklySummaryFilteringByScopeAndPeriod() {
        let sam = summary(.sam)
        XCTAssertEqual([sam.homeworkOnTime, sam.homeworkDays, sam.requestCount, sam.freePassCount, sam.freePassMinutes], [4, 5, 2, 1, 30])
        XCTAssertEqual([sam.focusCompleted, sam.focusInterrupted], [0, 0])

        let maya = summary(.maya)
        XCTAssertEqual([maya.focusCompleted, maya.focusInterrupted, maya.requestCount], [3, 1, 3])
        XCTAssertEqual([maya.homeworkDays, maya.freePassCount], [0, 0])

        // All is exactly Sam plus Maya, nothing more.
        let all = summary(.all)
        XCTAssertEqual(all.homeworkDays, sam.homeworkDays + maya.homeworkDays)
        XCTAssertEqual(all.homeworkOnTime, sam.homeworkOnTime + maya.homeworkOnTime)
        XCTAssertEqual(all.requestCount, sam.requestCount + maya.requestCount)
        XCTAssertEqual(all.requestsApproved, 2)
        XCTAssertEqual(all.requestsPartiallyApproved, 2)
        XCTAssertEqual(all.requestsDeclined, 1)
        XCTAssertEqual(all.focusCompleted, sam.focusCompleted + maya.focusCompleted)
        XCTAssertEqual(all.freePassCount, sam.freePassCount + maya.freePassCount)

        // Last week uses last week's events.
        XCTAssertEqual(ActivityPresentation.overviewLine(summary(.sam, .lastWeek)), "Homework on time 5 of 5")
        XCTAssertEqual(ActivityPresentation.overviewLine(summary(.maya, .lastWeek)), "2 Focus Sessions · 2 requests")
        XCTAssertEqual(summary(.maya, .lastWeek).requestsDeclined, 1)
        XCTAssertEqual(summary(.maya, .lastWeek).requestsExpired, 1)
    }

    func testSummariesAreDerivedFromThemisEventsOnly() {
        // The same counts can be rebuilt from the events alone: nothing else feeds a summary.
        let samEvents = snapshot.events(for: .sam).filter { ActivityPeriod.thisWeek.contains($0.occurredAt, reference: snapshot.referenceDate) }
        XCTAssertEqual(samEvents.filter { $0.category == .task && $0.taskTiming != nil }.count, summary(.sam).homeworkDays)
        XCTAssertEqual(samEvents.filter { $0.category == .request }.count, summary(.sam).requestCount)
        XCTAssertEqual(samEvents.filter { $0.category == .temporaryAccess }.compactMap(\.durationMinutes).reduce(0, +), summary(.sam).freePassMinutes)
    }

    func testNoChildScoringRankingOrGamificationExists() {
        let forbiddenNames = ["score", "rank", "rating", "compliance", "streak", "points", "grade", "badge"]
        let mirrors = [Mirror(reflecting: summary(.sam)), Mirror(reflecting: snapshot.events[0]), Mirror(reflecting: snapshot)]
        for mirror in mirrors {
            for label in mirror.children.compactMap(\.label) {
                for name in forbiddenNames {
                    XCTAssertFalse(label.lowercased().contains(name), "Field \(label) looks like a score or ranking")
                }
            }
        }
        for sentence in allDemoCopy {
            for word in ["compliant", "non-compliant", "good", "bad", "best", "worst", "rank", "score"] {
                XCTAssertNil(
                    sentence.lowercased().range(of: "\\b\(word)\\b", options: .regularExpression),
                    "Copy judges a child (“\(word)”): \(sentence)"
                )
            }
        }
    }

    func testPeriodsAreMondayToSundayWeeks() {
        let reference = ActivityDemoData.referenceDate // Friday 2 October 2026
        XCTAssertEqual(ActivityCalendar.weekStart(of: reference), ActivityCalendar.date(2026, 9, 28, 0, 0))
        XCTAssertEqual(ActivityCalendar.weekStart(of: ActivityCalendar.date(2026, 10, 4, 23, 0)), ActivityCalendar.date(2026, 9, 28, 0, 0))
        XCTAssertEqual(ActivityCalendar.weekStart(of: ActivityCalendar.date(2026, 9, 28, 0, 0)), ActivityCalendar.date(2026, 9, 28, 0, 0))
        XCTAssertTrue(ActivityPeriod.thisWeek.contains(ActivityCalendar.date(2026, 9, 28, 0, 0), reference: reference))
        XCTAssertFalse(ActivityPeriod.thisWeek.contains(ActivityCalendar.date(2026, 9, 27, 23, 59), reference: reference))
        XCTAssertTrue(ActivityPeriod.lastWeek.contains(ActivityCalendar.date(2026, 9, 27, 23, 59), reference: reference))
        XCTAssertFalse(ActivityPeriod.lastWeek.contains(ActivityCalendar.date(2026, 9, 20, 23, 59), reference: reference))
        XCTAssertEqual(ActivityPeriod.allCases.map(\.title), ["This week", "Last week"])
    }

    // MARK: Approved frame content

    func testChildSummaryItemsMatchTheApprovedFrames() {
        let sam = ActivityPresentation.summaryItems(summary(.sam)).map { [$0.key, $0.value] }
        XCTAssertEqual(sam, [
            ["Homework", "On time 4 of 5 school days"],
            ["Requests", "2 · 1 approved, 1 partly approved"],
            ["Free Passes", "1 · 30 min"],
            ["Protection", "Protected all week"]
        ])

        let maya = ActivityPresentation.summaryItems(summary(.maya)).map { [$0.key, $0.value] }
        XCTAssertEqual(maya, [
            ["Focus Sessions", "3 completed · 1 interrupted"],
            ["Requests", "3 · 1 approved, 1 partly approved, 1 declined"],
            ["Protection", "Sync pending on Tuesday"]
        ])
    }

    func testSamWeekdayRowsMatchTheApprovedFrame() {
        let rows = ActivityPresentation.weekRows(for: .sam, snapshot: snapshot)
        XCTAssertEqual(rows.map(\.title), ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"])
        XCTAssertEqual(rows.map(\.subtitle), [
            "Homework approved 5:52 PM",
            "Sent 5:42 · approved 6:13 PM",
            "Approved after the deadline",
            "Approved, timing unverified",
            "Homework approved 5:48 PM"
        ])
        XCTAssertEqual(rows.map { $0.status?.label }, ["Approved", "Approved", "After 6:00", "Approved", "Approved"])
    }

    func testMayaWeekRowsListRequestsAndFocusSessionsNewestFirst() throws {
        let rows = ActivityPresentation.weekRows(for: .maya, snapshot: snapshot)
        XCTAssertEqual(rows.count, 7)
        let tuesday = try XCTUnwrap(rows.first { $0.id == "maya-instagram-15-tue" })
        XCTAssertEqual(tuesday.title, "Instagram · 15 min")
        XCTAssertEqual(tuesday.subtitle, "Tuesday · partly approved")
        XCTAssertEqual(tuesday.status, .partiallyApproved)
        let monday = try XCTUnwrap(rows.first { $0.id == "maya-focus-2026-09-28" })
        XCTAssertEqual(monday.title, "Focus Session · 30 min")
        XCTAssertEqual(monday.subtitle, "Monday")
        XCTAssertEqual(monday.status, .completed)
        XCTAssertEqual(rows.first?.id, "maya-focus-2026-10-02")
    }

    func testAppUsageNoteAppearsForSamOnlyAsDrawn() {
        XCTAssertTrue(ActivityPresentation.showsAppUsageNote(for: .sam))
        XCTAssertFalse(ActivityPresentation.showsAppUsageNote(for: .maya))
        XCTAssertEqual(ActivityCopy.appUsageNote(for: .sam), "Themis doesn’t show which apps Sam used or for how long.")
    }

    func testRuleChangesMatchTheApprovedFrame() {
        let sections = ActivityPresentation.ruleChangeSections(snapshot: snapshot)
        XCTAssertEqual(sections.map(\.title), ["September"])
        XCTAssertEqual(sections.first?.rows.map(\.title), ["Homework Deadline edited", "Bedtime created", "Social apps schedule edited"])
        XCTAssertEqual(sections.first?.rows.map(\.subtitle), [
            "Due time 5:30 → 6:00 PM · Sarah · 12 Sep",
            "Sam · Alex · 3 Sep",
            "Maya · Sarah · 1 Sep"
        ])
        XCTAssertTrue(sections.flatMap(\.rows).allSatisfy { $0.status == nil })
    }

    func testRequestRowsMatchTheApprovedFrame() throws {
        let all = ActivityPresentation.requestRows(scope: .all, snapshot: snapshot)
        XCTAssertEqual(all.count, 7)
        let tuesday = try XCTUnwrap(all.first { $0.id == "maya-instagram-15-tue" })
        XCTAssertEqual(tuesday.title, "Instagram · 15 min")
        XCTAssertEqual(tuesday.subtitle, "Maya · Tue 10:04 PM")
        XCTAssertEqual(tuesday.status, .partiallyApproved)
        XCTAssertEqual(try XCTUnwrap(all.first { $0.id == "maya-instagram-30" }).subtitle, "Maya · last week")
        XCTAssertEqual(try XCTUnwrap(all.first { $0.id == "maya-tiktok-15" }).status, .expired)
        XCTAssertEqual(try XCTUnwrap(all.first { $0.id == "sam-youtube-school-20" }).title, "YouTube for school · 20 min")

        XCTAssertEqual(ActivityPresentation.requestRows(scope: .sam, snapshot: snapshot).count, 2)
        XCTAssertEqual(ActivityPresentation.requestRows(scope: .maya, snapshot: snapshot).count, 5)
        XCTAssertTrue(ActivityPresentation.requestRows(scope: .sam, snapshot: snapshot).allSatisfy { $0.subtitle?.hasPrefix("Sam") ?? false })
    }

    func testProtectionRowsMatchTheApprovedFrame() {
        let now = ActivityPresentation.protectionNowRows(snapshot: snapshot)
        XCTAssertEqual(now.map(\.title), ["Sam’s iPhone", "Maya’s iPhone"])
        XCTAssertEqual(now.map(\.subtitle), ["Verified 2 min ago", "Verified 14 min ago"])
        XCTAssertEqual(now.map { $0.status?.kind }, [.protected, .syncPending])

        let earlier = ActivityPresentation.protectionEarlierRows(snapshot: snapshot)
        let attention = earlier.first { $0.id == "sam-protection-needs-attention" }
        XCTAssertEqual(attention?.title, "Apple permission turned off")
        XCTAssertEqual(attention?.subtitle, "Sam · Mon 7:10 PM · fixed 7:24 PM")
        XCTAssertEqual(attention?.status?.label, "Fixed")
        let offline = earlier.first { $0.id == "maya-protection-offline-sat" }
        XCTAssertEqual(offline?.title, "Offline for 3 hr")
        XCTAssertEqual(offline?.subtitle, "Maya · Sat · reconnected")
        XCTAssertEqual(offline?.status?.label, "Reconnected")
    }

    func testOverviewFooterMatchesTheApprovedFrame() {
        XCTAssertEqual(
            ActivityCopy.overviewFooter,
            "Activity shows what happened with your family’s Themis rules. It isn’t a record of everything your children do."
        )
    }

    // MARK: Retention copy (docs/23_PRIVACY_AND_CHILD_SAFETY.md §23.5)

    func testStructuredHistoryCopyUsesTwelveMonthRollingRetention() {
        XCTAssertEqual(ActivityRetention.structuredHistoryMonths, 12)
        XCTAssertEqual(ActivityRetention.ruleChangesFooter, "Shows the last 12 months.")
        XCTAssertTrue(ActivityRetention.requestsFooter.hasPrefix("Outcomes are kept for 12 months."))
    }

    func testFreeTextContentCopyUsesNinetyDayRetention() {
        XCTAssertEqual(ActivityRetention.freeTextDays, 90)
        XCTAssertTrue(ActivityRetention.requestsFooter.hasSuffix("Reasons and notes are removed after 90 days."))
        XCTAssertEqual(
            ActivityRetention.requestsFooter,
            "Outcomes are kept for 12 months. Reasons and notes are removed after 90 days."
        )
    }

    func testStructuredRequestOutcomesAreNotDescribedAsNinetyDayOnly() throws {
        let footer = ActivityRetention.requestsFooter
        // 90 days is attached to reasons and notes only, never to the request outcome.
        let ninety = try XCTUnwrap(footer.range(of: "90 days"))
        let reasons = try XCTUnwrap(footer.range(of: "Reasons and notes"))
        XCTAssertLessThan(reasons.lowerBound, ninety.lowerBound)
        XCTAssertNil(footer.range(of: "Outcomes[^.]*90", options: .regularExpression))
        XCTAssertNil(footer.range(of: "Requests? (are|is) (removed|deleted)", options: .regularExpression))
        XCTAssertNotNil(footer.range(of: "Outcomes are kept for 12 months", options: .literal))
    }

    func testRetentionIsCopyOnlyWithNoControls() {
        // Retention is expressed as constants and sentences only.
        for sentence in [ActivityRetention.ruleChangesFooter, ActivityRetention.requestsFooter] {
            for word in ["delete", "change", "choose", "set "] {
                XCTAssertFalse(sentence.lowercased().contains(word), "Retention copy must not suggest a control: \(sentence)")
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
        XCTAssertEqual(try event("sam-homework-2026-09-28").resolverText, "Resolved by Sarah")
        XCTAssertEqual(try event("sam-free-pass-games").resolverText, "Granted by Sarah")
        XCTAssertEqual(try event("rule-bedtime-created").resolverText, "Changed by Alex")
        XCTAssertNil(try event("maya-focus-2026-09-28").resolverText)
    }

    func testDemoCalendarFormattingIsLocaleIndependent() {
        XCTAssertEqual(ActivityCalendar.timeText(ActivityCalendar.date(2026, 9, 30, 17, 48)), "5:48 PM")
        XCTAssertEqual(ActivityCalendar.timeText(ActivityCalendar.date(2026, 9, 30, 0, 5)), "12:05 AM")
        XCTAssertEqual(ActivityCalendar.timeText(ActivityCalendar.date(2026, 9, 30, 12, 0)), "12:00 PM")
        XCTAssertEqual(ActivityCalendar.shortWeekdayTime(ActivityCalendar.date(2026, 9, 29, 22, 4)), "Tue 10:04 PM")
        XCTAssertEqual(ActivityCalendar.monthName(ActivityCalendar.date(2026, 9, 12, 20, 0)), "September")
        XCTAssertEqual(ActivityCalendar.dayMonthText(ActivityCalendar.date(2026, 9, 12, 20, 0)), "12 Sep")
        XCTAssertEqual(ActivityCalendar.dayLabel(for: ActivityCalendar.date(2026, 9, 20, 9, 0), relativeTo: ActivityDemoData.referenceDate), "20 Sep")
    }

    func testRoutesCoverEveryT00xScreen() {
        let routes: [ActivityRoute] = [
            .child(.sam), .ruleChanges, .requestHistory, .protectionHistory, .appleScreenTime, .eventDetail("x")
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
        XCTAssertEqual(viewModel.period, .thisWeek)
    }
}
