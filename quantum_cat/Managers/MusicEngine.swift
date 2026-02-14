//
//  MusicEngine.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 14.02.2026
//

import AVFoundation
import SwiftUI

class MusicEngine {
    static let shared = MusicEngine()

    @AppStorage("musicEnabled") private var musicEnabled = true

    private var audioEngine: AVAudioEngine?
    private var playerNodes: [AVAudioPlayerNode] = []
    private var isPlaying = false

    private let sampleRate: Double = 44100.0

    private init() {}

    func startMusic() {
        guard musicEnabled, !isPlaying else { return }

        do {
            let engine = AVAudioEngine()
            let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

            let bassNode = AVAudioPlayerNode()
            let padNode = AVAudioPlayerNode()
            let shimmerNode = AVAudioPlayerNode()

            engine.attach(bassNode)
            engine.attach(padNode)
            engine.attach(shimmerNode)

            let mixer = engine.mainMixerNode

            engine.connect(bassNode, to: mixer, format: format)
            engine.connect(padNode, to: mixer, format: format)
            engine.connect(shimmerNode, to: mixer, format: format)

            mixer.outputVolume = 0.25

            try engine.start()

            scheduleBassLayer(node: bassNode, format: format)
            schedulePadLayer(node: padNode, format: format)
            scheduleShimmerLayer(node: shimmerNode, format: format)

            bassNode.play()
            padNode.play()
            shimmerNode.play()

            self.audioEngine = engine
            self.playerNodes = [bassNode, padNode, shimmerNode]
            self.isPlaying = true
        } catch {
            print("[MusicEngine] Failed to start: \(error)")
        }
    }

    func stopMusic() {
        playerNodes.forEach { $0.stop() }
        audioEngine?.stop()
        audioEngine = nil
        playerNodes = []
        isPlaying = false
    }

    func pauseMusic() {
        playerNodes.forEach { $0.pause() }
    }

    func resumeMusic() {
        guard musicEnabled else { return }
        playerNodes.forEach { $0.play() }
    }

    // MARK: - Generative Layers

    private func scheduleBassLayer(node: AVAudioPlayerNode, format: AVAudioFormat) {
        let duration: Double = 8.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
        }
        buffer.frameLength = frameCount

        let data = buffer.floatChannelData![0]
        let baseFreq: Float = 55.0  // A1

        for i in 0..<Int(frameCount) {
            let t = Float(i) / Float(sampleRate)
            let envelope = sin(Float.pi * t / Float(duration)) * 0.3
            let wave = sin(2.0 * Float.pi * baseFreq * t)
            let wave2 = sin(2.0 * Float.pi * (baseFreq * 1.5) * t) * 0.3
            data[i] = (wave + wave2) * envelope
        }

        node.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    private func schedulePadLayer(node: AVAudioPlayerNode, format: AVAudioFormat) {
        let duration: Double = 12.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
        }
        buffer.frameLength = frameCount

        let data = buffer.floatChannelData![0]
        let frequencies: [Float] = [130.81, 164.81, 196.0, 261.63]  // C3, E3, G3, C4

        for i in 0..<Int(frameCount) {
            let t = Float(i) / Float(sampleRate)
            let envelope = sin(Float.pi * t / Float(duration)) * 0.12

            var sample: Float = 0
            for (idx, freq) in frequencies.enumerated() {
                let phase = t * Float(idx + 1) * 0.1
                let modFreq = freq + sin(2.0 * Float.pi * 0.2 * t + phase) * 1.5
                sample += sin(2.0 * Float.pi * modFreq * t)
            }
            data[i] = (sample / Float(frequencies.count)) * envelope
        }

        node.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    private func scheduleShimmerLayer(node: AVAudioPlayerNode, format: AVAudioFormat) {
        let duration: Double = 16.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
        }
        buffer.frameLength = frameCount

        let data = buffer.floatChannelData![0]
        let highFreqs: [Float] = [523.25, 659.25, 783.99]  // C5, E5, G5

        for i in 0..<Int(frameCount) {
            let t = Float(i) / Float(sampleRate)

            let burstPhase = t.truncatingRemainder(dividingBy: 4.0)
            let burstEnvelope: Float
            if burstPhase < 0.3 {
                burstEnvelope = sin(Float.pi * burstPhase / 0.3) * 0.08
            } else {
                burstEnvelope = max(0, 0.08 * exp(-3.0 * (burstPhase - 0.3)))
            }

            var sample: Float = 0
            for freq in highFreqs {
                let vibrato = sin(2.0 * Float.pi * 5.0 * t) * 2.0
                sample += sin(2.0 * Float.pi * (freq + vibrato) * t)
            }
            data[i] = (sample / Float(highFreqs.count)) * burstEnvelope
        }

        node.scheduleBuffer(buffer, at: nil, options: .loops)
    }
}
