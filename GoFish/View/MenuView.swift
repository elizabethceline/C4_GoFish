//
//  MenuView.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var matchManager: MatchManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Go Fish!")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.blue)

            Button {
                matchManager.startMatchmaking()
            } label: {
                Text("PLAY")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 80)
                    .padding(.vertical, 15)
                    .background(
                        Capsule().fill(
                            matchManager.authenticationState != .authenticated || matchManager.gameState != .menu
                            ? Color.gray : Color.blue
                        )
                    )
            }
            .disabled(matchManager.authenticationState != .authenticated || matchManager.gameState != .menu)
            
            if matchManager.authenticationState != .authenticated {
                Text(matchManager.authenticationState.rawValue)
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            
            if matchManager.gameState == .matchmaking {
                HStack {
                    Text("Finding players...")
                    ProgressView()
                }
                .font(.headline)
                .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    MenuView(matchManager: MatchManager())
}
