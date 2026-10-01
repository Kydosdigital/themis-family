import Foundation

/// Deterministic Category A example data for the canonical family: Sarah (Owner),
/// Sam (Child) and Maya (Teen). Nothing is generated at runtime and nothing here is
/// Apple Screen Time data.
///
/// "Now" is Friday 2 October 2026, 6:30 PM (UTC, fixed). This week is Monday 28 September
/// to Sunday 4 October; last week is Monday 21 to Sunday 27 September.
enum ActivityDemoData {
    static let referenceDate = ActivityCalendar.date(2026, 10, 2, 18, 30)
    private static let owner = "Sarah"

    /// September 2026 unless `month` is 10.
    private static func at(_ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        ActivityCalendar.date(2026, month, day, hour, minute)
    }

    static let protectionNow: [ProtectionNow] = [
        ProtectionNow(child: .sam, status: .protected, evidence: "Verified 2 min ago"),
        ProtectionNow(child: .maya, status: .syncPending, evidence: "Verified 14 min ago")
    ]

    /// Explicit week-level protection evidence. The demo states it deterministically, as the
    /// approved frames show it; production will have to be supplied this by the repository.
    /// Missing evidence is never read as "Protected all week".
    static let protectionWeeks: [ProtectionWeekKey: WeeklyProtectionSummary] = [
        ProtectionWeekKey(child: .sam, period: .thisWeek): .protectedAllWeek,
        ProtectionWeekKey(child: .maya, period: .thisWeek): .changed([ProtectionWeekNote(state: .syncPending, weekday: "Tuesday")]),
        ProtectionWeekKey(child: .sam, period: .lastWeek): .changed([ProtectionWeekNote(state: .needsAttention, weekday: "Monday")]),
        ProtectionWeekKey(child: .maya, period: .lastWeek): .changed([ProtectionWeekNote(state: .deviceOffline, weekday: "Saturday")])
    ]

    // MARK: Variants

    /// Canonical frames (T-001 to T-006): Thursday's homework is still waiting for review, so
    /// T-002 reads "Timing could not be verified." with "Needs you". The visible rows are the
    /// ones the approved frames show; the other events still feed counts and filters.
    static let snapshot = makeSnapshot(thursday: thursdayAwaitingReview, variant: .canonical)

    /// T-002 after timing review: the same week with Thursday resolved as "Approved, timing
    /// unverified". Activity only presents this; the review itself belongs to the task flow.
    static let timingResolvedSnapshot = makeSnapshot(thursday: thursdayResolved, variant: .afterTimingReview)

    /// Review state: the canonical family plus one recorded change for each of the five
    /// protection states, shown without frame presentation so T-005 lists every change.
    static let allProtectionStatesSnapshot = ActivitySnapshot(
        referenceDate: referenceDate,
        events: events + allProtectionStateEvents,
        protectionNow: protectionNow,
        protectionWeeks: protectionWeeks
    )

    /// The canonical events.
    static let events: [ActivityEvent] = eventList(thursday: thursdayAwaitingReview)

    private static func eventList(thursday: ActivityEvent) -> [ActivityEvent] {
        [samHomework, [thursday], samOther, mayaRequests, mayaSessions, mayaOther, ruleChanges].flatMap { $0 }
    }

    private static func makeSnapshot(thursday: ActivityEvent, variant: ChildActivityVariant) -> ActivitySnapshot {
        ActivitySnapshot(
            referenceDate: referenceDate,
            events: eventList(thursday: thursday),
            protectionNow: protectionNow,
            protectionWeeks: protectionWeeks,
            presentation: ActivityFramePresentation(
                childWeekRowIDs: [
                    .sam: ["sam-homework-2026-09-28", "sam-homework-2026-09-29", "sam-homework-2026-09-30", thursday.id],
                    .maya: ["maya-instagram-15-tue", "maya-focus-2026-09-28"]
                ],
                protectionEarlierIDs: ["sam-protection-needs-attention", "maya-protection-offline-sat"],
                childActivityVariant: variant
            )
        )
    }

    // MARK: Sam · homework, one resolved task per school day

    private static let samHomework: [ActivityEvent] = [
        // This week
        homework("sam-homework-2026-09-28", at(9, 28, 17, 52), text: "Homework approved 5:52 PM"),
        homework("sam-homework-2026-09-29", at(9, 29, 18, 13), text: "Sent 5:42 · approved 6:13 PM"),
        // Approved after the deadline. Modelled as an on-time submission approved within the
        // 30-minute grace period (DEC-40), so it counts toward "on time".
        homework("sam-homework-2026-09-30", at(9, 30, 18, 25), text: "Approved after the deadline", outcome: ActivityStatus.afterDeadline),
        homework("sam-homework-2026-10-02", at(10, 2, 17, 48), text: "Homework approved 5:48 PM"),
        // Last week
        homework("sam-homework-2026-09-21", at(9, 21, 17, 50), text: "Homework approved 5:50 PM"),
        homework("sam-homework-2026-09-22", at(9, 22, 17, 55), text: "Homework approved 5:55 PM"),
        homework("sam-homework-2026-09-23", at(9, 23, 17, 40), text: "Homework approved 5:40 PM"),
        homework("sam-homework-2026-09-24", at(9, 24, 17, 58), text: "Homework approved 5:58 PM"),
        homework("sam-homework-2026-09-25", at(9, 25, 17, 45), text: "Homework approved 5:45 PM")
    ]

    /// Thursday before review: timing could not be verified, so it needs the parent.
    private static let thursdayAwaitingReview = ActivityEvent(
        id: "sam-homework-timing-needs-review", child: .sam, occurredAt: at(10, 1, 18, 5), category: .task,
        title: "Homework Deadline", outcome: .needsYou,
        detail: nil, resolver: nil,
        taskTiming: .timingUnverified, weekdayText: "Timing could not be verified."
    )

    /// Thursday after review: approved by Sarah with timing still unverified. Never restated as
    /// on time or late.
    private static let thursdayResolved = ActivityEvent(
        id: "sam-homework-timing-unverified", child: .sam, occurredAt: at(10, 1, 18, 20), category: .task,
        title: "Homework Deadline", outcome: .approvedTimingUnverified,
        detail: ActivityCopy.timingExplanation, resolver: owner,
        timing: TimingEvidence(claimedByChildDevice: at(10, 1, 17, 58), serverReceived: at(10, 1, 18, 2)),
        taskTiming: .timingUnverified
    )

    private static func homework(
        _ id: String,
        _ date: Date,
        text: String,
        outcome: ThemisStatus = .approved
    ) -> ActivityEvent {
        ActivityEvent(
            id: id, child: .sam, occurredAt: date, category: .task,
            title: "Homework", outcome: outcome,
            detail: nil, resolver: owner,
            taskTiming: .onTime, weekdayText: text
        )
    }

    // MARK: Sam · requests, Free Pass, protection

    private static let samOther: [ActivityEvent] = [
        ActivityEvent(
            id: "sam-youtube-school-20", child: .sam, occurredAt: at(9, 28, 16, 20), category: .request,
            title: "YouTube for school · 20 min", outcome: .approved, detail: nil, resolver: owner
        ),
        ActivityEvent(
            id: "sam-roblox-30", child: .sam, occurredAt: at(10, 1, 16, 10), category: .request,
            title: "Roblox · 30 min", outcome: .partiallyApproved, detail: nil, resolver: owner
        ),
        ActivityEvent(
            id: "sam-free-pass-games", child: .sam, occurredAt: at(9, 30, 19, 15), category: .temporaryAccess,
            title: "Games · 30 minute Free Pass", outcome: ActivityStatus.granted,
            detail: nil, resolver: owner, durationMinutes: 30
        ),
        ActivityEvent(
            id: "sam-protection-needs-attention", child: .sam, occurredAt: at(9, 21, 19, 10), category: .protection,
            title: "Apple permission turned off", outcome: ActivityStatus.fixed,
            detail: "Mon 7:10 PM · fixed 7:24 PM", resolver: nil, protectionState: .needsAttention
        )
    ]

    // MARK: Maya · requests

    private static let mayaRequests: [ActivityEvent] = [
        // This week
        ActivityEvent(
            id: "maya-instagram-15-tue", child: .maya, occurredAt: at(9, 29, 22, 4), category: .request,
            title: "Instagram · 15 min", outcome: .partiallyApproved, detail: nil, resolver: owner
        ),
        ActivityEvent(
            id: "maya-instagram-15-wed", child: .maya, occurredAt: at(9, 30, 17, 30), category: .request,
            title: "Instagram · 15 min", outcome: .approved, detail: nil, resolver: owner
        ),
        ActivityEvent(
            id: "maya-youtube-15", child: .maya, occurredAt: at(10, 1, 16, 45), category: .request,
            title: "YouTube · 15 min", outcome: .declined, detail: nil, resolver: owner
        ),
        // Last week
        ActivityEvent(
            id: "maya-instagram-30", child: .maya, occurredAt: at(9, 22, 21, 30), category: .request,
            title: "Instagram · 30 min", outcome: .declined, detail: nil, resolver: owner
        ),
        ActivityEvent(
            id: "maya-tiktok-15", child: .maya, occurredAt: at(9, 24, 20, 0), category: .request,
            title: "TikTok · 15 min", outcome: .expired, detail: nil, resolver: nil
        )
    ]

    // MARK: Maya · Focus Sessions (system outcomes, not proof of a real-world activity)

    private static let mayaSessions: [ActivityEvent] = [
        focus("maya-focus-2026-09-28", at(9, 28, 16, 30)),
        focus("maya-focus-2026-09-30", at(9, 30, 16, 50)),
        focus("maya-focus-2026-10-01-interrupted", at(10, 1, 17, 10), outcome: ActivityStatus.interrupted),
        focus("maya-focus-2026-10-02", at(10, 2, 16, 50)),
        focus("maya-focus-2026-09-22", at(9, 22, 16, 40)),
        focus("maya-focus-2026-09-24", at(9, 24, 16, 40))
    ]

    private static func focus(_ id: String, _ date: Date, outcome: ThemisStatus = .completed) -> ActivityEvent {
        ActivityEvent(
            id: id, child: .maya, occurredAt: date, category: .session,
            title: "Focus Session · 30 min", outcome: outcome,
            detail: nil, resolver: nil, durationMinutes: 30
        )
    }

    // MARK: Maya · protection

    private static let mayaOther: [ActivityEvent] = [
        ActivityEvent(
            id: "maya-protection-sync-pending-tue", child: .maya, occurredAt: at(9, 29, 16, 12), category: .protection,
            title: "Change waiting to reach device", outcome: ProtectionStatus.syncPending.themisStatus,
            detail: "Tue 4:12 PM", resolver: nil, protectionState: .syncPending
        ),
        ActivityEvent(
            id: "maya-protection-offline-sat", child: .maya, occurredAt: at(9, 26, 14, 0), category: .protection,
            title: "Offline for 3 hr", outcome: ActivityStatus.reconnected,
            detail: "Sat · reconnected", resolver: nil, protectionState: .deviceOffline
        )
    ]

    // MARK: Rule changes (who changed what, and when)

    private static let ruleChanges: [ActivityEvent] = [
        ActivityEvent(
            id: "rule-homework-deadline-edited", child: .sam, occurredAt: at(9, 12, 20, 0), category: .rule,
            title: "Homework Deadline edited", outcome: ActivityStatus.edited,
            detail: "Due time 5:30 → 6:00 PM", resolver: owner
        ),
        ActivityEvent(
            id: "rule-bedtime-created", child: .sam, occurredAt: at(9, 3, 19, 0), category: .rule,
            title: "Bedtime created", outcome: ActivityStatus.created,
            detail: nil, resolver: "Alex"
        ),
        ActivityEvent(
            id: "rule-social-apps-edited", child: .maya, occurredAt: at(9, 1, 20, 0), category: .rule,
            title: "Social apps schedule edited", outcome: ActivityStatus.edited,
            detail: nil, resolver: owner
        )
    ]

    // MARK: Review-only protection states

    private static let allProtectionStateEvents: [ActivityEvent] = [
        reviewProtection("review-protected", .protected, hour: 9, detail: "Verified 9:00 AM"),
        reviewProtection("review-sync-pending", .syncPending, hour: 10, detail: "Change waiting to reach device"),
        reviewProtection("review-device-offline", .deviceOffline, hour: 11, detail: "Device hasn’t checked in"),
        reviewProtection("review-needs-attention", .needsAttention, hour: 12, detail: "Apple permission turned off"),
        reviewProtection("review-protection-unavailable", .protectionUnavailable, hour: 13, detail: "Protection couldn’t be applied")
    ]

    private static func reviewProtection(_ id: String, _ state: ProtectionStatus, hour: Int, detail: String) -> ActivityEvent {
        ActivityEvent(
            id: id, child: .sam, occurredAt: at(10, 2, hour, 0), category: .protection,
            title: ActivityChild.sam.deviceName, outcome: state.themisStatus,
            detail: detail, resolver: nil, protectionState: state
        )
    }
}
