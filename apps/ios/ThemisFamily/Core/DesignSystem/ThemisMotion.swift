import SwiftUI

/// Approved motion (Engineering Handoff motion spec). Every animation has a
/// documented Reduce Motion alternative; use `ThemisMotion.animation(_:reduceMotion:)`
/// so callers never have to remember it.
enum ThemisMotion: CaseIterable, Sendable {
    /// Any StatusBadge kind change · 200 ms ease-in-out · RM: instant.
    case statusChange
    /// Approved → Applying → Applied · spring (0.35, 0.9) · RM: cross-fade.
    case applicationMorph
    /// Button press · 120 ms ease-out, scale 0.98 · RM: opacity only.
    case buttonPress
    /// Countdown (grace, Free Pass) each whole minute · 400 ms ease-in-out · RM: text only.
    case countdownTick
    /// Timeline now-marker each minute · 400 ms ease-in-out · RM: jumps.
    case nowMarker
    /// Lightweight auto-advance (P-008, P-020 · Testing, B-007) · 250 ms cross-fade.
    case lightweightAdvance
    /// Protection Activated (P-022) · ≈700 ms ease-out · RM: cross-fade.
    case protectionActivated

    var animation: Animation {
        switch self {
        case .statusChange: return .easeInOut(duration: 0.2)
        case .applicationMorph: return .spring(response: 0.35, dampingFraction: 0.9)
        case .buttonPress: return .easeOut(duration: 0.12)
        case .countdownTick, .nowMarker: return .easeInOut(duration: 0.4)
        case .lightweightAdvance: return .easeInOut(duration: 0.25)
        case .protectionActivated: return .easeOut(duration: 0.7)
        }
    }

    /// The Reduce Motion alternative. `nil` means apply the change without animation.
    var reducedAnimation: Animation? {
        switch self {
        case .statusChange, .countdownTick, .nowMarker: return nil
        case .applicationMorph, .lightweightAdvance, .protectionActivated: return .easeInOut(duration: 0.2)
        case .buttonPress: return .easeOut(duration: 0.12)
        }
    }

    static func animation(_ motion: ThemisMotion, reduceMotion: Bool) -> Animation? {
        reduceMotion ? motion.reducedAnimation : motion.animation
    }

    // MARK: Welcome story reveal (P-002)

    /// Total reveal duration.
    static let revealDuration: Double = 2.6
    /// Stagger between bands, as a fraction of the reveal (≈570 ms).
    static let revealBandStagger: Double = 0.22
    /// Each band's draw time, as a fraction of the reveal (≈780 ms).
    static let revealBandLength: Double = 0.3
    /// The now marker appears in the last 22% (≈570 ms).
    static let revealMarkerStart: Double = 0.78
    /// Band labels fade in once the band is 55% drawn.
    static let revealLabelThreshold: Double = 0.55

    /// Ease-out cubic, clamped to 0…1.
    static func easeOutCubic(_ x: Double) -> Double {
        let t = min(max(x, 0), 1)
        return 1 - pow(1 - t, 3)
    }
}
