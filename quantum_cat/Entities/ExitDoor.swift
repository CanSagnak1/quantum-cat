//
//  ExitDoor.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SpriteKit

class ExitDoor: SKNode {
    private let doorEmoji: SKLabelNode
    private let glowEffect: SKShapeNode

    override init() {
        doorEmoji = SKLabelNode(text: "🚪")
        doorEmoji.fontSize = 60
        doorEmoji.verticalAlignmentMode = .center
        doorEmoji.horizontalAlignmentMode = .center

        glowEffect = SKShapeNode(circleOfRadius: 35)
        glowEffect.fillColor = SKColor.cyan.withAlphaComponent(0.3)
        glowEffect.strokeColor = .clear
        glowEffect.zPosition = -1

        super.init()

        addChild(glowEffect)
        addChild(doorEmoji)
        setupPhysics()
        startAnimations()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        let doorSize = CGSize(width: 50, height: 60)
        self.physicsBody = SKPhysicsBody(rectangleOf: doorSize)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = 0x1 << 2
        self.physicsBody?.contactTestBitMask = 0x1 << 0
        self.physicsBody?.collisionBitMask = 0
    }

    private func startAnimations() {
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.8)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        glowEffect.run(SKAction.repeatForever(pulse))

        let moveUp = SKAction.moveBy(x: 0, y: 5, duration: 1.0)
        let moveDown = SKAction.moveBy(x: 0, y: -5, duration: 1.0)
        let float = SKAction.sequence([moveUp, moveDown])
        doorEmoji.run(SKAction.repeatForever(float))
    }
}
