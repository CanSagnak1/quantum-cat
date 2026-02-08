//
//  ObserverEntity.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SpriteKit

class ObserverEntity: SKNode {
    private let bodyNode: SKShapeNode
    private let visionCone: SKShapeNode
    private let warningIndicator: SKShapeNode

    var visionRange: CGFloat = 250.0
    var visionAngle: CGFloat = .pi / 3

    private var isWarning: Bool = false
    private var warningTimer: TimeInterval = 0
    private let warningDuration: TimeInterval = 0.5

    var patrolPoints: [CGPoint] = []
    private var currentPatrolIndex: Int = 0
    private var patrolSpeed: CGFloat = 50.0

    static let categoryBitMask: UInt32 = 0x1 << 3

    override init() {
        bodyNode = SKShapeNode(circleOfRadius: 18)
        bodyNode.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        bodyNode.strokeColor = .white
        bodyNode.lineWidth = 2

        let lensNode = SKShapeNode(circleOfRadius: 8)
        lensNode.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        lensNode.strokeColor = SKColor.red.withAlphaComponent(0.8)
        lensNode.lineWidth = 2
        lensNode.position = CGPoint(x: 5, y: 0)

        let path = CGMutablePath()
        path.move(to: .zero)
        let leftPoint = CGPoint(
            x: visionRange * cos(visionAngle / 2),
            y: visionRange * sin(visionAngle / 2)
        )
        let rightPoint = CGPoint(
            x: visionRange * cos(-visionAngle / 2),
            y: visionRange * sin(-visionAngle / 2)
        )
        path.addLine(to: leftPoint)
        path.addLine(to: rightPoint)
        path.closeSubpath()

        visionCone = SKShapeNode(path: path)
        visionCone.fillColor = SKColor.yellow.withAlphaComponent(0.15)
        visionCone.strokeColor = SKColor.yellow.withAlphaComponent(0.3)
        visionCone.lineWidth = 1
        visionCone.zPosition = -1

        warningIndicator = SKShapeNode(circleOfRadius: 25)
        warningIndicator.fillColor = .clear
        warningIndicator.strokeColor = SKColor.red
        warningIndicator.lineWidth = 3
        warningIndicator.alpha = 0

        super.init()

        bodyNode.addChild(lensNode)
        addChild(visionCone)
        addChild(bodyNode)
        addChild(warningIndicator)

        startScanningAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func startScanningAnimation() {
        let rotateLeft = SKAction.rotate(byAngle: .pi / 2, duration: 2.0)
        rotateLeft.timingMode = .easeInEaseOut
        let rotateRight = rotateLeft.reversed()
        let pause = SKAction.wait(forDuration: 0.5)
        let sequence = SKAction.sequence([rotateLeft, pause, rotateRight, pause])
        run(SKAction.repeatForever(sequence))

        let lensNode = bodyNode.children.first as? SKShapeNode
        let blink = SKAction.sequence([
            SKAction.run { lensNode?.strokeColor = SKColor.red },
            SKAction.wait(forDuration: 0.5),
            SKAction.run { lensNode?.strokeColor = SKColor.red.withAlphaComponent(0.3) },
            SKAction.wait(forDuration: 0.5),
        ])
        bodyNode.run(SKAction.repeatForever(blink))
    }

    func setPatrol(points: [CGPoint]) {
        patrolPoints = points
        if !points.isEmpty {
            position = points[0]
        }
    }

    func updatePatrol(deltaTime: TimeInterval) {
        guard patrolPoints.count > 1 else { return }

        let target = patrolPoints[currentPatrolIndex]
        let direction = CGPoint(x: target.x - position.x, y: target.y - position.y)
        let distance = hypot(direction.x, direction.y)

        if distance < 5 {
            currentPatrolIndex = (currentPatrolIndex + 1) % patrolPoints.count
        } else {
            let normalized = CGPoint(x: direction.x / distance, y: direction.y / distance)
            let movement = CGFloat(deltaTime) * patrolSpeed
            position.x += normalized.x * movement
            position.y += normalized.y * movement
        }
    }

    func checkDetection(target: SKNode) -> Bool {
        let distance = hypot(target.position.x - position.x, target.position.y - position.y)
        if distance > visionRange {
            hideWarning()
            return false
        }

        let directionToTarget = CGPoint(
            x: target.position.x - position.x,
            y: target.position.y - position.y
        )
        let angleToTarget = atan2(directionToTarget.y, directionToTarget.x)
        let currentAngle = zRotation

        var angleDiff = angleToTarget - currentAngle
        while angleDiff > .pi { angleDiff -= 2 * .pi }
        while angleDiff < -.pi { angleDiff += 2 * .pi }

        if abs(angleDiff) <= visionAngle / 2 {
            showWarning()
            return true
        } else {
            hideWarning()
            return false
        }
    }

    private func showWarning() {
        guard !isWarning else { return }
        isWarning = true

        visionCone.fillColor = SKColor.red.withAlphaComponent(0.3)
        visionCone.strokeColor = SKColor.red

        warningIndicator.alpha = 1
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        warningIndicator.run(SKAction.repeatForever(pulse), withKey: "warning")
    }

    private func hideWarning() {
        guard isWarning else { return }
        isWarning = false

        visionCone.fillColor = SKColor.yellow.withAlphaComponent(0.15)
        visionCone.strokeColor = SKColor.yellow.withAlphaComponent(0.3)

        warningIndicator.removeAction(forKey: "warning")
        warningIndicator.alpha = 0
    }
    private static func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        return hypot(point2.x - point1.x, point2.y - point1.y)
    }
}
