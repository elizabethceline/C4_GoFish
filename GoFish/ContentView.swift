//
//  ContentView.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 09/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var matchManager = MatchManager()

    var body: some View {
        ZStack {
            if matchManager.gameState == .menu {
                VideoSplashScreenView()
            } else if matchManager.gameState == .inGame {
                GameView(matchManager: matchManager)
            } else {
                GameOverView(matchManager: matchManager)
            }
        }
        .onAppear {
            matchManager.authenticateUser()
        }
    }
}

#Preview {
    ContentView()
}
