//
//  GameView.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import GameKit
import SwiftUI

struct GameView: View {
    @ObservedObject var matchManager: MatchManager

    @State private var selectedCardIndex: Int?

    private var localPlayer: Player? {
        matchManager.players.first { $0.id == GKLocalPlayer.local.gamePlayerID }
    }

    private var otherPlayers: [Player] {
        matchManager.players.filter {
            $0.id != GKLocalPlayer.local.gamePlayerID
        }
    }

    private var opponent1: Player? {
        otherPlayers.indices.contains(0) ? otherPlayers[0] : nil
    }

    private var opponent2: Player? {
        otherPlayers.indices.contains(1) ? otherPlayers[1] : nil
    }

    private var isMyTurn: Bool {
        localPlayer?.id == matchManager.currentPlayerId
    }

    var body: some View {
        ZStack {
            // background
            Color.blue.opacity(0.2)
                .ignoresSafeArea()

            VStack {
                HStack(alignment: .top) {
                    playerSideView(for: opponent1)
                    Spacer()
                    playerSideView(for: opponent2)
                }

                VStack {
                    Spacer()
                    CardBackView()
                        .frame(width: 80, height: 110)
                        .overlay(alignment: .bottom) {
                            Text("\(matchManager.cardsRemainingInDeck)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Capsule())
                                .offset(y: 15)
                        }

                    Text(matchManager.gameLog.last ?? "Game has started!")
                        .font(.headline)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()

                    Spacer()
                }
                .frame(maxWidth: .infinity)

                Spacer()

                localPlayerView()
            }
            .padding()
        }
    }

    @ViewBuilder
    private func playerSideView(for player: Player?) -> some View {
        if let player = player {
            VStack(spacing: 20) {
                OpponentView(
                    player: player,
                    isCurrentTurn: player.id == matchManager.currentPlayerId
                )

                ZStack {
                    ForEach(0..<min(player.hand.count, 7), id: \.self) {
                        index in
                        CardBackView()
                            .frame(width: 60, height: 85)
                            .offset(y: CGFloat(index) * 15)
                    }
                }
            }
            .frame(width: 100)
        } else {
            Spacer().frame(width: 100)
        }
    }

    @ViewBuilder
    private func localPlayerView() -> some View {
        VStack(spacing: 10) {
            if let hand = localPlayer?.hand.sorted(by: { $0.rank < $1.rank }) {
                ZStack {
                    ForEach(Array(hand.enumerated()), id: \.element.id) {
                        index, card in
                        CardView(card: card)
                            .frame(height: 140)
                            .offset(
                                x: CGFloat(index - hand.count / 2) * 40,
                                y: selectedCardIndex == index ? -30 : 0
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedCardIndex =
                                        (selectedCardIndex == index)
                                        ? nil : index
                                }
                            }
                    }
                }
                .frame(height: 160)
            }

            HStack(spacing: 15) {
                VStack {
                    Text("Your Books")
                        .font(.caption2)
                    Text("★ \(localPlayer?.books ?? 0)")
                        .font(.headline).bold()
                }

                Image(systemName: "person.fill")
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color.orange.opacity(0.8))
                    .clipShape(Circle())

                if isMyTurn {
                    Button("Your Turn") {

                    }
                    .font(.headline.bold())
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.yellow)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                } else {
                    Text("Waiting...")
                        .font(.headline.bold())
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

#Preview {
    func createMockManager() -> MatchManager {
        let manager = MatchManager()

        let localPlayerId = GKLocalPlayer.local.gamePlayerID
        let player1 = Player(
            id: localPlayerId, displayName: "Anda",
            hand: [
                Card(rank: .ace, suit: .spades),
                Card(rank: .king, suit: .hearts),
                Card(rank: .seven, suit: .spades),
                Card(rank: .two, suit: .diamonds),
                Card(rank: .jack, suit: .clubs),
                Card(rank: .five, suit: .hearts),
            ], books: 1)

        let opponentHand1 = (0..<5).map { _ in Card(rank: .queen, suit: .clubs)
        }
        let opponentHand2 = (0..<7).map { _ in Card(rank: .queen, suit: .clubs)
        }

        let player2 = Player(
            id: "OPPONENT_1", displayName: "Player A", hand: opponentHand1,
            books: 2)
        let player3 = Player(
            id: "OPPONENT_2", displayName: "Player B", hand: opponentHand2,
            books: 0)

        manager.players = [player1, player2, player3]
        manager.gameState = .inGame
        manager.gameLog = ["Welcome!", "Cards dealt.", "It's your turn!"]

        manager.currentPlayerId = player1.id

        return manager
    }

    return GameView(matchManager: createMockManager())
}
