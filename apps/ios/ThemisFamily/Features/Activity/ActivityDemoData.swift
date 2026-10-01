import Foundation

/// Deterministic Category A example data for the canonical family: Sarah (Owner),
/// Sam (Child) and Maya (Teen). Nothing is generated at runtime and nothing here is
/// Apple Screen Time data.
///
/// "Now" is Wednesday 30 September 2026, 6:30 PM (UTC, fixed).
enum ActivityDemoData {
    static let referenceDate = ActivityCalendar.date(2026, 9, 30, 18, 30)
    private static let owner = "Sarah"

    private static func at(_ day: Int, _ hour: Int, _ minute: Int, month: Int = 9) -> Date {
        ActivityCalendar.date(2026, month, day, hour, minute)
    }

    static let snapshot = ActivitySnapshot(
        referenceDate: referenceDate,
        events: events,
        protectionNow: [
            ProtectionNow(child: .sam, status: .protected, evidence: "Verified 2 min ago"),
            ProtectionNow(child: .maya, status: .syncPending, evidence: "Change waiting to reach device")
        ]
    )

    static let events: [ActivityEvent] = [
        // Today · Wednesday
        ActivityEvent(
            id: "sam-homework-submitted", child: .sam, occurredAt: at(30, 17, 42), category: .task,
            title: "Homework submitted", outcome: ThemisStatus(.resolved, label: "Submitted"),
            detail: nil, resolver: nil
        ),
        ActivityEvent(
            id: "sam-homework-approved", child: .sam, occurredAt: at(30, 17, 48), category: .task,
            title: "Homework approved", outcome: .approved,
            detail: nil, resolver: owner
        ),
        ActivityEvent(
            id: "sam-homework-deadline-met", child: .sam, occurredAt: at(30, 18, 0), category: .rule,
            title: "Homework Deadline met", outcome: ThemisStatus(.cleared, label: "Met"),
            detail: nil, resolver: nil
        ),
        ActivityEvent(
            id: "maya-instagram-plus15", child: .maya, occurredAt: at(30, 17, 55), category: .request,
            title: "Instagram · +15 min", outcome: .approved,
            detail: "Requested +15 min · Approved +15 min", resolver: owner
        ),
        ActivityEvent(
            id: "maya-focus-30", child: .maya, occurredAt: at(30, 16, 50), category: .session,
            title: "30-minute Focus Session completed", outcome: .completed,
            detail: nil, resolver: nil
        ),
        ActivityEvent(
            id: "maya-protection-sync-pending", child: .maya, occurredAt: at(30, 17, 46), category: .protection,
            title: ActivityChild.maya.deviceName, outcome: ProtectionStatus.syncPending.themisStatus,
            detail: "Change waiting to reach device", resolver: nil
        ),

        // Yesterday · Tuesday
        ActivityEvent(
            id: "maya-social-schedule-started", child: .maya, occurredAt: at(29, 22, 0), category: .rule,
            title: "Social apps", outcome: ThemisStatus(.active, label: "Schedule started"),
            detail: "10:00 PM–7:00 AM", resolver: nil
        ),
        ActivityEvent(
            id: "sam-free-pass-games", child: .sam, occurredAt: at(29, 19, 15), category: .temporaryAccess,
            title: "Games · 30 minute Free Pass", outcome: ThemisStatus(.freePassActive, label: "Granted"),
            detail: nil, resolver: owner
        ),
        ActivityEvent(
            id: "sam-roblox-plus30", child: .sam, occurredAt: at(29, 16, 10), category: .request,
            title: "Roblox · +30 min", outcome: .partiallyApproved,
            detail: "Requested +30 min · Approved +15 min", resolver: owner
        ),
        ActivityEvent(
            id: "sam-youtube-plus15", child: .sam, occurredAt: at(29, 15, 50), category: .request,
            title: "YouTube · +15 min", outcome: .declined,
            detail: "Requested +15 min", resolver: owner
        ),

        // Monday
        ActivityEvent(
            id: "sam-homework-timing-unverified", child: .sam, occurredAt: at(28, 18, 20), category: .task,
            title: "Homework Deadline", outcome: .approvedTimingUnverified,
            detail: ActivityCopy.timingExplanation, resolver: owner,
            timing: TimingEvidence(claimedByChildDevice: at(28, 17, 58), serverReceived: at(28, 18, 2))
        ),
        ActivityEvent(
            id: "sam-protection-restored", child: .sam, occurredAt: at(28, 19, 24), category: .protection,
            title: ActivityChild.sam.deviceName, outcome: ProtectionStatus.protected.themisStatus,
            detail: "Verified 7:24 PM", resolver: nil
        ),
        ActivityEvent(
            id: "sam-protection-needs-attention", child: .sam, occurredAt: at(28, 19, 10), category: .protection,
            title: ActivityChild.sam.deviceName, outcome: ProtectionStatus.needsAttention.themisStatus,
            detail: "Apple permission was turned off", resolver: nil
        ),

        // Sunday
        ActivityEvent(
            id: "sam-protection-unavailable", child: .sam, occurredAt: at(27, 11, 0), category: .protection,
            title: ActivityChild.sam.deviceName, outcome: ProtectionStatus.protectionUnavailable.themisStatus,
            detail: "Protection couldn’t be applied on this iPhone", resolver: nil
        ),

        // Saturday
        ActivityEvent(
            id: "maya-protection-offline", child: .maya, occurredAt: at(26, 14, 0), category: .protection,
            title: ActivityChild.maya.deviceName, outcome: ProtectionStatus.deviceOffline.themisStatus,
            detail: "Offline for 3 hr, then reconnected", resolver: nil
        )
    ]
}
