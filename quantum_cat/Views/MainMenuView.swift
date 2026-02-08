//
//  MainMenuView.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SwiftUI

struct MainMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showLevelSelect = false
    @State private var showSettings = false
    @State private var catScale: CGFloat = 1.0
    @State private var titleOffset: CGFloat = 0

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 30) {
                Spacer()

                VStack(spacing: 12) {
                    Text("🐱")
                        .font(.system(size: 100))
                        .scaleEffect(catScale)
                        .shadow(color: .purple.opacity(0.5), radius: 20)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
                            ) {
                                catScale = 1.1
                            }
                        }

                    Text("QUANTUM CAT")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .purple.opacity(0.5), radius: 10)

                    Text("Schrödinger's Adventure")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .offset(y: titleOffset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        titleOffset = 5
                    }
                }

                Spacer()

                VStack(spacing: 16) {
                    MenuButton(
                        title: "QUICK PLAY",
                        icon: "play.fill",
                        gradient: [.purple, .pink]
                    ) {
                        viewModel.startGame()
                    }

                    MenuButton(
                        title: "SELECT LEVEL",
                        icon: "square.grid.2x2.fill",
                        gradient: [.blue, .purple]
                    ) {
                        showLevelSelect = true
                    }

                    MenuButton(
                        title: "SETTINGS",
                        icon: "gearshape.fill",
                        gradient: [Color(white: 0.3), Color(white: 0.2)]
                    ) {
                        showSettings = true
                    }
                }
                .padding(.horizontal, 40)

                Spacer().frame(height: 60)
            }
        }
        .sheet(isPresented: $showLevelSelect) {
            LevelSelectView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.05, blue: 0.2),
                Color(red: 0.15, green: 0.08, blue: 0.25),
                Color(red: 0.1, green: 0.05, blue: 0.2),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func seededRandom(seed: Int, min: CGFloat, max: CGFloat) -> CGFloat {
        var generator = SeededRandomNumberGenerator(seed: UInt64(seed * 12345))
        return CGFloat.random(in: min...max, using: &generator)
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: gradient.first?.opacity(0.4) ?? .clear, radius: 10, y: 5)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
        }
    }
}

struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
