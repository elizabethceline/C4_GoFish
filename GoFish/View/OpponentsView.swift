//
//  OpponentsView.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import SwiftUI

struct OpponentView: View {
    @ObservedObject var matchManager: MatchManager
    let playerId: String
    let isCurrentTurn: Bool

    var body: some View {
        if let player = matchManager.players.first(where: { $0.id == playerId })
        {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    if let gkPlayer = matchManager.getGKPlayer(by: player.id) {
                        GameCenterAvatarView(
                            player: gkPlayer,
                            size: CGSize(width: 50, height: 50))
                    } else {
                        Image(systemName: "person.fill")
                            .font(.title)
                            .frame(width: 50, height: 50)
                            .background(Color.gray.opacity(0.5))
                            .clipShape(Circle())
                    }

                    if isCurrentTurn {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    }
                }

                Text(player.displayName)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.black)
                Text("★ Books: \(player.books)")
                    .font(.caption2)
                    .foregroundColor(.black)
            }
        }
    }
}
