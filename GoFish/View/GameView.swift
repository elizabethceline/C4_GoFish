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

    @State private var isDealingCards = false
    @State private var dealtCardIDs: Set<String> = []
    @State private var deckPosition: CGPoint = .zero
    @State private var showDeckAnimation = false

    // Book animation state
    @State private var showBookAnimation = false
    @State private var bookRankToShow: Card.Rank?

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
            // Book animation overlay (on top)
            if showBookAnimation, let rank = bookRankToShow {
                ZStack {
                    ConfettiView(colors: [.white, .black])
                    BookCardView(rank: rank)
                }
                .transition(.opacity.combined(with: .scale))
                .zIndex(100)
            }

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

                        ZStack {
                            ForEach(
                                0..<min(matchManager.cardsRemainingInDeck, 5),
                                id: \.self
                            ) { i in
                                CardBackView()
                                    .frame(width: 80, height: 110)
                                    .rotationEffect(
                                        .degrees(
                                            showDeckAnimation
                                                ? Double(i) * 2 - 4 : 20
                                        )
                                    )
                                    .offset(
                                        y: showDeckAnimation
                                            ? CGFloat(i) * -4 : 300
                                    )
                                    .scaleEffect(
                                        showDeckAnimation
                                            ? (1 - CGFloat(i) * 0.03) : 0.1
                                    )
                                    .zIndex(Double(i))
                                    .animation(
                                        .easeOut(duration: 0.6).delay(
                                            Double(i) * 0.1
                                        ),
                                        value: showDeckAnimation
                                    )
                            }
                        }
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        let frame = geo.frame(
                                            in: .named("deckSpace")
                                        )
                                        deckPosition = CGPoint(
                                            x: frame.midX,
                                            y: frame.midY
                                        )
                                    }
                            }
                        )
                        .overlay(alignment: .bottom) {
                            Text("\(matchManager.cardsRemainingInDeck)")
                                .font(.caption.bold()).foregroundColor(.white)
                                .padding(4).background(Color.black.opacity(0.5))
                                .clipShape(Capsule()).offset(y: 15)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    playerSideView(for: opponent2)
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
                                        ? 1.0 : 0.5
                                )
                        }
                    }
                }
                .multilineTextAlignment(.center).padding().frame(
                    minHeight: 80
                ).padding(.top, 12)
                .padding(.bottom, 20)

                Spacer()

                localPlayerView()  // Shows local player's hand and controls
            }
            .padding()
            .onAppear {
                isDealingCards = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        showDeckAnimation = true
                    }
                }
            }
            .onChange(of: matchManager.lastCompletedBook, initial: false) {
                old,
                new in
                guard let book = new, book.playerId == localPlayer?.id else {
                    return
                }
                bookRankToShow = book.rank
                withAnimation(.easeOut(duration: 0.4)) {
                    showBookAnimation = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showBookAnimation = false
                    }
                }
            }
        }
        .coordinateSpace(name: "deckSpace")
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

                GeometryReader { geo in
                    HStack {
                        Spacer()
                        ZStack {
                            ForEach(0..<min(player.hand.count, 12), id: \.self)
                            {
                                index in
                                CardBackView()
                                    .frame(width: 60, height: 85)
                                    .scaleEffect(isDealingCards ? 1 : 0.1)
                                    .opacity(isDealingCards ? 1 : 0)
                                    .offset(
                                        x: isDealingCards
                                            ? 0
                                            : UIScreen.main.bounds.midX
                                                - geo.frame(in: .global).midX,
                                        y: isDealingCards
                                            ? CGFloat(index) * 15
                                            : UIScreen.main.bounds.midY
                                                - geo.frame(in: .global).midY
                                    )
                                    .animation(
                                        .easeOut(duration: 0.3).delay(
                                            Double(index) * 0.2
                                        ),
                                        value: isDealingCards
                                    )
                            }
                        }
                        .frame(width: 70)
                        Spacer()
                    }
                }
                .frame(height: 160)

                if isMyTurn,
                    let selectedRank = selectedRank,
                    player.id != localPlayer?.id
                {
                    Button("Ask!") {
                        // Sends the takeTurn action with selected card rank and opponent ID
                        matchManager.takeTurn(
                            askingPlayerId: matchManager.localPlayer
                                .gamePlayerID,
                            askedPlayerId: player.id,
                            requestedRank: selectedRank
                        )
                        self.selectedRank = nil
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.newRed)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10).stroke(
                            Color.black,
                            lineWidth: 1
                        )
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
                GeometryReader { geometry in
                    let minSpacing: CGFloat = 18
                    let maxSpacing: CGFloat = 40
                    let spacing = max(
                        minSpacing,
                        min(maxSpacing, 280 / CGFloat(hand.count))
                    )
                    let totalWidth = spacing * CGFloat(hand.count - 1)
                    ZStack {
                        // Displays local player's hand with cards spaced horizontally and selectable
                        ForEach(Array(hand.enumerated()), id: \.element.id) {
                            index,
                            card in
                            let spacing = max(
                                18,
                                min(40, 280 / CGFloat(hand.count))
                            )
                            let totalWidth = spacing * CGFloat(hand.count - 1)
                            let isDealt = dealtCardIDs.contains(card.id)

                            CardView(card: card)
                                .frame(height: 140)
                                .scaleEffect(isDealt ? 1 : 0.1)
                                .opacity(isDealt ? 1 : 0)
                                .animation(
                                    .easeOut(duration: 0.3).delay(
                                        Double(index) * 0.05
                                    ),
                                    value: dealtCardIDs
                                )
                                .onAppear {
                                    if isDealingCards {
                                        DispatchQueue.main.asyncAfter(
                                            deadline: .now() + Double(index)
                                                * 0.05
                                        ) {
                                            dealtCardIDs.insert(card.id)
                                        }
                                    }
                                }
                                .animation(
                                    .easeInOut(duration: 0.3),
                                    value: hand.count
                                )
                                .onTapGesture {
                                    guard isMyTurn else { return }
                                    withAnimation(.spring()) {
                                        selectedRank =
                                            (selectedRank == card.rank)
                                            ? nil : card.rank
                                    }
                                }
                                .offset(
                                    x: isDealt
                                        ? CGFloat(index) * spacing - totalWidth
                                            / 2
                                        : deckPosition.x - geometry.size.width
                                            / 2,
                                    y: isDealt
                                        ? selectedRank == card.rank ? -30 : 0
                                        : deckPosition.y
                                            - geometry.frame(in: .global).minY
                                )
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
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
                            .foregroundColor(.black)
                        Text("★ \(localPlayer?.books ?? 0)")
                            .font(.headline).bold()
                            .foregroundColor(.black)
                    }
                }

                if let gkPlayer = matchManager.getGKPlayer(
                    by: localPlayer?.id ?? ""
                ) {
                    GameCenterAvatarView(
                        player: gkPlayer,
                        size: CGSize(width: 60, height: 60)
                    )
                } else {
                    Image(systemName: "person.fill")
                        .font(.title)
                        .frame(width: 60, height: 60)
                        .background(Color.newRed)
                        .clipShape(Circle())
                }

                if isMyTurn {
                    Text("Your Turn")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
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
                    id: localPlayer?.id ?? ""
                )
                if bookRanks.isEmpty {
                    // Message when no books completed yet
                    Text("You haven't completed any books yet.")
                        .foregroundColor(.secondary)
                } else {
                    // List all completed book ranks
                    ForEach(bookRanks, id: \.self) { rank in
                        BookCardView(rank: rank)
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
            books: 0
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
