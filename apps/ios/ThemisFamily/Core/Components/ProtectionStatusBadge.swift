import SwiftUI

/// Protection status chip. A thin wrapper over the shared `StatusBadge`
/// so every protection surface uses the one approved status system.
struct ProtectionStatusBadge: View {
    let status: ProtectionStatus

    var body: some View {
        StatusBadge(status.themisStatus, accessibilityContext: "Protection status")
    }
}
