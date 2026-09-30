import SwiftUI

/// Shared model for `AgreementTimeline` and its accessibility fallback `StackedTimelineList`.
///
/// Times are minutes from midnight on the timeline's first day; values past 1440 run
/// into the next morning (bedtime until 7 AM). A band that ends after the visible
/// range is open-ended ("From 8:30 PM").
struct AgreementTimelineModel: Equatable, Sendable {
    struct Band: Identifiable, Equatable, Sendable {
        let id: String
        let label: String
        let startMinute: Int
        let endMinute: Int
        let tone: ThemisTone
        /// Dashed outline: an outcome that only happens if it applies ("Games pause if not approved").
        var isConditional: Bool = false
        /// Vertical lane, for overlapping bands.
        var lane: Int = 0

        init(
            _ label: String,
            from startMinute: Int,
            to endMinute: Int,
            tone: ThemisTone,
            isConditional: Bool = false,
            lane: Int = 0
        ) {
            self.id = "\(label)-\(startMinute)-\(lane)"
            self.label = label
            self.startMinute = startMinute
            self.endMinute = endMinute
            self.tone = tone
            self.isConditional = isConditional
            self.lane = lane
        }
    }

    struct StackedRow: Identifiable, Equatable, Sendable {
        enum Marker: Equatable, Sendable {
            case now
            case band(ThemisTone)
        }

        let id: String
        let title: String
        let detail: String
        let marker: Marker
    }

    /// Visible range.
    let startMinute: Int
    let endMinute: Int
    /// Tick labels, spread evenly across the range ("4 PM", "6", "8 PM").
    let ticks: [String]
    let bands: [Band]
    /// Current time marker, if shown.
    var nowMinute: Int? = nil
    /// Marker pill text. Defaults to "Now".
    var nowLabel: String = "Now"

    var laneCount: Int { (bands.map(\.lane).max() ?? 0) + 1 }

    /// Horizontal position of a minute within the visible range, 0…1 (not clamped).
    func fraction(of minute: Int) -> Double {
        guard endMinute > startMinute else { return 0 }
        return Double(minute - startMinute) / Double(endMinute - startMinute)
    }

    func isOpenEnded(_ band: Band) -> Bool { band.endMinute > endMinute }

    /// The same information as rows, in time order, with the now marker first.
    var stackedRows: [StackedRow] {
        var rows: [StackedRow] = []
        if let nowMinute {
            rows.append(
                StackedRow(
                    id: "now",
                    title: nowLabel == "Today" ? "Today" : "Now",
                    detail: Self.format(minute: nowMinute),
                    marker: .now
                )
            )
        }
        for band in bands.sorted(by: { $0.startMinute < $1.startMinute }) {
            var detail = isOpenEnded(band)
                ? "From \(Self.format(minute: band.startMinute))"
                : "\(Self.format(minute: band.startMinute)) – \(Self.format(minute: band.endMinute))"
            if band.isConditional {
                detail += " · only if it applies"
            }
            rows.append(StackedRow(id: band.id, title: band.label, detail: detail, marker: .band(band.tone)))
        }
        return rows
    }

    /// "4 PM", "5:40 PM", "12 AM". Rounded to the nearest five minutes, as drawn.
    static func format(minute: Int) -> String {
        let rounded = Int((Double(minute) / 5).rounded()) * 5
        let dayMinute = ((rounded % 1440) + 1440) % 1440
        let hour24 = dayMinute / 60
        let minutes = dayMinute % 60
        let meridiem = hour24 >= 12 ? "PM" : "AM"
        let hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12
        let time = minutes == 0 ? "\(hour12)" : "\(hour12):" + String(format: "%02d", minutes)
        return "\(time) \(meridiem)"
    }

    /// One sentence for VoiceOver when the graphical timeline is shown.
    var accessibilitySummary: String {
        stackedRows.map { "\($0.title), \($0.detail)" }.joined(separator: ". ")
    }
}

/// `AgreementTimeline` · the Themis brand motif: an evening drawn as time bands.
///
/// At accessibility text sizes it becomes `StackedTimelineList` automatically,
/// because band labels no longer fit. `revealProgress` drives the Welcome story
/// reveal (P-002); leave it at 1 everywhere else.
struct AgreementTimeline: View {
    let model: AgreementTimelineModel
    /// Draw bands on white, for use inside a tinted task panel.
    var onPanel: Bool = false
    /// 0…1. See `ThemisMotion.reveal*`.
    var revealProgress: Double = 1

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            StackedTimelineList(model: model, onPanel: onPanel)
        } else {
            graphical
        }
    }

    private static let laneHeight: CGFloat = 48
    private static let bandHeight: CGFloat = 40

    private var graphical: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(Array(model.ticks.enumerated()), id: \.offset) { index, tick in
                    if index > 0 { Spacer(minLength: 4) }
                    Text(tick)
                }
            }
            .font(.system(size: 11, weight: .bold))
            .tracking(11 * 0.06)
            .foregroundStyle(ThemisColor.textTertiary)
            .padding(.bottom, 8)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(onPanel ? ThemisColor.textPrimary.opacity(0.12) : ThemisColor.borderControl)
                    .frame(height: ThemisBorder.hairline)
            }

            GeometryReader { proxy in
                let width = proxy.size.width
                ZStack(alignment: .topLeading) {
                    ForEach(Array(model.bands.enumerated()), id: \.element.id) { index, band in
                        bandView(band, index: index, width: width)
                    }
                    if let nowMinute = model.nowMinute {
                        nowMarker(at: nowMinute, width: width, height: proxy.size.height)
                    }
                }
                .frame(width: width, height: proxy.size.height, alignment: .topLeading)
                .clipped()
            }
            .frame(height: CGFloat(model.laneCount) * Self.laneHeight + (model.nowMinute == nil ? 6 : 30))
        }
        .padding(.top, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilitySummary)
    }

    @ViewBuilder
    private func bandView(_ band: AgreementTimelineModel.Band, index: Int, width: CGFloat) -> some View {
        let reveal = ThemisMotion.easeOutCubic(
            (revealProgress - Double(index) * ThemisMotion.revealBandStagger) / ThemisMotion.revealBandLength
        )
        let startX = CGFloat(model.fraction(of: band.startMinute)) * width
        let openEnded = model.isOpenEnded(band)
        let endFraction = min(model.fraction(of: band.endMinute), 1)
        let fullWidth = openEnded
            ? max(width - startX, 0)
            : max(CGFloat(endFraction) * width - startX, 0)
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 20,
            bottomLeadingRadius: 20,
            bottomTrailingRadius: openEnded ? 0 : 20,
            topTrailingRadius: openEnded ? 0 : 20,
            style: .continuous
        )

        HStack(spacing: 7) {
            Circle()
                .fill(band.tone.dot)
                .frame(width: 7, height: 7)
            Text(band.label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ThemisColor.textPrimary)
                .lineLimit(1)
                .opacity(reveal > ThemisMotion.revealLabelThreshold ? 1 : 0)
        }
        .padding(.horizontal, 12)
        .frame(width: fullWidth * CGFloat(reveal), height: Self.bandHeight, alignment: .leading)
        .background(bandFill(band), in: shape)
        .overlay {
            if band.isConditional {
                shape.stroke(band.tone.dot, style: StrokeStyle(lineWidth: ThemisBorder.conditional, dash: [5, 4]))
            }
        }
        .clipShape(shape)
        .opacity(reveal > 0 ? 1 : 0)
        .offset(x: startX, y: CGFloat(band.lane) * Self.laneHeight + 6)
    }

    private func bandFill(_ band: AgreementTimelineModel.Band) -> Color {
        if onPanel {
            return band.isConditional ? Color.white.opacity(0.65) : Color.white
        }
        return band.isConditional ? Color.white : band.tone.band
    }

    @ViewBuilder
    private func nowMarker(at minute: Int, width: CGFloat, height: CGFloat) -> some View {
        let settle = ThemisMotion.easeOutCubic(
            (revealProgress - ThemisMotion.revealMarkerStart) / (1 - ThemisMotion.revealMarkerStart)
        )
        let x = (CGFloat(model.fraction(of: minute)) - CGFloat(1 - settle) * 0.03) * width

        Rectangle()
            .fill(ThemisColor.brandSecondary)
            .frame(width: 1.5, height: max(height - 24, 0))
            .offset(x: x)
            .opacity(settle)
        Text(model.nowLabel)
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(ThemisColor.textOnPrimary)
            .padding(.vertical, 3)
            .padding(.horizontal, 7)
            .background(ThemisColor.brandSecondary, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .fixedSize()
            .alignmentGuide(.leading) { $0.width / 2 }
            .offset(x: x, y: height - 20)
            .opacity(settle)
    }
}

/// `StackedTimelineList` · the timeline as rows, used at accessibility sizes.
struct StackedTimelineList: View {
    let model: AgreementTimelineModel
    var onPanel: Bool = false

    @Environment(\.themisAudience) private var audience
    @Environment(\.themisGround) private var ground

    var body: some View {
        let rows = model.stackedRows
        VStack(spacing: 0) {
            ForEach(rows) { row in
                if row.id != rows.first?.id {
                    Rectangle().fill(ThemisColor.borderHairline).frame(height: ThemisBorder.hairline)
                }
                HStack(alignment: .firstTextBaseline, spacing: ThemisSpacing.inline12) {
                    Circle()
                        .fill(color(for: row.marker))
                        .frame(width: 10, height: 10)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.title)
                            .themisFont(.rowTitle)
                            .foregroundStyle(ThemisColor.textPrimary)
                        Text(row.detail)
                            .themisFont(.secondary)
                            .fontWeight(.semibold)
                            .foregroundStyle(ThemisColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, onPanel ? 14 : 16)
                .accessibilityElement(children: .combine)
            }
        }
        .background(
            onPanel ? Color.white.opacity(0.7) : ground.surface,
            in: RoundedRectangle(cornerRadius: onPanel ? ThemisRadius.inner : audience.cardRadius, style: .continuous)
        )
    }

    private func color(for marker: AgreementTimelineModel.StackedRow.Marker) -> Color {
        switch marker {
        case .now: return ThemisColor.brandSecondary
        case let .band(tone): return tone.dot
        }
    }
}

#Preview("Timeline") {
    let model = AgreementTimelineModel(
        startMinute: 16 * 60,
        endMinute: 22 * 60,
        ticks: ["4 PM", "6", "8", "10 PM"],
        bands: [
            .init("Homework", from: 16 * 60, to: 18 * 60, tone: .aqua),
            .init("Bedtime", from: 20 * 60 + 30, to: 31 * 60, tone: .peach)
        ],
        nowMinute: 17 * 60 + 10
    )
    return VStack(spacing: 24) {
        AgreementTimeline(model: model)
        StackedTimelineList(model: model)
    }
    .padding(ThemisSpacing.screen)
    .themisGround(.plain)
}
