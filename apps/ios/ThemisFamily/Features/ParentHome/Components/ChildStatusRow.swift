import SwiftUI

/// `ChildStatusRow` · one child in the Children group: avatar, "Sam · Child",
/// last-verified evidence and the protection status chip.
///
/// Status and evidence are read together by VoiceOver so a status is never
/// announced without when it was last confirmed.
struct ChildStatusRow: View {
    let child: ChildStatusSummary

    var body: some View {
        ThemisRow(
            title: child.title,
            subtitle: child.evidenceText,
            status: child.status,
            avatar: (child.avatar.initial, child.avatar.tone),
            showsChevron: child.destination != nil
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(child.firstName), \(child.segment.rawValue)")
        .accessibilityValue("\(child.status.label). \(child.evidenceText)")
    }
}
