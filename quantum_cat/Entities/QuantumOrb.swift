//
//  QuantumOrb.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SpriteKit

class QuantumOrb: SKNode {
    private let spriteNode: SKShapeNode
    private let glowNode: SKShapeNode
    private let orbSize: CGFloat = 25

    let stabilityBonus: CGFloat = 0.20
    static let categoryBitMask: UInt32 = 0x1 << 4

    override init() {
        spriteNode = SKShapeNode(circleOfRadius: orbSize / 2)
        spriteNode.fillColor = SKColor(red: 0.6, green: 0.3, blue: 1.0, alpha: 1.0)
        spriteNode.strokeColor = .white
        spriteNode.lineWidth = 2

        glowNode = SKShapeNode(circleOfRadius: orbSize * 0.8)
        glowNode.fillColor = SKColor.purple.withAlphaComponent(0.3)
        glowNode.strokeColor = .clear
        glowNode.zPosition = -1

        super.init()

        addChild(glowNode)
        addChild(spriteNode)

        setupPhysics()
        startAnimations()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        self.physicsBody = SKPhysicsBody(circleOfRadius: orbSize / 2)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = QuantumOrb.categoryBitMask
        self.physicsBody?.contactTestBitMask = 0x1 << 0
        self.physicsBody?.collisionBitMask = 0
    }

    private func startAnimations() {
        let moveUp = SKAction.moveBy(x: 0, y: 8, duration: 1.0)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = moveUp.reversed()
        let float = SKAction.sequence([moveUp, moveDown])
        spriteNode.run(SKAction.repeatForever(float))

        let expandGlow = SKAction.scale(to: 1.3, duration: 0.8)
        let shrinkGlow = SKAction.scale(to: 1.0, duration: 0.8)
        let pulse = SKAction.sequence([expandGlow, shrinkGlow])
        glowNode.run(SKAction.repeatForever(pulse))

        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 4.0)
        spriteNode.run(SKAction.repeatForever(rotate))
    }

    func collect() {
        removeAllActions()
        spriteNode.removeAllActions()
        glowNode.removeAllActions()

        let scaleUp = SKAction.scale(to: 1.5, duration: 0.15)
        let fadeOut = SKAction.fadeOut(withDuration: 0.15)
        let group = SKAction.group([scaleUp, fadeOut])

        if let particles = createCollectionParticles() {
            particles.position = .zero
            addChild(particles)
            particles.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.5),
                    SKAction.removeFromParent(),
                ]))
        }

        run(SKAction.sequence([group, SKAction.removeFromParent()]))
    }

    private func createCollectionParticles() -> SKEmitterNode? {
        let emitter = SKEmitterNode()

        emitter.particleTexture = nil
        emitter.particleBirthRate = 50
        emitter.numParticlesToEmit = 15
        emitter.particleLifetime = 0.5
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.emissionAngleRange = .pi * 2
        emitter.particleScale = 0.1
        emitter.particleScaleSpeed = -0.1
        emitter.particleColor = .purple
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -2.0

        return emitter
    }
}
