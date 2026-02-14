//
//  LevelData.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import CoreGraphics
import Foundation

struct TutorialHint: Codable {
    let position: PointData
    let text: String
    let icon: String?

    func cgPosition() -> CGPoint {
        return CGPoint(x: position.x, y: position.y)
    }
}

struct LevelData: Codable {
    let id: Int
    let name: String
    let difficulty: Int
    let description: String
    let playerStart: PointData
    let exitPosition: PointData
    let platforms: [PlatformData]
    let quantumPlatforms: [PlatformData]
    let observers: [ObserverData]
    let orbs: [PointData]
    let parTime: TimeInterval
    let requiredOrbs: Int
    let backgroundTheme: String?
    let tutorialHints: [TutorialHint]?

    enum CodingKeys: String, CodingKey {
        case id, name, difficulty, description, playerStart, exitPosition
        case platforms, observers, orbs, parTime, requiredOrbs, backgroundTheme
        case quantumPlatforms = "betaPlatforms"
        case tutorialHints
    }

    func isValid() -> Bool {
        guard id > 0 else { return false }
        guard difficulty >= 1 && difficulty <= 5 else { return false }
        guard !platforms.isEmpty else { return false }
        guard parTime > 0 else { return false }
        guard requiredOrbs >= 0 && requiredOrbs <= orbs.count else { return false }
        return true
    }
}

struct PlatformData: Codable {
    let position: PointData
    let size: SizeData
    let type: String?

    func cgPosition() -> CGPoint {
        return CGPoint(x: position.x, y: position.y)
    }

    func cgSize() -> CGSize {
        return CGSize(width: size.width, height: size.height)
    }
}

struct ObserverData: Codable {
    let position: PointData
    let rotation: CGFloat
    let patrolPoints: [PointData]?
    let detectionAngle: CGFloat?
    let detectionRange: CGFloat?
    let patrolSpeed: CGFloat?

    func cgPosition() -> CGPoint {
        return CGPoint(x: position.x, y: position.y)
    }

    func cgPatrolPoints() -> [CGPoint] {
        return patrolPoints?.map { CGPoint(x: $0.x, y: $0.y) } ?? []
    }
}

struct PointData: Codable {
    let x: CGFloat
    let y: CGFloat

    func cgPoint() -> CGPoint {
        return CGPoint(x: x, y: y)
    }
}

struct SizeData: Codable {
    let width: CGFloat
    let height: CGFloat
}

struct LevelMetadata {
    let id: Int
    let name: String
    let difficulty: Int
    let isUnlocked: Bool
    let stars: Int
    let highScore: Int
}
