//
//  TutorialHintNode.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 14.02.2026
//

import SpriteKit

class TutorialHintNode: SKNode {
    private let hintText: String
    private let hintIcon: String?
    private var dismissed = false
    private let dismissDistance: CGFloat = 120

    init(text: String, icon: String? = nil) {
        self.hintText = text
        self.hintIcon = icon
        super.init()
        setupNode()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupNode() {
        let displayText = (hintIcon ?? "") + " " + hintText

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = displayText
        label.fontSize = 14
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.name = "hintLabel"

        let padding: CGFloat = 24
        let bgWidth = label.frame.width + padding * 2
        let bgHeight: CGFloat = 36

        let background = SKShapeNode(
            rectOf: CGSize(width: bgWidth, height: bgHeight), cornerRadius: 18)
        background.fillColor = SKColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 0.85)
        background.strokeColor = SKColor.purple.withAlphaComponent(0.6)
        background.lineWidth = 1.5
        background.name = "hintBg"

        let glow = SKShapeNode(
            rectOf: CGSize(width: bgWidth + 4, height: bgHeight + 4), cornerRadius: 20)
        glow.fillColor = .clear
        glow.strokeColor = SKColor.purple.withAlphaComponent(0.3)
        glow.lineWidth = 2
        glow.glowWidth = 4

        addChild(glow)
        addChild(background)
        addChild(label)

        self.zPosition = 500

        let floatUp = SKAction.moveBy(x: 0, y: 6, duration: 1.5)
        let floatDown = floatUp.reversed()
        let floatSequence = SKAction.sequence([floatUp, floatDown])
        run(SKAction.repeatForever(floatSequence))

        let pulseUp = SKAction.fadeAlpha(to: 1.0, duration: 1.2)
        let pulseDown = SKAction.fadeAlpha(to: 0.7, duration: 1.2)
        glow.run(SKAction.repeatForever(SKAction.sequence([pulseDown, pulseUp])))
    }

    func checkProximity(to playerPosition: CGPoint) {
        guard !dismissed else { return }

        let distance = hypot(position.x - playerPosition.x, position.y - playerPosition.y)

        if distance < dismissDistance {
            dismiss()
        } else if distance < dismissDistance * 2 {
            let scale = max(0.8, distance / (dismissDistance * 2))
            alpha = scale
        }
    }

    private func dismiss() {
        dismissed = true
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.4)
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.4)
        let group = SKAction.group([fadeOut, scaleDown, moveUp])
        run(SKAction.sequence([group, SKAction.removeFromParent()]))
    }
}
