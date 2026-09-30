import Foundation

enum ChildTeenHomeDemoData {
    static let sam = ChildTeenHomeState(
        screenID: "C-001",
        audience: .child,
        firstName: "Sam",
        dayLabel: nil,
        activeStatus: .active,
        transparencyLinkTitle: "What can my parent or carer see?",
        content: .childHomework(
            ChildHomeworkHomeState(
                sectionTitle: "Homework",
                status: .due,
                dueText: "Due at 6:00 PM",
                timeline: AgreementTimelineModel(
                    startMinute: 16 * 60,
                    endMinute: 20 * 60,
                    ticks: ["4 PM", "6", "8 PM"],
                    bands: [
                        .init("Homework", from: 16 * 60, to: 18 * 60, tone: .aqua),
                        .init(
                            "Games pause if not approved",
                            from: 18 * 60,
                            to: 21 * 60,
                            tone: .peach,
                            isConditional: true
                        )
                    ],
                    nowMinute: 17 * 60 + 40
                ),
                consequence: "If it isn’t done by 6:00 PM, Roblox and Minecraft pause.",
                primaryActionTitle: "I’ve finished my homework",
                secondaryActionTitle: "Ask for more time"
            )
        ),
        transparency: childTransparency,
        essentialAccess: childEssentialAccess
    )

    static let maya = ChildTeenHomeState(
        screenID: "C-001 · Teen",
        audience: .teen,
        firstName: "Maya",
        dayLabel: "Tuesday",
        activeStatus: .active,
        transparencyLinkTitle: "What your parent or carer can see",
        content: .teen(
            TeenHomeState(
                nowSectionTitle: "Now",
                scheduleTitle: "Social apps",
                scheduleSummary: "Pause 10:00 PM–7:00 AM",
                scheduleStatus: ThemisStatus(.active, label: "Tonight"),
                eveningTimeline: AgreementTimelineModel(
                    startMinute: 20 * 60,
                    endMinute: 24 * 60,
                    ticks: ["8 PM", "10", "12 AM"],
                    bands: [
                        .init(
                            "Social apps pause",
                            from: 22 * 60,
                            to: 31 * 60,
                            tone: .cobalt
                        )
                    ],
                    nowMinute: 21 * 60 + 15
                ),
                todaySectionTitle: "Today",
                focusTitle: "Focus Session",
                focusSummary: "30 min away from distracting apps",
                startActionTitle: "Start",
                requestActionTitle: "Request more time"
            )
        ),
        transparency: teenTransparency,
        essentialAccess: teenEssentialAccess
    )

    static let childTransparency = TransparencyState(
        screenID: "C-013",
        title: "What can my parent or carer see?",
        intro: "Themis is designed to make family rules clear without showing private conversations.",
        visibleSectionTitle: "Your parent can see",
        visibleFacts: [
            "Your Themis rules",
            "If homework was done",
            "Your requests and answers",
            "Extra time they gave you",
            "If Themis is working",
            "Some Screen Time information Apple makes available where supported"
        ],
        privateSectionTitle: "Themis does not show them",
        privateFacts: [
            "Your messages or chats",
            "Everything you search or visit",
            "A minute-by-minute activity list"
        ]
    )

    static let teenTransparency = TransparencyState(
        screenID: "C-013 · Teen",
        title: "What your parent or carer can see",
        intro: "Themis shares the information needed to run your family agreement, not the content of your private conversations.",
        visibleSectionTitle: "Visible to your parent or carer",
        visibleFacts: [
            "Rules and task outcomes",
            "Requests and decisions",
            "Temporary access",
            "Device protection status",
            "Screen Time reports Apple provides where available"
        ],
        privateSectionTitle: "Not provided by Themis",
        privateFacts: [
            "Message or chat content",
            "Full browsing or search history",
            "Minute-by-minute activity",
            "Apple raw Screen Time data"
        ]
    )

    static let childEssentialAccess = EssentialAccessState(
        screenID: "C-014",
        title: "Essential access",
        intro: "School and important access are considered when your family sets up rules.",
        facts: [
            "Always Allowed and school access are set by your parent or carer.",
            "Phone, Messages and Maps can be configured to stay available where supported.",
            "Emergency calling and iPhone emergency features are never deliberately restricted by Themis.",
            "Themis does not claim to filter the content inside those apps."
        ]
    )

    static let teenEssentialAccess = EssentialAccessState(
        screenID: "C-014 · Teen",
        title: "Essential access",
        intro: "Family rules can preserve configured school and essential access without claiming control Apple does not provide.",
        facts: [
            "Always Allowed and school access are parent-configured.",
            "Phone, Messages and Maps are recommended or configured where supported, not technically guaranteed until the Apple spike is resolved.",
            "Emergency calling and OS emergency functionality are never deliberately restricted by Themis.",
            "Themis does not claim deep content filtering inside essential apps."
        ]
    )

    static func state(childID: UUID, scenario: DemoScenario) -> ChildTeenHomeState {
        // UI-03 implements the canonical Child and Teen homes only. Later task, request,
        // Free Pass and restriction scenarios stay in DemoData for their owning slices.
        childID == DemoData.mayaID ? maya : sam
    }
}
