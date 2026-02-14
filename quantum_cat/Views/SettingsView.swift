//
//  SettingsView.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("musicEnabled") private var musicEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @State private var showResetAlert = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }

                    Spacer()

                    Text("SETTINGS")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)

                VStack(spacing: 0) {
                    SettingsToggle(
                        icon: "speaker.wave.2.fill",
                        title: "Sound Effects",
                        isOn: $soundEnabled
                    )

                    Divider().background(Color.white.opacity(0.1))

                    SettingsToggle(
                        icon: "music.note",
                        title: "Music",
                        isOn: $musicEnabled
                    )

                    Divider().background(Color.white.opacity(0.1))

                    SettingsToggle(
                        icon: "iphone.radiowaves.left.and.right",
                        title: "Haptic Feedback",
                        isOn: $hapticsEnabled
                    )
                }
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    showResetAlert = true
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset Progress")
                    }
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                Text("v1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .padding(.top, 20)
        }
        .alert("Reset Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                GameProgressManager.shared.resetProgress()
            }
        } message: {
            Text(
                "Are you sure? All level progress, stars, and high scores will be permanently deleted."
            )
        }
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.purple)
                .frame(width: 30)

            Text(title)
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(.purple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
