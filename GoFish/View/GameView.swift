//
//  GameView.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import GameKit
import SwiftUI

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct GameView: View {
    @ObservedObject var matchManager: MatchManager

    @State private var selectedCardIndex: Int?
    @State private var selectedOpponentId: String?
    @State private var selectedRank: Card.Rank?
    @State private var showBooksSheet = false

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
            // background amel
            Image("gameviewbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                HStack(alignment: .top) {
                    playerSideView(for: opponent1)
                    Spacer()
                    playerSideView(for: opponent2)
                }

                VStack {
                    Spacer()
                    ZStack {
                        ForEach(0..<min(matchManager.cardsRemainingInDeck, 5), id: \.self) { i in
                            CardBackView()
                                .frame(width: 80, height: 110)
                                .offset(y: CGFloat(i) * -2)
                                .zIndex(Double(i))
                        }
                    }
                    .overlay(alignment: .bottom) {
                        Text("\(matchManager.cardsRemainingInDeck)")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                            .offset(y: 15)
                    }

                    VStack(spacing: 5) {
                        if matchManager.gameLog.isEmpty {
                            Text("Game has started!")
                                .font(.headline)
                                .bold()
                        } else {
                            ForEach(Array(matchManager.gameLog.suffix(2)), id: \.self) { logMessage in
                                Text(logMessage)
                                    .font(.headline)
                                    .bold(logMessage == matchManager.gameLog.last)
                                    .opacity(logMessage == matchManager.gameLog.last ? 1.0 : 0.4)
                            }
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(minHeight: 80)
                    .padding(.top, 10)

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
                    isCurrentTurn: matchManager.currentPlayerId == player.id
                )

                ZStack {
                    ForEach(0..<min(player.hand.count, 7), id: \.self) {
                        index in
                        CardBackView()
                            .frame(width: 60, height: 85)
                            .offset(y: CGFloat(index) * 15)
                    }
                }
                if isMyTurn,
                   let selectedCardIndex = selectedCardIndex,
                   let selectedCard = localPlayer?.hand.sorted(by: { $0.rank < $1.rank })[safe: selectedCardIndex],
                   player.id != localPlayer?.id {
                    Button("Ask!") {
                        matchManager.takeTurn(
                            askingPlayerId: matchManager.localPlayer.gamePlayerID,
                            askedPlayerId: player.id,
                            requestedRank: selectedCard.rank
                        )
                        self.selectedCardIndex = nil
                    }
                    .padding(.top, 8)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    .clipShape(Capsule())
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
                        index,
                        card in
                        let spacing: CGFloat = hand.count > 7 ? 25 : 40
                        CardView(card: card)
                            .frame(height: 140)
                            .offset(
                                x: CGFloat(index - hand.count / 2) * spacing,
                                y: selectedCardIndex == index ? -30 : 0
                            )
                            .animation(.easeInOut(duration: 0.3), value: hand.count)
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
                Button {
                    showBooksSheet = true
                } label: {
                    VStack {
                        Text("Your Books")
                            .font(.caption2)
                        Text("★ \(localPlayer?.books ?? 0)")
                            .font(.headline).bold()
                    }
                }

                Image(systemName: "person.fill")
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(Color.orange.opacity(0.8))
                    .clipShape(Circle())

                if isMyTurn {
                    Text("Tap a card, then choose a player to ask.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
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
        .sheet(isPresented: $showBooksSheet) {
            VStack(spacing: 20) {
                Text("Completed Books")
                    .font(.title2).bold()

                let bookRanks = matchManager.booksForPlayer(id: localPlayer?.id ?? "")
                if bookRanks.isEmpty {
                    Text("You haven't completed any books yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(bookRanks, id: \.self) { rank in
                        Text("• \(rank.rawValue)")
                            .font(.headline)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    func createMockManager() -> MatchManager {
        let manager = MatchManager()

        let localPlayerId = GKLocalPlayer.local.gamePlayerID
        let player1 = Player(
            id: localPlayerId,
            displayName: "You",
            hand: [
                Card(rank: .ace, suit: .spades),
                Card(rank: .ace, suit: .hearts),
                Card(rank: .seven, suit: .spades),
                Card(rank: .ace, suit: .diamonds),
                Card(rank: .ace, suit: .clubs),
                Card(rank: .five, suit: .hearts),
            ],
            books: 1
        )

        let opponentHand1 = (0..<5).map { _ in Card(rank: .queen, suit: .clubs)
        }
        let opponentHand2 = (0..<7).map { _ in Card(rank: .queen, suit: .clubs)
        }

        let player2 = Player(
            id: "OPPONENT_1",
            displayName: "Player A",
            hand: opponentHand1,
            books: 2
        )
        let player3 = Player(
            id: "OPPONENT_2",
            displayName: "Player B",
            hand: opponentHand2,
            books: 0
        )

        manager.players = [player1, player2, player3]
        manager.gameState = .inGame
        manager.gameLog = ["Welcome!", "Cards dealt.", "It's your turn!"]

        manager.currentPlayerId = player1.id

        return manager
    }

    return GameView(matchManager: createMockManager())
}
