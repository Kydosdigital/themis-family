import SwiftUI

// MARK: - UI-13 Edge States · Previews
//
// Deterministic previews for every approved scenario (problem statement §33),
// plus accessibility3 previews for the six states called out explicitly:
// P-023 · Servers unreachable, A-002 · Timing, C-004 · Queued, Q-006 · Offline,
// C-001 · Permission, A-004 · Send failed.

#Preview("P-023 · Servers unreachable") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .serversUnreachable))
    }
}

#Preview("P-023 · Servers unreachable · AX3") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .serversUnreachable))
    }
    .dynamicTypeSize(.accessibility3)
}

#Preview("A-001 · Empty") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .actionCentreEmpty))
    }
}

#Preview("T-001 · Empty") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .activityEmpty))
    }
}

#Preview("A-002 · Timing") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .timingUnverified))
    }
}

#Preview("A-002 · Timing · AX3") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .timingUnverified))
    }
    .dynamicTypeSize(.accessibility3)
}

#Preview("A-002 · Timing approved") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .timingApproved))
    }
}

#Preview("A-002 · Timing ask") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .timingAsk))
    }
}

#Preview("T-002 · Timing") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .activityTiming))
    }
}

#Preview("C-004 · Timing") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .childTimingUnverified))
    }
}

#Preview("C-001 · Offline") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .childOffline))
    }
}

#Preview("C-004 · Queued") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .childQueuedOffline))
    }
}

#Preview("C-004 · Queued · AX3") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .childQueuedOffline))
    }
    .dynamicTypeSize(.accessibility3)
}

#Preview("Q-006 · Offline") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .requestSavedOffline))
    }
}

#Preview("Q-006 · Offline · AX3") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .requestSavedOffline))
    }
    .dynamicTypeSize(.accessibility3)
}

#Preview("C-001 · Permission") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .childPermissionNeeded))
    }
}

#Preview("C-001 · Permission · AX3") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .childPermissionNeeded))
    }
    .dynamicTypeSize(.accessibility3)
}

#Preview("C-001 · Removed") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .childDeviceRemoved))
    }
}

#Preview("P-010 · Interrupted") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .pairingInterrupted))
    }
}

#Preview("E-007 · Abandoned") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .sessionAbandoned))
    }
}

#Preview("A-004 · Send failed") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .decisionSendFailed))
    }
}

#Preview("A-004 · Send failed · AX3") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .decisionSendFailed))
    }
    .dynamicTypeSize(.accessibility3)
}

#Preview("P-012 · External revoke") {
    NavigationStack {
        EdgeStateView(presentation: EdgeStateDemoData.presentation(for: .permissionRevokedExternally))
    }
}

#Preview("UI-13 · Catalogue") {
    NavigationStack {
        EdgeStateCatalogueView()
    }
}
