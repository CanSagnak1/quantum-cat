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
            return levelData
        } catch {
            return nil
        }
    }

    func configureScene(_ scene: GameScene, with levelData: LevelData) {
        scene.removeAllChildren()

        scene.backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -12.0)

        let camera = SKCameraNode()
        scene.camera = camera
        scene.addChild(camera)

        for platformData in levelData.platforms {
            let platform = createPlatform(data: platformData, isBeta: false)
            scene.addChild(platform)
        }

        for quantumPlatData in levelData.quantumPlatforms {
            let platform = createPlatform(data: quantumPlatData, isBeta: true)
            scene.addChild(platform)
        }

        for observerData in levelData.observers {
            let observer = createObserver(data: observerData)
            scene.addChild(observer)
        }

        for orbPos in levelData.orbs {
            let orb = QuantumOrb()
            orb.position = orbPos.cgPoint()
            scene.addChild(orb)
        }

        let player = PlayerEntity()
        player.position = levelData.playerStart.cgPoint()
        scene.player = player
        scene.addChild(player)

        let door = ExitDoor()
        door.position = levelData.exitPosition.cgPoint()
        scene.addChild(door)
    }

    private func createPlatform(data: PlatformData, isBeta: Bool) -> SKShapeNode {
        let platform = SKShapeNode(rectOf: data.cgSize())
        platform.position = data.cgPosition()

        if isBeta {
            platform.fillColor = SKColor.purple.withAlphaComponent(0.3)
            platform.strokeColor = .purple
            platform.alpha = 0.2
            platform.name = "betaPlatform"
            platform.physicsBody = SKPhysicsBody(rectangleOf: data.cgSize())
            platform.physicsBody?.isDynamic = false
            platform.physicsBody?.categoryBitMask = 0
        } else {
            platform.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
            platform.strokeColor = .white
            platform.physicsBody = SKPhysicsBody(rectangleOf: data.cgSize())
            platform.physicsBody?.isDynamic = false
            platform.physicsBody?.categoryBitMask = 0x1 << 1
            platform.physicsBody?.collisionBitMask = 0x1 << 0
        }

        return platform
    }

    private func createObserver(data: ObserverData) -> ObserverEntity {
        let observer = ObserverEntity()
        observer.position = data.cgPosition()
        observer.zRotation = data.rotation

        if !data.cgPatrolPoints().isEmpty {
            observer.setPatrol(points: data.cgPatrolPoints())
        }

        return observer
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
            backgroundTheme: "space_blue"
        )
    }
}
