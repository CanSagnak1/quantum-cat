//
//  LevelLoader.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SpriteKit

class LevelLoader {
    static let shared = LevelLoader()
    private init() {}

    func loadLevel(id: Int) -> LevelData? {
        let filename = "level_\(id)"

        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let levelData = try decoder.decode(LevelData.self, from: data)
            guard levelData.isValid() else {
                print("[LevelLoader] Level \(id) failed validation")
                return nil
            }
            return levelData
        } catch {
            print("[LevelLoader] Failed to decode level \(id): \(error)")
            return nil
        }
    }

    func createDefaultLevel() -> LevelData {
        return LevelData(
            id: 1,
            name: "First Steps",
            difficulty: 1,
            description: "Learn the basics",
            playerStart: PointData(x: -100, y: 0),
            exitPosition: PointData(x: 600, y: -130),
            platforms: [
                PlatformData(
                    position: PointData(x: 0, y: -200),
                    size: SizeData(width: 2000, height: 50),
                    type: "normal"
                )
            ],
            quantumPlatforms: [
                PlatformData(
                    position: PointData(x: 300, y: -100),
                    size: SizeData(width: 150, height: 20),
                    type: "quantum"
                )
            ],
            observers: [
                ObserverData(
                    position: PointData(x: 400, y: 50),
                    rotation: 0,
                    patrolPoints: nil,
                    detectionAngle: 60,
                    detectionRange: 200,
                    patrolSpeed: 50
                )
            ],
            orbs: [
                PointData(x: 100, y: -100),
                PointData(x: 200, y: -50),
                PointData(x: 350, y: 0),
            ],
            parTime: 30,
            requiredOrbs: 0,
            backgroundTheme: "space_blue",
            tutorialHints: nil
        )
    }
}
