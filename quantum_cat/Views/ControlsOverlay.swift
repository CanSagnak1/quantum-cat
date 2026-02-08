//
//  ControlsOverlay.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import Combine
import SwiftUI

#if os(iOS)
    import UIKit
#endif

struct ControlsOverlay: View {
    @ObservedObject var viewModel: GameViewModel

    @State private var moveDirection: CGFloat = 0
    @State private var movementTimer: Timer?

    var body: some View {
        VStack {
            Spacer()

            HStack(alignment: .bottom) {
                HStack(spacing: 15) {
                    HoldButton(systemName: "arrow.left", color: .white) { isHolding in
                        handleMovement(direction: isHolding ? -1.0 : 0, button: "left")
                    }

                    HoldButton(systemName: "arrow.right", color: .white) { isHolding in
                        handleMovement(direction: isHolding ? 1.0 : 0, button: "right")
                    }
                }
                .padding(.leading, 30)

                Spacer()

                HStack(spacing: 15) {
                    TapButton(
                        systemName: viewModel.isSplit
                            ? "arrow.triangle.merge" : "arrow.triangle.branch",
                        color: .purple,
                        size: 60
                    ) {
                        viewModel.toggleSplit()
                    }

                    TapButton(
                        systemName: "arrow.up",
                        color: .blue,
                        size: 70
                    ) {
                        viewModel.requestJump()
                    }
                }
                .padding(.trailing, 30)
            }
            .padding(.bottom, 40)
        }
        .onDisappear {
            movementTimer?.invalidate()
        }
    }

    private func handleMovement(direction: CGFloat, button: String) {
        if direction != 0 {
            moveDirection = direction
            startMovementTimer()
        } else {
            if moveDirection != 0
                && ((button == "left" && moveDirection < 0)
                    || (button == "right" && moveDirection > 0))
            {
                moveDirection = 0
                stopMovementTimer()
                viewModel.updateMovement(direction: 0)
            }
        }
    }

    private func startMovementTimer() {
        movementTimer?.invalidate()
        movementTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            if moveDirection != 0 {
                viewModel.updateMovement(direction: moveDirection)
            }
        }
    }

    private func stopMovementTimer() {
        movementTimer?.invalidate()
        movementTimer = nil
    }
}

struct HoldButton: View {
    let systemName: String
    let color: Color
    var size: CGFloat = 65
    let onHoldChanged: (Bool) -> Void

    @State private var isPressed = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isPressed ? color.opacity(0.5) : color.opacity(0.25))
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.6), lineWidth: 2)
                )
                .shadow(color: color.opacity(0.3), radius: isPressed ? 2 : 6)

            Image(systemName: systemName)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.easeOut(duration: 0.08), value: isPressed)
        .onLongPressGesture(
            minimumDuration: .infinity,
            pressing: { pressing in
                isPressed = pressing
                onHoldChanged(pressing)
            }, perform: {})
    }
}

struct TapButton: View {
    let systemName: String
    let color: Color
    var size: CGFloat = 65
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.7), color.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(color.opacity(0.8), lineWidth: 3)
                )
                .shadow(color: color.opacity(0.5), radius: isPressed ? 2 : 8)

            Image(systemName: systemName)
                .font(.system(size: size * 0.35, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(isPressed ? 0.88 : 1.0)
        .animation(.easeOut(duration: 0.08), value: isPressed)
        .onLongPressGesture(
            minimumDuration: .infinity,
            pressing: { pressing in
                if pressing && !isPressed {
                    isPressed = true
                    onTap()

                    #if os(iOS)
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    #endif
                } else if !pressing {
                    isPressed = false
                }
            }, perform: {})
    }
}
