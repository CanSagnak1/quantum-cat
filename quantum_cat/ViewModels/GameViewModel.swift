//
//  GameViewModel.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import Combine
import SwiftUI

class GameViewModel: ObservableObject, GameSceneDelegate {
    @Published var state: GameState = .menu
    @Published var score: Int = 0
    @Published var quantumStability: CGFloat = 1.0
    @Published var isSplit: Bool = false
    @Published var orbsCollected: Int = 0
    @Published var currentLevel: Int = 1
    @Published var movementDirection: CGFloat = 0
    @Published var elapsedTime: TimeInterval = 0

    private var stabilityTimer: Timer?
    private var gameTimer: Timer?

    var isPlaying: Bool { state == .playing }

    weak var scene: GameScene?

    func startGame() {
        stopTimers()
        resetGame()
        state = .playing
        startTimers()
        MusicEngine.shared.startMusic()
    }

    func resetGame() {
        score = 0
        quantumStability = 1.0
        isSplit = false
        orbsCollected = 0
        elapsedTime = 0
        movementDirection = 0

        scene?.restartLevel()
    }

    private func startTimers() {
        stabilityTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
            [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard self.isSplit, self.state == .playing else { return }
                self.drainStability(amount: 0.005)
            }
        }

        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard self.state == .playing else { return }
                self.elapsedTime += 1
            }
        }
    }

    private func stopTimers() {
        stabilityTimer?.invalidate()
        stabilityTimer = nil
        gameTimer?.invalidate()
        gameTimer = nil
    }

    func finishLevel() {
        stopTimers()
        calculateScore()
        state = .levelComplete
    }

    func gameOver() {
        stopTimers()
        state = .gameOver
        MusicEngine.shared.stopMusic()
    }

    func returnToMenu() {
        stopTimers()
        state = .menu
        MusicEngine.shared.stopMusic()
    }

    func updateMovement(direction: CGFloat) {
        movementDirection = direction
        scene?.player?.move(velocity: direction)
    }

    func requestJump() {
        guard state == .playing else { return }
        scene?.player?.jump()
    }

    func toggleSplit() {
        guard quantumStability > 0.1 && state == .playing else { return }

        isSplit.toggle()
        scene?.player?.toggleSplit()
        scene?.updateQuantumState(isSplit: isSplit)

        if isSplit {
            drainStability(amount: 0.05)
        }
    }

    func drainStability(amount: CGFloat) {
        quantumStability = max(0.0, quantumStability - amount)

        if quantumStability <= 0 && isSplit {
            forceCollapse()
        }
    }

    func restoreStability(amount: CGFloat) {
        quantumStability = min(1.0, quantumStability + amount)
    }

    private func forceCollapse() {
        isSplit = false
        scene?.player?.toggleSplit()
        scene?.updateQuantumState(isSplit: false)
    }

    func collectOrb(stabilityBonus: CGFloat) {
        orbsCollected += 1
        restoreStability(amount: stabilityBonus)
        updateScore(by: 100)
    }

    func updateScore(by points: Int) {
        score += points
    }

    private func calculateScore() {
        let baseScore = 1000
        let timeBonus = max(0, 500 - Int(elapsedTime * 5))
        let orbBonus = orbsCollected * 100
        let perfectBonus = quantumStability >= 0.5 ? 200 : 0
        score = baseScore + timeBonus + orbBonus + perfectBonus
    }

    func sceneDidRequestSplit() {
        toggleSplit()
    }

    func sceneDidDetectObserver() {
        if isSplit {
            forceCollapse()
        }
    }

    func sceneDidReachExit() {
        finishLevel()
    }

    func sceneDidCollectOrb(stabilityBonus: CGFloat) {
        collectOrb(stabilityBonus: stabilityBonus)
    }

    func sceneDidPlayerFall() {
        gameOver()
    }
}
