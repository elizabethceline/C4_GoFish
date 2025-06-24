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
        VStack(spacing: 10) {
            Image("logosketchy")
            .resizable()
            .scaledToFill()
            .frame(width: 200, height: 250)
            .padding(.bottom, 130)

            Button {
                matchManager.startMatchmaking()
            } label: {
                Image("playbutton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 80)
                        .opacity(matchManager.authenticationState != .authenticated || matchManager.gameState != .menu ? 0.5 : 1.0)
                        .animation(.easeInOut, value: matchManager.authenticationState != .authenticated || matchManager.gameState != .menu)
                }
            .disabled(matchManager.authenticationState != .authenticated || matchManager.gameState != .menu)
            
            Button {
                matchManager.startAIGame()
            } label: {
                Image("playwithAIbutton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 80)
                        .opacity(matchManager.authenticationState != .authenticated || matchManager.gameState != .menu ? 0.5 : 1.0)
                        .animation(.easeInOut, value: matchManager.authenticationState != .authenticated || matchManager.gameState != .menu)
            }
            .disabled(matchManager.gameState != .menu)
            .opacity(matchManager.gameState != .menu ? 0.5 : 1.0)
            .animation(.easeInOut, value: matchManager.gameState != .menu)
            
            if matchManager.authenticationState != .authenticated {
                Text(matchManager.authenticationState.rawValue)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.top, 20)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MenuView(matchManager: MatchManager())
}
