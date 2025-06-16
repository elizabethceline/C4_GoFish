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
            Image("logo")
            .resizable()
            .scaledToFill()
            .frame(width: 300, height: 150)
            .padding(.bottom, 20)

            Button {
                matchManager.startMatchmaking()
            } label: {
                Image("playbutton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 100)
                        .opacity(matchManager.authenticationState != .authenticated || matchManager.gameState != .menu ? 0.5 : 1.0)
                        .animation(.easeInOut, value: matchManager.authenticationState != .authenticated || matchManager.gameState != .menu)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Image("menuviewbackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
    }
}

#Preview {
    MenuView(matchManager: MatchManager())
}
