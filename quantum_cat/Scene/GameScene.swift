//
//  GameScene.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    weak var gameDelegate: GameSceneDelegate?

    var player: PlayerEntity!
    private var cameraNode: SKCameraNode!
    private var observers: [ObserverEntity] = []
    private var exitDoor: ExitDoor!
    private var orbs: [QuantumOrb] = []

    private var quantumPlatforms: [SKNode] = []
    private var parallaxLayers: [SKNode] = []
    private var tutorialHints: [TutorialHintNode] = []

    var currentLevelId: Int = 1
    private var levelData: LevelData?
    private var lastUpdateTime: TimeInterval = 0
    private var levelEnded: Bool = false

    struct PhysicsCategory {
        static let player: UInt32 = 0x1 << 0
        static let ground: UInt32 = 0x1 << 1
        static let door: UInt32 = 0x1 << 2
        static let observer: UInt32 = 0x1 << 3
        static let orb: UInt32 = 0x1 << 4
    }

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self

        childNode(withName: "helloLabel")?.removeFromParent()
        enumerateChildNodes(withName: "//*") { node, _ in
            if node is SKLabelNode {
                node.removeFromParent()
            }
        }

        if let currentLevel = (gameDelegate as? GameViewModel)?.currentLevel {
            currentLevelId = currentLevel
        }

        setupWorld()
        setupParallaxBackground()
        setupCamera()
        loadLevel(id: currentLevelId)
    }

    func restartLevel() {
        removeAllChildren()
        removeAllActions()
        observers = []
        orbs = []
        quantumPlatforms = []
        parallaxLayers = []
        tutorialHints = []
        lastUpdateTime = 0

        setupWorld()
        setupParallaxBackground()
        setupCamera()
        loadLevel(id: currentLevelId)
    }

    private func loadLevel(id: Int) {
        if let data = LevelLoader.shared.loadLevel(id: id) {
            levelData = data
            setupLevelFromData(data)
        } else {
            setupLevelFromData(LevelLoader.shared.createDefaultLevel())
        }
    }

    private func setupLevelFromData(_ data: LevelData) {
        levelEnded = false
        player = PlayerEntity()
        player.position = data.playerStart.cgPoint()
        addChild(player)

        for platformData in data.platforms {
            addPlatform(at: platformData.cgPosition(), size: platformData.cgSize())
        }

        for quantumData in data.quantumPlatforms {
            addQuantumPlatform(at: quantumData.cgPosition(), size: quantumData.cgSize())
        }

        for observerData in data.observers {
            let observer = ObserverEntity()
            observer.position = observerData.cgPosition()
            observer.zRotation = observerData.rotation * .pi / 180

            if let angle = observerData.detectionAngle {
                observer.visionAngle = angle * .pi / 180
            }
            if let range = observerData.detectionRange {
                observer.visionRange = range
            }
            if let speed = observerData.patrolSpeed {
                observer.patrolSpeed = speed
            }

            if let patrolPoints = observerData.patrolPoints, !patrolPoints.isEmpty {
                let cgPoints = patrolPoints.map { $0.cgPoint() }
                observer.setPatrol(points: cgPoints)
            }

            observer.rebuildVisionCone()
            observer.startAnimations()

            addChild(observer)
            observers.append(observer)
        }

        for orbPos in data.orbs {
            let orb = QuantumOrb()
            orb.position = orbPos.cgPoint()
            addChild(orb)
            orbs.append(orb)
        }

        exitDoor = ExitDoor()
        exitDoor.position = data.exitPosition.cgPoint()
        addChild(exitDoor)

        if let hints = data.tutorialHints {
            for hintData in hints {
                let hintNode = TutorialHintNode(text: hintData.text, icon: hintData.icon)
                hintNode.position = hintData.cgPosition()
                addChild(hintNode)
                tutorialHints.append(hintNode)
            }
        }
    }

    private func setupWorld() {
        self.backgroundColor = SKColor(red: 0.05, green: 0.03, blue: 0.1, alpha: 1.0)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -12.0)
    }

    private func setupParallaxBackground() {
        let starsLayer = SKNode()
        starsLayer.zPosition = -100
        for _ in 0..<50 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.3...0.8)
            star.position = CGPoint(
                x: CGFloat.random(in: -1000...2000),
                y: CGFloat.random(in: -500...500)
            )
            starsLayer.addChild(star)
        }
        addChild(starsLayer)
        parallaxLayers.append(starsLayer)

        let midLayer = SKNode()
        midLayer.zPosition = -50
        midLayer.alpha = 0.3
        for i in 0..<5 {
            let plat = SKShapeNode(rectOf: CGSize(width: 200, height: 30))
            plat.fillColor = SKColor(white: 0.2, alpha: 1.0)
            plat.strokeColor = .clear
            plat.position = CGPoint(x: CGFloat(i) * 400 - 200, y: CGFloat.random(in: -200...200))
            midLayer.addChild(plat)
        }
        addChild(midLayer)
        parallaxLayers.append(midLayer)
    }

    private func addPlatform(at position: CGPoint, size: CGSize) {
        let plat = SKShapeNode(rectOf: size)
        plat.fillColor = SKColor(red: 0.25, green: 0.22, blue: 0.3, alpha: 1.0)
        plat.strokeColor = .white
        plat.lineWidth = 1
        plat.position = position

        plat.physicsBody = SKPhysicsBody(rectangleOf: size)
        plat.physicsBody?.isDynamic = false
        plat.physicsBody?.categoryBitMask = PhysicsCategory.ground
        plat.physicsBody?.collisionBitMask = PhysicsCategory.player

        addChild(plat)
    }

    private func addQuantumPlatform(at position: CGPoint, size: CGSize) {
        let quantumPlat = SKShapeNode(rectOf: size)
        quantumPlat.fillColor = SKColor.purple.withAlphaComponent(0.2)
        quantumPlat.strokeColor = .purple
        quantumPlat.lineWidth = 2
        quantumPlat.position = position
        quantumPlat.name = "quantumPlatform"
        quantumPlat.alpha = 0.3

        quantumPlat.physicsBody = SKPhysicsBody(rectangleOf: size)
        quantumPlat.physicsBody?.isDynamic = false
        quantumPlat.physicsBody?.categoryBitMask = 0
        quantumPlat.physicsBody?.collisionBitMask = PhysicsCategory.player

        addChild(quantumPlat)
        quantumPlatforms.append(quantumPlat)
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        self.camera = cameraNode
        addChild(cameraNode)
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime

        guard player != nil, !levelEnded else { return }

        checkFallDeath()
        updateCamera()
        updateObservers(deltaTime: deltaTime)
        checkObserverDetection()
        updateTutorialHints()
    }

    private func checkFallDeath() {
        let fallThreshold: CGFloat = -500
        if player.position.y < fallThreshold {
            levelEnded = true
            gameDelegate?.sceneDidPlayerFall()
        }
    }

    private func updateCamera() {
        guard let camera = cameraNode else { return }

        let targetPos = player.positionForCamera
        let newX = lerp(start: camera.position.x, end: targetPos.x, t: 0.08)
        let newY = lerp(start: camera.position.y, end: targetPos.y, t: 0.04)

        let deltaX = newX - camera.position.x
        camera.position = CGPoint(x: newX, y: newY)

        for (index, layer) in parallaxLayers.enumerated() {
            let factor = CGFloat(index + 1) * 0.1
            layer.position.x -= deltaX * factor
        }
    }

    private func updateObservers(deltaTime: TimeInterval) {
        for observer in observers {
            observer.updatePatrol(deltaTime: deltaTime)
        }
    }

    private func checkObserverDetection() {
        guard gameDelegate?.isSplit == true else { return }

        for observer in observers {
            if observer.checkDetection(target: player) {
                gameDelegate?.sceneDidDetectObserver()
                AudioManager.shared.playSound(.detected)
                AudioManager.shared.playHaptic(.heavy)
                break
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask

        if (maskA == PhysicsCategory.player && maskB == PhysicsCategory.door)
            || (maskA == PhysicsCategory.door && maskB == PhysicsCategory.player)
        {
            guard !levelEnded else { return }
            levelEnded = true
            gameDelegate?.sceneDidReachExit()
            AudioManager.shared.playSound(.levelComplete)
            AudioManager.shared.playNotificationHaptic(.success)
        }

        if maskA == PhysicsCategory.player && maskB == PhysicsCategory.orb {
            collectOrb(contact.bodyB.node as? QuantumOrb)
        } else if maskA == PhysicsCategory.orb && maskB == PhysicsCategory.player {
            collectOrb(contact.bodyA.node as? QuantumOrb)
        }
    }

    private func collectOrb(_ orb: QuantumOrb?) {
        guard let orb = orb, let index = orbs.firstIndex(of: orb) else { return }

        orbs.remove(at: index)
        gameDelegate?.sceneDidCollectOrb(stabilityBonus: 0.1)
        orb.collect()

        AudioManager.shared.playSound(.orbPickup)
        AudioManager.shared.playHaptic(.light)
    }

    func updateQuantumState(isSplit: Bool) {
        for platform in quantumPlatforms {
            if isSplit {
                platform.physicsBody?.categoryBitMask = PhysicsCategory.ground
                platform.alpha = 1.0
            } else {
                platform.physicsBody?.categoryBitMask = 0
                platform.alpha = 0.3
            }
        }
    }

    private func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
        return start + (end - start) * t
    }

    private func updateTutorialHints() {
        guard player != nil else { return }
        for hint in tutorialHints {
            hint.checkProximity(to: player.position)
        }
        tutorialHints.removeAll { $0.parent == nil }
    }
}
