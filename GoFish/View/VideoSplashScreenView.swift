//
//  VideoSplashScreenView.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 16/06/25.
//

import SwiftUI
import AVKit

struct VideoSplashScreenView: View {
    @State private var showMainMenu = false
    
    private var player: AVPlayer

    init() {
        if let url = Bundle.main.url(forResource: "splashVideo", withExtension: "mp4") {
            self.player = AVPlayer(url: url)
        } else {
            self.player = AVPlayer()
            print("Error: Video file not found.")
        }
    }

    var body: some View {
        ZStack {
            if showMainMenu {
                MenuView(matchManager: MatchManager())
            } else {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                        player.isMuted = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                self.showMainMenu = true
                            }
                        }
                    }
                    .onDisappear {
                        player.pause()
                    }
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

#Preview {
    VideoSplashScreenView()
}
