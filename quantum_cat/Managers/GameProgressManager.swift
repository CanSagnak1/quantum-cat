//
//  GameProgressManager.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import Combine
import Foundation

class GameProgressManager: ObservableObject {
    static let shared = GameProgressManager()

    private let progressKey = "game_progress"
    @Published private(set) var progress: PlayerProgress

    private init() {
        progress = Self.loadProgress()
    }

    var unlockedLevels: Set<Int> {
        progress.unlockedLevels
    }

    func isLevelUnlocked(_ levelId: Int) -> Bool {
        progress.unlockedLevels.contains(levelId)
    }

    func unlockLevel(_ levelId: Int) {
        progress.unlockedLevels.insert(levelId)
        saveProgress()
    }

    func getMaxUnlockedLevel() -> Int {
        return progress.unlockedLevels.max() ?? 1
    }

    func getStars(for levelId: Int) -> Int {
        progress.levelStars[levelId] ?? 0
    }

    func getHighScore(for levelId: Int) -> Int {
        progress.highScores[levelId] ?? 0
    }

    func completeLevel(
        _ levelId: Int, score: Int, time: TimeInterval, parTime: TimeInterval, wasCollapsed: Bool,
        orbsCollected: Int, totalOrbs: Int
    ) {
        var stars = 1

        if time <= parTime {
            stars += 1
        }

        if !wasCollapsed && orbsCollected >= totalOrbs {
            stars += 1
        }

        let currentStars = progress.levelStars[levelId] ?? 0
        if stars > currentStars {
            progress.levelStars[levelId] = stars
        }

        let currentHigh = progress.highScores[levelId] ?? 0
        if score > currentHigh {
            progress.highScores[levelId] = score
        }

        let nextLevel = levelId + 1
        if nextLevel <= 10 {
            progress.unlockedLevels.insert(nextLevel)
        }

        saveProgress()
    }

    var totalStars: Int {
        progress.levelStars.values.reduce(0, +)
    }

    var totalScore: Int {
        progress.highScores.values.reduce(0, +)
    }

    var completedLevels: Int {
        progress.levelStars.count
    }

    private static func loadProgress() -> PlayerProgress {
        guard let data = UserDefaults.standard.data(forKey: "game_progress"),
            let progress = try? JSONDecoder().decode(PlayerProgress.self, from: data)
        else {
            return PlayerProgress(
                unlockedLevels: [1],
                levelStars: [:],
                highScores: [:]
            )
        }
        return progress
    }

    private func saveProgress() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
    }

    func resetProgress() {
        progress = PlayerProgress(
            unlockedLevels: [1],
            levelStars: [:],
            highScores: [:]
        )
        saveProgress()
    }
}

struct PlayerProgress: Codable {
    var unlockedLevels: Set<Int>
    var levelStars: [Int: Int]
    var highScores: [Int: Int]
}
