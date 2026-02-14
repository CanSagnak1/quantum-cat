//
//  GameState.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import Foundation

enum GameState: Equatable, Sendable {
    case menu
    case playing
    case levelComplete
    case gameOver
}
