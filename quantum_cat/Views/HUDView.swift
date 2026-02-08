//
//  HUDView.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SwiftUI

struct HUDView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        HStack(spacing: 10) {
            HUDPill(icon: "star.fill", iconColor: .yellow) {
                Text("\(viewModel.score)")
                    .fontWeight(.bold)
            }

            HUDPill(icon: "clock.fill", iconColor: .white) {
                Text(timeString)
                    .fontWeight(.medium)
                    .monospacedDigit()
            }

            HUDPill(icon: "sparkles", iconColor: .purple) {
                Text("\(viewModel.orbsCollected)")
                    .fontWeight(.bold)
            }

            StabilityBarView(stability: viewModel.quantumStability)
        }
        .padding(.leading, 16)
    }

    private var timeString: String {
        let minutes = Int(viewModel.elapsedTime) / 60
        let seconds = Int(viewModel.elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct HUDPill<Content: View>: View {
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 12))
            content
                .foregroundColor(.white)
                .font(.system(size: 14))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.6))
        .cornerRadius(8)
    }
}

struct StabilityBarView: View {
    let stability: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("STABILITY")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white.opacity(0.7))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 6)

                Capsule()
                    .fill(stabilityGradient)
                    .frame(width: 80 * max(0, stability), height: 6)
                    .animation(.linear(duration: 0.2), value: stability)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.6))
        .cornerRadius(8)
    }

    private var stabilityGradient: LinearGradient {
        let color: Color = stability > 0.6 ? .green : (stability > 0.3 ? .yellow : .red)
        return LinearGradient(
            colors: [color.opacity(0.8), color],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
