import Foundation

// UI-10 Activity (T-001 to T-006).
//
// Reporting model (docs/22_REPORTING_AND_ANALYTICS.md §22.2):
// - Category A, Themis-owned outcomes, is modelled here as `ActivityEvent`, and may be
//   counted (weekly summaries) because every figure comes from Themis-owned events.
// - Category B, Apple-owned Screen Time activity, is deliberately NOT modelled.
//   `AppleScreenTimeReportState` carries availability only: no usage records, bundle
//   identifiers, domains or minutes. The underlying data never leaves Apple's
//   report-extension sandbox, and no summary here ever includes it.

/// The Themis-owned event categories Activity can show. Nothing else.
enum ActivityCategory: String, CaseIterable, Sendable {
    case rule
    case task
    case request
    case temporaryAccess
    case protection
    case session
}

enum ActivityChild: String, CaseIterable, Identifiable, Hashable, Sendable {
    case sam
    case maya

    var id: String { rawValue }

    var firstName: String {
        switch self {
        case .sam: return "Sam"
        case .maya: return "Maya"
        }
    }

    var segment: ExperienceSegment {
        switch self {
        case .sam: return .child
        case .maya: return .teen
        }
    }

    /// "Sam · Child".
    var title: String { "\(firstName) · \(segment.rawValue)" }

    var initial: String { String(firstName.prefix(1)) }

    var tone: ThemisTone {
        switch self {
        case .sam: return .aqua
        case .maya: return .peach
        }
    }

    /// "Sam’s iPhone".
    var deviceName: String { "\(firstName)’s iPhone" }
}

/// Presentation-only filter (T-004). It never changes what is stored.
enum ActivityScope: String, CaseIterable, Identifiable, Hashable, Sendable {
    case all
    case sam
    case maya

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .sam: return "Sam"
        case .maya: return "Maya"
        }
    }

    var child: ActivityChild? {
        switch self {
        case .all: return nil
        case .sam: return .sam
        case .maya: return .maya
        }
    }

    func includes(_ other: ActivityChild) -> Bool {
        child == nil || child == other
    }

    init(_ child: ActivityChild) {
        switch child {
        case .sam: self = .sam
        case .maya: self = .maya
        }
    }
}

/// The T-001 period selector. Weeks run Monday to Sunday.
enum ActivityPeriod: String, CaseIterable, Identifiable, Hashable, Sendable {
    case thisWeek
    case lastWeek

    var id: String { rawValue }

    var title: String {
        switch self {
        case .thisWeek: return "This week"
        case .lastWeek: return "Last week"
        }
    }

    func contains(_ date: Date, reference: Date) -> Bool {
        let start = ActivityCalendar.weekStart(of: reference)
        switch self {
        case .thisWeek:
            return date >= start && date < ActivityCalendar.adding(days: 7, to: start)
        case .lastWeek:
            return date >= ActivityCalendar.adding(days: -7, to: start) && date < start
        }
    }
}

/// How a task's submission timing was established. A timing-unverified task is never
/// counted as on time and never labelled late.
enum TaskTimingOutcome: Equatable, Sendable {
    case onTime
    case afterDeadline
    case timingUnverified
}

/// Both times shown when timing could not be verified. Neither is treated as true:
/// Activity never rewrites the history as on time or late.
struct TimingEvidence: Equatable, Sendable {
    /// Submission time claimed by the child's device.
    let claimedByChildDevice: Date
    /// Time the Themis server received the submission.
    let serverReceived: Date

    var claimedText: String { ActivityCalendar.timeText(claimedByChildDevice) }
    var serverReceivedText: String { ActivityCalendar.timeText(serverReceived) }
}

/// Reusable outcome chips for Activity, built from the existing status kinds so glyph
/// and tone stay in the shared status system.
enum ActivityStatus {
    /// Wednesday-style approval that came after the deadline (T-002 frame chip).
    static let afterDeadline = ThemisStatus(.overdue, label: "After 6:00")
    static let granted = ThemisStatus(.freePassActive, label: "Granted")
    static let interrupted = ThemisStatus(.expired, label: "Interrupted")
    static let fixed = ThemisStatus(.needsAttention, label: "Fixed")
    static let reconnected = ThemisStatus(.deviceOffline, label: "Reconnected")
    static let edited = ThemisStatus(.resolved, label: "Edited")
    static let created = ThemisStatus(.resolved, label: "Created")
}

/// One Themis-owned outcome, already resolved elsewhere. Activity displays it and
/// offers no actions.
struct ActivityEvent: Identifiable, Equatable, Sendable {
    let id: String
    let child: ActivityChild
    let occurredAt: Date
    let category: ActivityCategory
    let title: String
    /// Outcome with its glyph and label. Never colour only.
    let outcome: ThemisStatus
    let detail: String?
    /// Who resolved, granted or changed it, where relevant ("Sarah").
    let resolver: String?
    /// Present only when timing could not be verified.
    var timing: TimingEvidence? = nil
    /// Set on the event that resolves a school-day task (counts toward "on time").
    var taskTiming: TaskTimingOutcome? = nil
    /// Text for the child's weekday list (T-002), as drawn in the approved frame.
    var weekdayText: String? = nil
    /// Length of a Free Pass or Focus Session.
    var durationMinutes: Int? = nil
    /// Protection state a protection event records.
    var protectionState: ProtectionStatus? = nil

    /// "Resolved by Sarah" / "Granted by Sarah" / "Changed by Sarah".
    var resolverText: String? {
        guard let resolver else { return nil }
        switch category {
        case .temporaryAccess: return "Granted by \(resolver)"
        case .rule: return "Changed by \(resolver)"
        default: return "Resolved by \(resolver)"
        }
    }

    static func newestFirst(_ lhs: ActivityEvent, _ rhs: ActivityEvent) -> Bool {
        lhs.occurredAt != rhs.occurredAt ? lhs.occurredAt > rhs.occurredAt : lhs.id < rhs.id
    }
}

/// A device's current protection with the evidence for it. A status is never shown
/// without when it was last confirmed. No staleness threshold (OQ-19) lives here.
struct ProtectionNow: Identifiable, Equatable, Sendable {
    let child: ActivityChild
    let status: ThemisStatus
    /// "Verified 2 min ago".
    let evidence: String

    var id: String { child.id }
}

struct ActivityDayGroup: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let events: [ActivityEvent]
}

/// A protection state that was not Protected during a period.
struct ProtectionWeekNote: Equatable, Sendable {
    let state: ProtectionStatus
    let weekday: String
}

/// Weekly counts of Themis-owned outcomes (Category A only). Every field is derived from
/// `ActivityEvent`s. There are no scores, rankings or ratings, and Apple Screen Time
/// data cannot appear here because Themis never receives it.
struct ActivityWeeklySummary: Equatable, Sendable {
    let scope: ActivityScope
    let period: ActivityPeriod
    /// School days with a resolved homework task, and how many were on time.
    let homeworkDays: Int
    let homeworkOnTime: Int
    let requestsApproved: Int
    let requestsPartiallyApproved: Int
    let requestsDeclined: Int
    let requestsExpired: Int
    let focusCompleted: Int
    let focusInterrupted: Int
    let freePassCount: Int
    let freePassMinutes: Int
    let protectionNotes: [ProtectionWeekNote]

    var requestCount: Int {
        requestsApproved + requestsPartiallyApproved + requestsDeclined + requestsExpired
    }
}

/// Everything Category A for Activity. Apple report availability is deliberately not
/// part of it, so the two categories cannot share a container by construction.
struct ActivitySnapshot: Equatable, Sendable {
    /// Fixed "now" so the demo is deterministic.
    let referenceDate: Date
    let events: [ActivityEvent]
    let protectionNow: [ProtectionNow]

    /// Newest first, ties broken by id.
    func events(for scope: ActivityScope, categories: Set<ActivityCategory>? = nil) -> [ActivityEvent] {
        events
            .filter { scope.includes($0.child) && (categories?.contains($0.category) ?? true) }
            .sorted(by: ActivityEvent.newestFirst)
    }

    func event(id: String) -> ActivityEvent? {
        events.first { $0.id == id }
    }

    /// Weekly counts for a scope and period. Category A events only.
    func summary(for scope: ActivityScope, period: ActivityPeriod) -> ActivityWeeklySummary {
        let inPeriod = events(for: scope).filter { period.contains($0.occurredAt, reference: referenceDate) }
        let tasks = inPeriod.filter { $0.category == .task && $0.taskTiming != nil }
        let requests = inPeriod.filter { $0.category == .request }
        let sessions = inPeriod.filter { $0.category == .session }
        let passes = inPeriod.filter { $0.category == .temporaryAccess }
        let notes = inPeriod
            .filter { $0.category == .protection && $0.protectionState != nil && $0.protectionState != .protected }
            .sorted { $0.occurredAt < $1.occurredAt }
            .compactMap { event -> ProtectionWeekNote? in
                guard let state = event.protectionState else { return nil }
                return ProtectionWeekNote(state: state, weekday: ActivityCalendar.weekdayName(event.occurredAt))
            }

        return ActivityWeeklySummary(
            scope: scope,
            period: period,
            homeworkDays: tasks.count,
            homeworkOnTime: tasks.filter { $0.taskTiming == .onTime }.count,
            requestsApproved: requests.filter { $0.outcome.kind == .approved }.count,
            requestsPartiallyApproved: requests.filter { $0.outcome.kind == .partiallyApproved }.count,
            requestsDeclined: requests.filter { $0.outcome.kind == .declined }.count,
            requestsExpired: requests.filter { $0.outcome.kind == .expired }.count,
            focusCompleted: sessions.filter { $0.outcome == .completed }.count,
            focusInterrupted: sessions.filter { $0.outcome == ActivityStatus.interrupted }.count,
            freePassCount: passes.count,
            freePassMinutes: passes.compactMap(\.durationMinutes).reduce(0, +),
            protectionNotes: notes
        )
    }

    /// Consecutive events on the same day, in the order given.
    func dayGroups(for events: [ActivityEvent]) -> [ActivityDayGroup] {
        var groups: [ActivityDayGroup] = []
        for event in events {
            let key = ActivityCalendar.dayKey(event.occurredAt)
            if let last = groups.last, last.id == key {
                groups[groups.count - 1] = ActivityDayGroup(id: key, title: last.title, events: last.events + [event])
            } else {
                groups.append(
                    ActivityDayGroup(
                        id: key,
                        title: ActivityCalendar.dayLabel(for: event.occurredAt, relativeTo: referenceDate),
                        events: [event]
                    )
                )
            }
        }
        return groups
    }
}

/// Availability and presentation of Apple's own Screen Time report (T-006).
///
/// This carries NO usage data. Raw app and website usage stays inside Apple's
/// `DeviceActivityReport` sandbox, and whether it renders on the parent's iPhone is
/// still the Priority 8 real-device spike.
enum AppleScreenTimeReportState: String, CaseIterable, Sendable {
    /// Review state: the bounded, Apple-owned area where Apple's report would appear.
    case systemOwnedReportArea
    /// Apple's report isn't available on this device right now.
    case unavailable
}

/// Retention periods confirmed in docs/23_PRIVACY_AND_CHILD_SAFETY.md §23.5. Copy only:
/// Activity offers no retention controls or deletion.
enum ActivityRetention {
    /// Structured Rule/Task/Request/Grant/completed Session history: 12-month rolling.
    static let structuredHistoryMonths = 12
    /// Free-text request reasons, clarification text and rejection notes: 90-day rolling.
    /// Structured outcome metadata is kept under the 12-month period, not this one.
    static let freeTextDays = 90

    /// T-003.
    static let ruleChangesFooter = "Shows the last \(structuredHistoryMonths) months."
    /// T-004. Outcomes keep the 12-month period; only reasons and notes are removed at 90 days.
    static let requestsFooter =
        "Outcomes are kept for \(structuredHistoryMonths) months. Reasons and notes are removed after \(freeTextDays) days."
}

/// T-006 copy, as drawn in the approved frames.
enum AppleScreenTimeCopy {
    /// Navigation title.
    static let title = "Screen Time"
    static let sectionLabel = "Shown by Apple"
    /// T-001 row.
    static let overviewTitle = "Screen Time reports"
    static let overviewSubtitle = "Drawn by Apple on this iPhone"
    /// T-002 link.
    static let childLinkTitle = "Open Apple’s Screen Time report"
    static let areaLabel = "Apple-owned report area"
    static let areaTitle = "Apple Screen Time report"
    static let areaDetail = "Rendered by Apple. What appears depends on Apple and the device."
    static let availableNotice = "Apple draws this report on this iPhone. Themis can’t read, store or share it."
    static let separation = "Themis activity (tasks, requests, passes, protection) is separate and stays in the Activity tab."
    static let backLink = "Back to Themis activity"
    static let unavailableNotice = "Apple’s report isn’t available on this iPhone right now."
    static let unavailableSupport = "This depends on Apple and the device. Themis activity is still available in the Activity tab."

    /// Every sentence shown for a state, for copy checks.
    static func allCopy(for state: AppleScreenTimeReportState) -> [String] {
        switch state {
        case .systemOwnedReportArea:
            return [title, sectionLabel, availableNotice, areaLabel, areaTitle, areaDetail, separation, backLink]
        case .unavailable:
            return [title, sectionLabel, unavailableNotice, unavailableSupport]
        }
    }
}

/// Static Activity copy outside T-006 and retention.
enum ActivityCopy {
    static let overviewFooter = "Activity shows what happened with your family’s Themis rules. It isn’t a record of everything your children do."
    static let emptyTitle = "No activity yet"
    static let emptyMessage = "Activity appears after the first day with Themis."
    static let loadError = "We couldn’t load your activity right now."
    static let timingExplanation = "Themis could not verify which submission time should be trusted."

    static func appUsageNote(for child: ActivityChild) -> String {
        "Themis doesn’t show which apps \(child.firstName) used or for how long."
    }
}

/// Navigation targets inside the Activity stack.
enum ActivityRoute: Hashable, Sendable {
    case child(ActivityChild)
    case ruleChanges
    case requestHistory
    case protectionHistory
    case appleScreenTime
    case eventDetail(String)
}

/// Fixed-calendar formatting so demo output never depends on the device's locale or
/// time zone. UTC, Gregorian, 12-hour clock as drawn ("5:48 PM"), weeks start Monday.
enum ActivityCalendar {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }()

    private static let weekdayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    private static let weekdayShortNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private static let monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    private static let monthShortNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }

    static func adding(days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }

    /// Start of the Monday on or before `date`.
    static func weekStart(of date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date) // Sunday = 1
        let daysSinceMonday = (weekday + 5) % 7
        return adding(days: -daysSinceMonday, to: calendar.startOfDay(for: date))
    }

    /// "5:48 PM".
    static func timeText(_ date: Date) -> String {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        let hour24 = parts.hour ?? 0
        let minute = parts.minute ?? 0
        let hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12
        return "\(hour12):" + String(format: "%02d", minute) + (hour24 >= 12 ? " PM" : " AM")
    }

    /// "Tuesday".
    static func weekdayName(_ date: Date) -> String {
        weekdayNames[calendar.component(.weekday, from: date) - 1]
    }

    /// "Tue 10:04 PM".
    static func shortWeekdayTime(_ date: Date) -> String {
        weekdayShortNames[calendar.component(.weekday, from: date) - 1] + " " + timeText(date)
    }

    /// "September".
    static func monthName(_ date: Date) -> String {
        monthNames[calendar.component(.month, from: date) - 1]
    }

    /// "12 Sep".
    static func dayMonthText(_ date: Date) -> String {
        let parts = calendar.dateComponents([.day, .month], from: date)
        return "\(parts.day ?? 1) \(monthShortNames[(parts.month ?? 1) - 1])"
    }

    /// Stable key for grouping by day.
    static func dayKey(_ date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 0)-" + String(format: "%02d", parts.month ?? 0) + "-" + String(format: "%02d", parts.day ?? 0)
    }

    /// Stable key for grouping by month.
    static func monthKey(_ date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month], from: date)
        return "\(parts.year ?? 0)-" + String(format: "%02d", parts.month ?? 0)
    }

    /// "Today", "Yesterday", a weekday within the last week, otherwise "26 Sep".
    static func dayLabel(for date: Date, relativeTo reference: Date) -> String {
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: reference)
        ).day ?? 0
        switch days {
        case 0: return "Today"
        case 1: return "Yesterday"
        case 2...6: return weekdayName(date)
        default: return dayMonthText(date)
        }
    }
}
