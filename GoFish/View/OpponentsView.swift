//
//  OpponentsView.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import SwiftUI

struct OpponentView: View {
    let player: Player
    let isCurrentTurn: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "person.fill")
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.5))
                    .clipShape(Circle())

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
            Text("★ Books: \(player.books)")
                .font(.caption2)
        }
    }
}

#Preview {
    OpponentView(
        player: Player(
            id: "1", displayName: "Alice",
            hand: [
                Card(rank: .ace, suit: .spades),
                Card(rank: .king, suit: .hearts),
                Card(rank: .seven, suit: .spades),
                Card(rank: .two, suit: .diamonds),
                Card(rank: .jack, suit: .clubs),
                Card(rank: .five, suit: .hearts),
            ], books: 2), isCurrentTurn: true
    )
    .padding()

}
