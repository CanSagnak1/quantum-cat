//
//  ContentView.swift
//  quantum_cat
//
//  Created by Celal Can Sağnak on 08.02.2026
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            if viewModel.state != .menu {
                GameContainerView(viewModel: viewModel)
            }

            switch viewModel.state {
            case .menu:
                MainMenuView(viewModel: viewModel)
            case .playing:
                EmptyView()
            case .levelComplete:
                LevelCompleteView(viewModel: viewModel)
            case .gameOver:
                GameOverView(viewModel: viewModel)
            }
        }
        .statusBar(hidden: true)
    }
}
