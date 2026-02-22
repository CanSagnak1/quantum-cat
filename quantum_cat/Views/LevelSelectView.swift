//
//  LevelSelectView.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SwiftUI

struct LevelSelectView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    private let levelInfo: [(name: String, difficulty: Int)] = [
        ("Quantum Awakening", 1),
        ("First Contact", 2),
        ("Patrol Protocol", 3),
        ("Double Vision", 4),
        ("Quantum Collapse", 5),
        ("Quantum Corridors", 3),
        ("Observer Network", 3),
        ("Schrödinger's Maze", 4),
        ("Phase Shift", 4),
        ("Final Observation", 5),
        ("Quantum Leap", 3),
        ("Twin Sentinels", 3),
        ("The Pendulum", 3),
        ("Blind Spots", 4),
        ("Orb Trail", 3),
        ("Crossfire", 4),
        ("The Void", 3),
        ("Sniper Alley", 4),
        ("Zig Zag", 4),
        ("Observation Deck", 4),
        ("Time Crunch", 5),
        ("The Gauntlet", 5),
        ("Quantum Maze", 4),
        ("Intersection", 4),
        ("Leap of Faith", 4),
        ("The Spiral", 4),
        ("Nowhere to Hide", 4),
        ("Orb Heist", 4),
        ("Entanglement", 5),
        ("Superposition", 5)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.02, blue: 0.15), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }

                    Spacer()

                    Text("LEVELS")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(0..<levelInfo.count, id: \.self) { index in
                            let levelId = index + 1
                            let info = levelInfo[index]
                            let isUnlocked =
                                levelId <= GameProgressManager.shared.getMaxUnlockedLevel()
                            let stars = GameProgressManager.shared.getStars(for: levelId)

                            LevelCard(
                                levelId: levelId,
                                name: info.name,
                                difficulty: info.difficulty,
                                isUnlocked: isUnlocked || levelId <= 2,
                                stars: stars
                            ) {
                                viewModel.currentLevel = levelId
                                viewModel.startGame()
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding(.top, 10)
        }
    }
}

struct LevelCard: View {
    let levelId: Int
    let name: String
    let difficulty: Int
    let isUnlocked: Bool
    let stars: Int
    let action: () -> Void

    var body: some View {
        Button(action: {
            if isUnlocked { action() }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isUnlocked ? levelColor : Color(white: 0.2))
                        .frame(width: 50, height: 50)
                        .shadow(color: isUnlocked ? levelColor.opacity(0.5) : .clear, radius: 8)

                    if isUnlocked {
                        Text("\(levelId)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isUnlocked ? .white : .gray)

                    HStack(spacing: 3) {
                        ForEach(0..<5, id: \.self) { i in
                            Image(systemName: i < difficulty ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundColor(
                                    i < difficulty ? difficultyColor : .gray.opacity(0.3))
                        }
                        Text("Difficulty")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                if isUnlocked {
                    VStack(spacing: 4) {
                        HStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { i in
                                Image(systemName: i < stars ? "star.fill" : "star")
                                    .font(.system(size: 14))
                                    .foregroundColor(i < stars ? .yellow : .white.opacity(0.2))
                            }
                        }
                        if stars > 0 {
                            Text("Best")
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        }
                    }

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isUnlocked ? cardGradient : lockedGradient)
                    .shadow(color: isUnlocked ? levelColor.opacity(0.2) : .clear, radius: 10)
            )
        }
        .disabled(!isUnlocked)
    }

    private var levelColor: Color {
        switch difficulty {
        case 1: return .green
        case 2: return .blue
        case 3: return .purple
        case 4: return .orange
        case 5: return .red
        default: return .purple
        }
    }

    private var difficultyColor: Color {
        switch difficulty {
        case 1: return .green
        case 2: return .cyan
        case 3: return .purple
        case 4: return .orange
        case 5: return .red
        default: return .yellow
        }
    }

    private var cardGradient: LinearGradient {
        LinearGradient(
            colors: [Color(white: 0.15), Color(white: 0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var lockedGradient: LinearGradient {
        LinearGradient(
            colors: [Color(white: 0.08), Color(white: 0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
