import SwiftUI
import UIKit
import XCTest
@testable import ThemisFamily

final class StatusSystemTests: XCTestCase {
    /// The approved status list from the UI-01 brief and the handoff state matrix.
    private let approvedLabels = [
        "Protected", "Sync pending", "Device offline", "Needs attention", "Protection unavailable",
        "Not active yet", "Unconfirmed", "Due today", "Waiting", "Grace", "Overdue", "Approved",
        "Cleared", "Needs you", "Pending", "Needs your reply", "Partially approved", "Declined",
        "Expired", "Resolved", "Waiting to send", "Free Pass active", "Overridden", "Sending",
        "Access revoked", "Active", "Payment", "Cancelled", "Protection ended", "Applying",
        "Applied on device", "Removing", "Paused", "Completed", "Not finished",
        "Approved, timing unverified"
    ]

    func testEveryApprovedStatusIsAvailable() {
        let labels = Set(ThemisStatus.allApproved.map(\.label))
        for label in approvedLabels {
            XCTAssertTrue(labels.contains(label), "Missing approved status: \(label)")
        }
    }

    func testEveryStatusHasGlyphAndLabelNotJustColour() {
        for status in ThemisStatus.allApproved {
            XCTAssertFalse(status.label.trimmingCharacters(in: .whitespaces).isEmpty)
            XCTAssertFalse(status.kind.glyphSymbol.isEmpty, "\(status.label) has no glyph")
        }
        for kind in StatusKind.allCases {
            XCTAssertFalse(kind.defaultLabel.isEmpty)
            XCTAssertNotNil(UIImage(systemName: kind.glyphSymbol), "\(kind) glyph \(kind.glyphSymbol) is not an SF Symbol")
        }
    }

    func testProtectionStatesMapToDistinctKindsWithApprovedLabels() {
        let expected: [(ProtectionStatus, StatusKind, String)] = [
            (.protected, .protected, "Protected"),
            (.syncPending, .syncPending, "Sync pending"),
            (.deviceOffline, .deviceOffline, "Device offline"),
            (.needsAttention, .needsAttention, "Needs attention"),
            (.protectionUnavailable, .protectionUnavailable, "Protection unavailable")
        ]
        for (status, kind, label) in expected {
            XCTAssertEqual(status.statusKind, kind)
            XCTAssertEqual(status.title, label)
        }
        XCTAssertEqual(Set(expected.map { $0.0.statusKind }).count, 5)
    }

    func testUnconfirmedNeverReadsAsProtected() {
        XCTAssertEqual(ThemisStatus.unconfirmed.kind, .deviceOffline)
        XCTAssertNotEqual(ThemisStatus.unconfirmed.tone, StatusKind.protected.tone)
    }

    func testApprovedAndAppliedStayDistinct() {
        // Honest "Approved" versus "Applied on device" status.
        XCTAssertNotEqual(ThemisStatus.approved, ThemisStatus.appliedOnDevice)
        XCTAssertNotEqual(ThemisStatus.approved.tone, ThemisStatus.appliedOnDevice.tone)
        XCTAssertEqual(ThemisStatus.approvedTimingUnverified.kind, .approved)
        XCTAssertNotEqual(ThemisStatus.approvedTimingUnverified.label, "Approved")
    }

    func testTonesMatchTokenSheet() {
        XCTAssertEqual(StatusKind.protected.tone, .success)
        XCTAssertEqual(StatusKind.approved.tone, .successSoft)
        XCTAssertEqual(StatusKind.syncPending.tone, .info)
        XCTAssertEqual(StatusKind.needsAttention.tone, .warning)
        XCTAssertEqual(StatusKind.pending.tone, .pending)
        XCTAssertEqual(StatusKind.waiting.tone, .neutral)
        XCTAssertEqual(StatusKind.deviceOffline.tone, .offline)
        XCTAssertEqual(StatusKind.protectionUnavailable.tone, .unavailable)
        XCTAssertEqual(StatusKind.grace.tone, .grace)
        XCTAssertEqual(StatusKind.freePassActive.tone, .brand)
    }

    func testDarkFillsUseLightGlyphs() {
        XCTAssertTrue(StatusTone.unavailable.hasLightGlyph)
        XCTAssertTrue(StatusTone.brand.hasLightGlyph)
        XCTAssertTrue(StatusTone.error.hasLightGlyph)
        XCTAssertFalse(StatusTone.success.hasLightGlyph)
        XCTAssertFalse(StatusTone.warning.hasLightGlyph)
    }
}

final class AgreementTimelineModelTests: XCTestCase {
    private let evening = AgreementTimelineModel(
        startMinute: 16 * 60,
        endMinute: 20 * 60,
        ticks: ["4 PM", "6", "8 PM"],
        bands: [
            .init("Games pause if not approved", from: 18 * 60, to: 21 * 60, tone: .peach, isConditional: true),
            .init("Homework", from: 16 * 60, to: 18 * 60, tone: .aqua)
        ],
        nowMinute: 17 * 60 + 40
    )

    func testTimeFormattingMatchesDesign() {
        XCTAssertEqual(AgreementTimelineModel.format(minute: 16 * 60), "4 PM")
        XCTAssertEqual(AgreementTimelineModel.format(minute: 17 * 60 + 40), "5:40 PM")
        XCTAssertEqual(AgreementTimelineModel.format(minute: 24 * 60), "12 AM")
        XCTAssertEqual(AgreementTimelineModel.format(minute: 31 * 60), "7 AM")
        XCTAssertEqual(AgreementTimelineModel.format(minute: 12 * 60 + 2), "12 PM")
    }

    func testStackedRowsPutNowFirstThenTimeOrder() {
        let rows = evening.stackedRows
        XCTAssertEqual(rows.map(\.title), ["Now", "Homework", "Games pause if not approved"])
        XCTAssertEqual(rows[0].detail, "5:40 PM")
        XCTAssertEqual(rows[1].detail, "4 PM – 6 PM")
    }

    func testOpenEndedConditionalBandIsDescribedHonestly() {
        let games = evening.stackedRows.last
        XCTAssertEqual(games?.detail, "From 6 PM · only if it applies")
        XCTAssertTrue(evening.isOpenEnded(evening.bands[0]))
        XCTAssertFalse(evening.isOpenEnded(evening.bands[1]))
    }

    func testFractionAcrossRange() {
        XCTAssertEqual(evening.fraction(of: 16 * 60), 0)
        XCTAssertEqual(evening.fraction(of: 18 * 60), 0.5)
        XCTAssertEqual(evening.fraction(of: 20 * 60), 1)
    }

    func testAccessibilitySummaryCoversEveryRow() {
        XCTAssertEqual(
            evening.accessibilitySummary,
            "Now, 5:40 PM. Homework, 4 PM – 6 PM. Games pause if not approved, From 6 PM · only if it applies"
        )
    }

    func testTodayMarkerKeepsItsLabel() {
        var model = evening
        model.nowLabel = "Today"
        XCTAssertEqual(model.stackedRows.first?.title, "Today")
    }
}

final class DesignTokenTests: XCTestCase {
    func testAudienceMetricsMatchTokenSheet() {
        XCTAssertEqual(ThemisAudience.parent.buttonHeight, 52)
        XCTAssertEqual(ThemisAudience.teen.buttonHeight, 50)
        XCTAssertEqual(ThemisAudience.child.buttonHeight, 58)
        XCTAssertEqual(ThemisAudience.parent.cardRadius, 20)
        XCTAssertEqual(ThemisAudience.child.cardRadius, 24)
        XCTAssertEqual(ThemisAudience.teen.cardRadius, 18)
        XCTAssertEqual(ThemisAudience.child.buttonRadius, 18)
        XCTAssertEqual(ThemisAudience.parent.rowMinHeight, 52)
        XCTAssertEqual(ThemisAudience.child.rowMinHeight, 56)
        XCTAssertEqual(ThemisAudience(.child), .child)
        XCTAssertEqual(ThemisAudience(.teen), .teen)
    }

    func testTouchTargetsMeetMinimum() {
        for audience in ThemisAudience.allCases {
            XCTAssertGreaterThanOrEqual(audience.buttonHeight, 44)
            XCTAssertGreaterThanOrEqual(audience.rowMinHeight, 44)
        }
        XCTAssertGreaterThanOrEqual(ThemisSize.chipMinimum, 44)
        XCTAssertGreaterThanOrEqual(ThemisSize.tapMinimum, 44)
    }

    func testTypeScaleMatchesTokenSheet() {
        XCTAssertEqual(ThemisTextRole.body.size(for: .parent), 16)
        XCTAssertEqual(ThemisTextRole.body.size(for: .child), 17)
        XCTAssertEqual(ThemisTextRole.body.size(for: .teen), 15.5)
        XCTAssertEqual(ThemisTextRole.display.size(for: .parent), 34)
        XCTAssertEqual(ThemisTextRole.numeral.size(for: .child), 51)
        XCTAssertEqual(ThemisTextRole.pageTitle.size(for: .teen), 31)
        XCTAssertEqual(ThemisTextRole.button.size(for: .parent), 17)
        XCTAssertTrue(ThemisTextRole.sectionLabel.isUppercase)
        XCTAssertEqual(ThemisTextRole.pageTitle.textStyle, .largeTitle)
        XCTAssertEqual(ThemisTextRole.body.textStyle, .body)
    }

    func testReduceMotionAlternativesExist() {
        XCTAssertNil(ThemisMotion.animation(.statusChange, reduceMotion: true))
        XCTAssertNil(ThemisMotion.animation(.nowMarker, reduceMotion: true))
        XCTAssertNotNil(ThemisMotion.animation(.applicationMorph, reduceMotion: true))
        XCTAssertEqual(ThemisMotion.easeOutCubic(-1), 0)
        XCTAssertEqual(ThemisMotion.easeOutCubic(2), 1)
    }

    func testNoPurpleInThePalette() {
        var colours: [Color] = [
            ThemisColor.brandPrimary, ThemisColor.brandPrimaryPressed, ThemisColor.brandPrimaryTint,
            ThemisColor.brandSecondary, ThemisColor.textPrimary, ThemisColor.textSecondary,
            ThemisColor.textTertiary, ThemisColor.textDestructive, ThemisColor.backgroundGrouped,
            ThemisColor.backgroundChild, ThemisColor.borderElevated, ThemisColor.chevron
        ]
        colours += StatusTone.allCases.flatMap { [$0.fill, $0.tint] }
        colours += ThemisTone.allCases.flatMap { [$0.band, $0.dot, $0.panel] }

        for colour in colours {
            var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
            UIColor(colour).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            let degrees = hue * 360
            let isPurple = saturation > 0.25 && degrees > 250 && degrees < 330
            XCTAssertFalse(isPurple, "Purple-range colour in palette: hue \(degrees)")
        }
    }
}

final class NavigationShellTests: XCTestCase {
    func testParentTabsMatchApprovedInformationArchitecture() {
        XCTAssertEqual(ParentTab.allCases.map(\.title), ["Home", "Rules", "Activity", "Settings"])
        XCTAssertEqual(ParentTab.allCases.map(\.rootScreenID), ["P-023", "R-001", "T-001", "ST-001"])
    }

    func testChildAndTeenTabsMatchApprovedInformationArchitecture() {
        XCTAssertEqual(ChildTab.allCases.map(\.title), ["Home", "My Rules", "Requests"])
        XCTAssertEqual(ChildTab.allCases.map { $0.rootScreenID(for: .child) }, ["C-001", "C-015", "C-017"])
        XCTAssertEqual(ChildTab.allCases.map { $0.rootScreenID(for: .teen) }, ["C-001 · Teen", "C-015", "Q-001"])
    }

    func testTabSymbolsAreSystemSymbols() {
        for tab in ParentTab.allCases {
            XCTAssertNotNil(UIImage(systemName: tab.systemImage))
        }
        for tab in ChildTab.allCases {
            XCTAssertNotNil(UIImage(systemName: tab.systemImage))
        }
    }
}
