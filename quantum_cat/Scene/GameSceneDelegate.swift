//
//  GameSceneDelegate.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func sceneDidRequestSplit()
    func sceneDidDetectObserver()
    func sceneDidReachExit()
    func sceneDidCollectOrb(stabilityBonus: CGFloat)
    func sceneDidPlayerFall()
    var isSplit: Bool { get }
    var isPlaying: Bool { get }
}
