import Foundation

/// A key/value line in a child's Activity summary (T-002).
struct ActivitySummaryItem: Identifiable, Equatable, Sendable {
    let key: String
    let value: String

    var id: String { key }
}

/// A row on a T-00x list, built from Themis-owned events only.
struct ActivityListRow: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String?
    /// Outcome chip with glyph and label. Nil for rows that have none (rule changes).
    let status: ThemisStatus?
    /// Opens the timing detail when this row carries timing evidence.
    let detailEventID: String?
}

struct ActivityRowSection: Identifiable, Equatable, Sendable {
    let id: String
    let title: String?
    let rows: [ActivityListRow]
}

/// Builds the strings and rows each T-00x screen shows, exactly as drawn in the approved
/// frames. Pure functions over Category A data, so they can be tested without a view.
enum ActivityPresentation {
    // MARK: T-001 · weekly summary line

    /// "Homework on time 4 of 5 · 2 requests" / "3 Focus Sessions · 3 requests".
    static func overviewLine(_ summary: ActivityWeeklySummary) -> String {
        var parts: [String] = []
        if summary.homeworkDays > 0 {
            parts.append("Homework on time \(summary.homeworkOnTime) of \(summary.homeworkDays)")
        }
        if summary.focusCompleted > 0 {
            parts.append("\(summary.focusCompleted) Focus Session\(summary.focusCompleted == 1 ? "" : "s")")
        }
        if summary.requestCount > 0 {
            parts.append("\(summary.requestCount) request\(summary.requestCount == 1 ? "" : "s")")
        }
        return parts.isEmpty ? "Nothing recorded" : parts.joined(separator: " · ")
    }

    // MARK: T-002 · child summary

    /// Homework, Focus Sessions, Requests, Free Passes and Protection, each only where the
    /// child has that kind of outcome (Sam has homework, Maya has Focus Sessions).
    static func summaryItems(_ summary: ActivityWeeklySummary) -> [ActivitySummaryItem] {
        var items: [ActivitySummaryItem] = []

        if summary.homeworkDays > 0 {
            items.append(
                ActivitySummaryItem(
                    key: "Homework",
                    value: "On time \(summary.homeworkOnTime) of \(summary.homeworkDays) school days"
                )
            )
        }

        if summary.focusCompleted + summary.focusInterrupted > 0 {
            var value = "\(summary.focusCompleted) completed"
            if summary.focusInterrupted > 0 { value += " · \(summary.focusInterrupted) interrupted" }
            items.append(ActivitySummaryItem(key: "Focus Sessions", value: value))
        }

        items.append(ActivitySummaryItem(key: "Requests", value: requestsValue(summary)))

        if summary.freePassCount > 0 {
            items.append(
                ActivitySummaryItem(key: "Free Passes", value: "\(summary.freePassCount) · \(summary.freePassMinutes) min")
            )
        }

        items.append(ActivitySummaryItem(key: "Protection", value: protectionValue(summary)))
        return items
    }

    /// "2 · 1 approved, 1 partly approved".
    static func requestsValue(_ summary: ActivityWeeklySummary) -> String {
        guard summary.requestCount > 0 else { return "None" }
        let breakdown = [
            (summary.requestsApproved, "approved"),
            (summary.requestsPartiallyApproved, "partly approved"),
            (summary.requestsDeclined, "declined"),
            (summary.requestsExpired, "expired")
        ]
        .filter { $0.0 > 0 }
        .map { "\($0.0) \($0.1)" }
        .joined(separator: ", ")
        return "\(summary.requestCount) · \(breakdown)"
    }

    /// "Protected all week" when no change from Protected was recorded, otherwise
    /// "Sync pending on Tuesday".
    static func protectionValue(_ summary: ActivityWeeklySummary) -> String {
        guard !summary.protectionNotes.isEmpty else { return "Protected all week" }
        return summary.protectionNotes.map { "\($0.state.title) on \($0.weekday)" }.joined(separator: ", ")
    }

    // MARK: T-002 · this week's list

    /// Whether the approved frame shows the "which apps" note for this child (Sam's only).
    static func showsAppUsageNote(for child: ActivityChild) -> Bool {
        child == .sam
    }

    /// Sam's list is one row per school day, Monday first. Maya's is her requests and Focus
    /// Sessions, newest first. A child with resolved homework this week gets the school-day list.
    static func weekRows(for child: ActivityChild, snapshot: ActivitySnapshot) -> [ActivityListRow] {
        let scope = ActivityScope(child)
        let week = snapshot.events(for: scope).filter {
            ActivityPeriod.thisWeek.contains($0.occurredAt, reference: snapshot.referenceDate)
        }

        let schoolDays = week.filter { $0.category == .task && $0.taskTiming != nil }
        if !schoolDays.isEmpty {
            return schoolDays.sorted { $0.occurredAt < $1.occurredAt }.map(schoolDayRow)
        }

        return week.filter { $0.category == .request || $0.category == .session }.map(outcomeRow)
    }

    /// "Monday" · "Homework approved 5:52 PM" · Approved. A timing-unverified day reads
    /// "Approved, timing unverified" and is never restated as on time or late.
    private static func schoolDayRow(_ event: ActivityEvent) -> ActivityListRow {
        ActivityListRow(
            id: event.id,
            title: ActivityCalendar.weekdayName(event.occurredAt),
            subtitle: event.weekdayText ?? event.outcome.label,
            status: event.taskTiming == .timingUnverified ? ThemisStatus.approved : event.outcome,
            detailEventID: event.timing == nil ? nil : event.id
        )
    }

    /// "Instagram · 15 min" · "Tuesday · partly approved" · Partially approved.
    private static func outcomeRow(_ event: ActivityEvent) -> ActivityListRow {
        let weekday = ActivityCalendar.weekdayName(event.occurredAt)
        let subtitle = event.category == .request ? "\(weekday) · \(outcomePhrase(event.outcome))" : weekday
        return ActivityListRow(id: event.id, title: event.title, subtitle: subtitle, status: event.outcome, detailEventID: nil)
    }

    private static func outcomePhrase(_ outcome: ThemisStatus) -> String {
        outcome.kind == .partiallyApproved ? "partly approved" : outcome.label.lowercased()
    }

    // MARK: T-003 · rule changes

    /// Rule changes grouped by month, newest first. "Due time 5:30 → 6:00 PM · Sarah · 12 Sep",
    /// or the child's name when there is no change summary: "Sam · Alex · 3 Sep".
    static func ruleChangeSections(snapshot: ActivitySnapshot) -> [ActivityRowSection] {
        var sections: [ActivityRowSection] = []
        for event in snapshot.events(for: .all, categories: [.rule]) {
            let key = ActivityCalendar.monthKey(event.occurredAt)
            let subtitle = [event.detail ?? event.child.firstName, event.resolver, ActivityCalendar.dayMonthText(event.occurredAt)]
                .compactMap { $0 }
                .joined(separator: " · ")
            let row = ActivityListRow(id: event.id, title: event.title, subtitle: subtitle, status: nil, detailEventID: nil)
            if let last = sections.last, last.id == key {
                sections[sections.count - 1] = ActivityRowSection(id: key, title: last.title, rows: last.rows + [row])
            } else {
                sections.append(ActivityRowSection(id: key, title: ActivityCalendar.monthName(event.occurredAt), rows: [row]))
            }
        }
        return sections
    }

    // MARK: T-004 · requests

    /// "Instagram · 15 min" · "Maya · Tue 10:04 PM" · Partially approved. Older requests read
    /// "last week", then a date.
    static func requestRows(scope: ActivityScope, snapshot: ActivitySnapshot) -> [ActivityListRow] {
        snapshot.events(for: scope, categories: [.request]).map { event in
            ActivityListRow(
                id: event.id,
                title: event.title,
                subtitle: "\(event.child.firstName) · \(requestWhen(event, reference: snapshot.referenceDate))",
                status: event.outcome,
                detailEventID: nil
            )
        }
    }

    static func requestWhen(_ event: ActivityEvent, reference: Date) -> String {
        if ActivityPeriod.thisWeek.contains(event.occurredAt, reference: reference) {
            return ActivityCalendar.shortWeekdayTime(event.occurredAt)
        }
        if ActivityPeriod.lastWeek.contains(event.occurredAt, reference: reference) {
            return "last week"
        }
        return ActivityCalendar.dayMonthText(event.occurredAt)
    }

    // MARK: T-005 · protection

    /// "Now": each device's current protection with when it was last verified.
    static func protectionNowRows(snapshot: ActivitySnapshot) -> [ActivityListRow] {
        snapshot.protectionNow.map { now in
            ActivityListRow(id: "now-\(now.id)", title: now.child.deviceName, subtitle: now.evidence, status: now.status, detailEventID: nil)
        }
    }

    /// "Earlier": recorded changes, newest first. "Sam · Mon 7:10 PM · fixed 7:24 PM".
    static func protectionEarlierRows(snapshot: ActivitySnapshot) -> [ActivityListRow] {
        snapshot.events(for: .all, categories: [.protection]).map { event in
            let subtitle = [event.child.firstName, event.detail].compactMap { $0 }.joined(separator: " · ")
            return ActivityListRow(id: event.id, title: event.title, subtitle: subtitle, status: event.outcome, detailEventID: nil)
        }
    }
}
