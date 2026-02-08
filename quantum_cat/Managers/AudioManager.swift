//
//  AudioManager.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import AVFoundation
import Combine
import SwiftUI

#if os(iOS)
    import UIKit
#endif

class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    private var musicPlayer: AVAudioPlayer?
    private var soundPlayers: [String: AVAudioPlayer] = [:]

    enum SoundEffect: String {
        case jump = "jump"
        case split = "split"
        case collapse = "collapse"
        case orbPickup = "orb_pickup"
        case detected = "detected"
        case levelComplete = "level_complete"
        case gameOver = "game_over"
        case buttonTap = "button_tap"
    }

    private init() {
        setupAudioSession()
        preloadSounds()
    }

    private func setupAudioSession() {
        #if os(iOS)
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {}
        #endif
    }

    private func preloadSounds() {
        for sound in [SoundEffect.jump, .split, .collapse, .orbPickup] {
            preloadSound(sound)
        }
    }

    private func preloadSound(_ sound: SoundEffect) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            soundPlayers[sound.rawValue] = player
        } catch {}
    }

    func playSound(_ sound: SoundEffect) {
        guard soundEnabled else { return }

        if let player = soundPlayers[sound.rawValue] {
            player.currentTime = 0
            player.play()
            return
        }

        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") else {
            playSystemFallback(for: sound)
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
            soundPlayers[sound.rawValue] = player
        } catch {}
    }

    private func playSystemFallback(for sound: SoundEffect) {
        guard soundEnabled else { return }

        #if os(iOS)
            let systemSoundID: SystemSoundID
            switch sound {
            case .jump, .split:
                systemSoundID = 1104
            case .collapse:
                systemSoundID = 1105
            case .orbPickup:
                systemSoundID = 1057
            case .levelComplete:
                systemSoundID = 1025
            case .detected, .gameOver:
                systemSoundID = 1073
            case .buttonTap:
                systemSoundID = 1104
            }

            AudioServicesPlaySystemSound(systemSoundID)
        #endif
    }

    func playMusic(_ filename: String) {
        guard musicEnabled else { return }

        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else { return }

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = 0.5
            musicPlayer?.play()
        } catch {}
    }

    func stopMusic() {
        musicPlayer?.stop()
    }

    func pauseMusic() {
        musicPlayer?.pause()
    }

    func resumeMusic() {
        guard musicEnabled else { return }
        musicPlayer?.play()
    }

    #if os(iOS)
        func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
            guard hapticsEnabled else { return }
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }

        func playNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
            guard hapticsEnabled else { return }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(type)
        }
    #else
        func playHaptic(_ style: Any) {}
        func playNotificationHaptic(_ type: Any) {}
    #endif
}
