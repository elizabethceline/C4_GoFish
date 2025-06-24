//
//  HapticManager.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 24/06/25.
//

import CoreHaptics

class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?

    private init() {
        prepareEngine()
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine failed: \(error.localizedDescription)")
        }
    }

    func playTurnHaptic() {
        playContinuous(intensity: 0.8, sharpness: 0.7, duration: 0.2)
    }

    func playCardTapHaptic() {
        playTransient(intensity: 0.5, sharpness: 0.6)
    }

    func playBookHaptic() {
        playContinuous(intensity: 1.0, sharpness: 0.7, duration: 0.5)
    }

    private func playTransient(intensity: Float, sharpness: Float) {
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )

        play(events: [event])
    }

    private func playContinuous(intensity: Float, sharpness: Float, duration: TimeInterval) {
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,
            duration: duration
        )

        play(events: [event])
    }

    private func play(events: [CHHapticEvent]) {
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error.localizedDescription)")
        }
    }
}
