//
//  GameContainerView.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SpriteKit
import SwiftUI

struct GameContainerView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var gameScene: GameScene?
    @State private var isPaused: Bool = false
    @State private var sceneId: UUID = UUID()

    var body: some View {
        ZStack {
            if let scene = gameScene {
                SpriteView(scene: scene)
                    .id(sceneId)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            } else {
                Color.black.ignoresSafeArea()
            }

            VStack {
                HStack {
                    HUDView(viewModel: viewModel)

                    Spacer()

                    Button(action: {
                        isPaused = true
                    }) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)

                Spacer()
            }

            if viewModel.state == .playing {
                ControlsOverlay(viewModel: viewModel)
            }

            if isPaused && viewModel.state == .playing {
                PauseMenuView(viewModel: viewModel, isPaused: $isPaused)
            }
        }
        .onAppear {
            setupScene()
        }
        .onChange(of: viewModel.currentLevel) { oldValue, newValue in
            setupScene()
        }
        .onChange(of: viewModel.state) { oldValue, newState in
            if newState == .playing {
                isPaused = false
                setupScene()
            } else {
                isPaused = false
            }
        }
    }

    private func setupScene() {
        let scene: GameScene
        if let loaded = GameScene(fileNamed: "GameScene") {
            scene = loaded
        } else {
            scene = GameScene(size: CGSize(width: 1024, height: 768))
        }
        scene.scaleMode = .aspectFill
        scene.gameDelegate = viewModel
        viewModel.scene = scene
        gameScene = scene
        sceneId = UUID()
    }
}
