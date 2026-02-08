//
//  PlayerEntity.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SpriteKit

class PlayerEntity: SKNode {
    private var alphaCat: CatNode!
    private var glowNode: SKShapeNode!

    private(set) var isSplit: Bool = false
    private var lastJumpTime: TimeInterval = 0

    private let jumpImpulse: CGFloat = 300.0
    private let moveSpeed: CGFloat = 200.0
    private let jumpCooldown: TimeInterval = 0.3

    override init() {
        super.init()
        setupCat()
        setupGlow()
        setupPhysicsBody()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCat() {
        alphaCat = CatNode(type: .alpha)
        addChild(alphaCat)
    }

    private func setupGlow() {
        glowNode = SKShapeNode(circleOfRadius: 40)
        glowNode.fillColor = SKColor.purple.withAlphaComponent(0.4)
        glowNode.strokeColor = .clear
        glowNode.zPosition = -1
        glowNode.isHidden = true
        addChild(glowNode)
    }

    private func setupPhysicsBody() {
        let bodySize = CGSize(width: 40, height: 40)
        self.physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.friction = 0.2
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.mass = 0.5
        self.physicsBody?.linearDamping = 0.0

        self.physicsBody?.categoryBitMask = 0x1 << 0
        self.physicsBody?.collisionBitMask = 0x1 << 1
        self.physicsBody?.contactTestBitMask = 0x1 << 1 | 0x1 << 2 | 0x1 << 4
    }

    private var isGrounded: Bool {
        guard let body = self.physicsBody else { return false }
        return abs(body.velocity.dy) < 50.0
    }

    func toggleSplit() {
        isSplit.toggle()

        if isSplit {
            glowNode.isHidden = false
            let scaleUp = SKAction.scale(to: 1.4, duration: 0.4)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.4)
            let pulse = SKAction.sequence([scaleUp, scaleDown])
            glowNode.run(SKAction.repeatForever(pulse), withKey: "glow")

            let catScaleUp = SKAction.scale(to: 1.15, duration: 0.15)
            let catScaleNormal = SKAction.scale(to: 1.0, duration: 0.15)
            alphaCat.run(SKAction.sequence([catScaleUp, catScaleNormal]))
        } else {
            glowNode.removeAction(forKey: "glow")
            glowNode.isHidden = true
            glowNode.setScale(1.0)

            let catScaleShrink = SKAction.scale(to: 0.9, duration: 0.1)
            let catScaleNormal = SKAction.scale(to: 1.0, duration: 0.1)
            alphaCat.run(SKAction.sequence([catScaleShrink, catScaleNormal]))
        }
    }

    func jump() {
        guard let body = self.physicsBody else { return }
        guard isGrounded else { return }

        let currentTime = CACurrentMediaTime()
        guard currentTime - lastJumpTime > jumpCooldown else { return }

        lastJumpTime = currentTime

        body.velocity = CGVector(dx: body.velocity.dx, dy: 0)
        body.applyImpulse(CGVector(dx: 0, dy: jumpImpulse))

        alphaCat.animateJump()
    }

    func move(velocity: CGFloat) {
        guard let body = self.physicsBody else { return }
        body.velocity.dx = velocity * moveSpeed

        if velocity > 0.1 {
            alphaCat.xScale = abs(alphaCat.xScale)
        } else if velocity < -0.1 {
            alphaCat.xScale = -abs(alphaCat.xScale)
        }
    }

    var positionForCamera: CGPoint {
        return position
    }
}
