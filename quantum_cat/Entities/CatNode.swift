//
//  CatNode.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SpriteKit

enum CatType {
    case alpha
    case beta
}

class CatNode: SKNode {
    let type: CatType
    private let emojiLabel: SKLabelNode
    private let catSize: CGFloat = 50

    init(type: CatType) {
        self.type = type
        emojiLabel = SKLabelNode(text: "🐱")
        emojiLabel.fontSize = catSize
        emojiLabel.verticalAlignmentMode = .center
        emojiLabel.horizontalAlignmentMode = .center

        super.init()

        if type == .alpha {
            emojiLabel.alpha = 1.0
        } else {
            emojiLabel.alpha = 0.6
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.5)
            let fadeIn = SKAction.fadeAlpha(to: 0.6, duration: 0.5)
            let pulse = SKAction.sequence([fadeOut, fadeIn])
            emojiLabel.run(SKAction.repeatForever(pulse))
        }

        addChild(emojiLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func animateRun() {
        let squish = SKAction.scaleX(to: 1.1, y: 0.9, duration: 0.1)
        let stretch = SKAction.scaleX(to: 0.9, y: 1.1, duration: 0.1)
        let normal = SKAction.scale(to: 1.0, duration: 0.1)
        emojiLabel.run(SKAction.sequence([squish, stretch, normal]))
    }

    func animateJump() {
        let stretch = SKAction.scaleY(to: 1.3, duration: 0.1)
        let normal = SKAction.scaleY(to: 1.0, duration: 0.2)
        emojiLabel.run(SKAction.sequence([stretch, normal]))
    }
}
