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

    @State private var selectedCardIndex: Int?  // Tracks the index of the selected card in local player's hand
    @State private var selectedOpponentId: String?  // Tracks the selected opponent's ID (not currently used)
    @State private var selectedRank: Card.Rank?  // Tracks the selected rank (not currently used)
    @State private var showBooksSheet = false  // Controls the visibility of the completed books sheet

    private var localPlayer: Player? {
        // Finds the local player from the match manager's players list
        matchManager.players.first { $0.id == GKLocalPlayer.local.gamePlayerID }
    }

    private var otherPlayers: [Player] {
        // Returns all players except the local player
        matchManager.players.filter {
            $0.id != GKLocalPlayer.local.gamePlayerID
        }
    }

    private var opponent1: Player? {
        // Returns the first opponent if available
        otherPlayers.indices.contains(0) ? otherPlayers[0] : nil
    }

    private var opponent2: Player? {
        // Returns the second opponent if available
        otherPlayers.indices.contains(1) ? otherPlayers[1] : nil
    }

    private var isMyTurn: Bool {
        // Checks if it's the local player's turn
        localPlayer?.id == matchManager.currentPlayerId
    }

    var body: some View {
        ZStack {
            // Background image for game view
            Image("gameviewbackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                HStack(alignment: .top) {

                    playerSideView(for: opponent1)

                    VStack {
                        Spacer()
                        Spacer()
                        Spacer()

                        ZStack {
                            ForEach(
                                0..<min(matchManager.cardsRemainingInDeck, 5),
                                id: \.self
                            ) { i in
                                CardBackView()
                                    .frame(width: 80, height: 110)
                                    .offset(y: CGFloat(i) * -2)
                                    .zIndex(Double(i))
                            }
                        }
                        .overlay(alignment: .bottom) {
                            Text("\(matchManager.cardsRemainingInDeck)")
                                .font(.caption.bold()).foregroundColor(.white)
                                .padding(4).background(Color.black.opacity(0.5))
                                .clipShape(Capsule()).offset(y: 15)
                        }

                        VStack(spacing: 5) {
                            if matchManager.gameLog.isEmpty {
                                Text("Game has started!").font(.headline).bold()
                            } else {
                                ForEach(
                                    Array(matchManager.gameLog.suffix(2)),
                                    id: \.self
                                ) { logMessage in
                                    Text(logMessage)
                                        .font(.headline)
                                        .bold(
                                            logMessage
                                                == matchManager.gameLog.last
                                        )
                                        .opacity(
                                            logMessage
                                                == matchManager.gameLog.last
                                                ? 1.0 : 0.5)
                                }
                            }
                        }
                        .multilineTextAlignment(.center).padding().frame(
                            minHeight: 80
                        ).padding(.top, 10)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)

                    playerSideView(for: opponent2)
                }

                Spacer()

                localPlayerView()  // Shows local player's hand and controls
            }
            .padding()
        }
    }

    @ViewBuilder
    private func playerSideView(for player: Player?) -> some View {
        if let player = player {
            VStack(spacing: 20) {
                OpponentView(
                    matchManager: matchManager,
                    playerId: player.id,
                    isCurrentTurn: matchManager.currentPlayerId == player.id
                )

                ZStack {
                    // Shows up to 7 cards as card backs representing opponent's hand
                    ForEach(0..<min(player.hand.count, 7), id: \.self) {
                        index in
                        CardBackView()
                            .frame(width: 60, height: 85)
                            .offset(y: CGFloat(index) * 15)  // Stacks cards vertically with spacing
                    }
                }
                if isMyTurn,
                    let selectedCardIndex = selectedCardIndex,
                    let selectedCard = localPlayer?.hand.sorted(by: {
                        $0.rank < $1.rank
                    })[safe: selectedCardIndex],
                    player.id != localPlayer?.id
                {
                    Button("Ask!") {
                        // Sends the takeTurn action with selected card rank and opponent ID
                        matchManager.takeTurn(
                            askingPlayerId: matchManager.localPlayer
                                .gamePlayerID,
                            askedPlayerId: player.id,
                            requestedRank: selectedCard.rank
                        )
                        self.selectedCardIndex = nil  // Reset selected card after asking
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.newRed)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10).stroke(
                            Color.black, lineWidth: 1)
                    )
                    .clipShape(Capsule())
                }
            }
            .frame(width: 100)  // Fixed width for opponent views
        } else {
            Spacer().frame(width: 100)  // Placeholder space if no opponent
        }
    }

    @ViewBuilder
    private func localPlayerView() -> some View {
        VStack(spacing: 10) {
            if let hand = localPlayer?.hand.sorted(by: { $0.rank < $1.rank }) {
                ZStack {
                    // Displays local player's hand with cards spaced horizontally and selectable
                    ForEach(Array(hand.enumerated()), id: \.element.id) {
                        index,
                        card in
                        let spacing: CGFloat = hand.count > 7 ? 25 : 40  // Adjust spacing based on hand size
                        CardView(card: card)
                            .frame(height: 140)
                            .offset(
                                x: CGFloat(index - hand.count / 2) * spacing,  // Center cards horizontally
                                y: selectedCardIndex == index ? -30 : 0  // Raise selected card visually
                            )
                            .animation(
                                .easeInOut(duration: 0.3), value: hand.count
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    // Toggle selection of card on tap
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
                    showBooksSheet = true  // Show sheet with completed books when tapped
                } label: {
                    VStack {
                        Text("Your Books")
                            .font(.caption2)
                            .foregroundColor(.black)
                        Text("★ \(localPlayer?.books ?? 0)")
                            .font(.headline).bold()
                            .foregroundColor(.black)
                    }
                }

                Image(systemName: "person.fill")
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
                    .background(Color.newRed)
                    .clipShape(Circle())

                if isMyTurn {
                    Text("Your Turn")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.newRed)
                        .clipShape(Capsule())
                } else {
                    // Waiting message when it's not local player's turn
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

                let bookRanks = matchManager.booksForPlayer(
                    id: localPlayer?.id ?? "")
                if bookRanks.isEmpty {
                    // Message when no books completed yet
                    Text("You haven't completed any books yet.")
                        .foregroundColor(.secondary)
                } else {
                    // List all completed book ranks
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
