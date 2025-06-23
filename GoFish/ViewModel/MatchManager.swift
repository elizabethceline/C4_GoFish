//
//  MatchManager.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import Foundation
import GameKit

struct CompletedBook: Equatable {
    let playerId: String
    let rank: Card.Rank
}

class MatchManager: NSObject, ObservableObject {
    @Published var authenticationState = PlayerAuthState.authenticating
    @Published var match: GKMatch?
    var otherPlayers = [GKPlayer]()
    var localPlayer = GKLocalPlayer.local

    @Published var gameState: GameState = .menu
    @Published var players = [Player]()
    @Published var gameLog: [String] = ["It's Sketchy Time!"]
    @Published var currentPlayerId: String?
    @Published var cardsRemainingInDeck: Int = 52
    @Published var winners: [Player] = []
    @Published var isVsAI: Bool = false
    @Published var lastCompletedBook: CompletedBook?

    var deck = Deck()
    // Store the original dealt deck for memory tracking
    private var dealtCards = [Card]()
    private var usedCards = [Card]()

    var rootViewController: UIViewController? {
        let windowScene =
            UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }

    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { [self] vc, e in
            if let viewController = vc {
                rootViewController?.present(viewController, animated: true)
                return
            }
            if let error = e {
                authenticationState = .error
                print("Authentication Error: \(error.localizedDescription)")
                return
            }
            if localPlayer.isAuthenticated {
                if localPlayer.isMultiplayerGamingRestricted {
                    authenticationState = .restricted
                } else {
                    authenticationState = .authenticated
                }
            } else {
                authenticationState = .unauthenticated
            }
        }
    }

    func startMatchmaking() {
        let request = GKMatchRequest()
        request.minPlayers = 3
        request.maxPlayers = 3
        request.inviteMessage = "Would you like to play Go Fish?"

        guard
            let matchmakingVC = GKMatchmakerViewController(
                matchRequest: request)
        else { return }
        matchmakingVC.matchmakerDelegate = self
        rootViewController?.present(matchmakingVC, animated: true)
        gameState = .matchmaking
    }

    // game logic
    func setupGame(newMatch: GKMatch) {
        self.match = newMatch
        self.match?.delegate = self
        self.otherPlayers = self.match?.players ?? []

        print("Match found. Total players: \(otherPlayers.count + 1)")

        // select random host
        let allPlayerIDs =
            (self.match?.players.map { $0.gamePlayerID } ?? []) + [
                localPlayer.gamePlayerID
            ]
        let hostID = allPlayerIDs.sorted().first

        if localPlayer.gamePlayerID != hostID {
            self.deck = Deck(from: [])  // Empty deck for clients
            print("I am a client. Waiting for host to deal.")
            return
        }

        if localPlayer.gamePlayerID == hostID {
            print("I am the host. Dealing cards...")
            dealInitialCards()
        } else {
            print("I am a client. Waiting for host to deal.")
        }
    }

    private func dealInitialCards() {
        deck = Deck()
        deck.shuffle()

        var allPlayersInfo = [Player]()
        let initialHandSize = 5

        let allPlayers = [localPlayer] + otherPlayers
        for p in allPlayers {
            let playerHand = deck.deal(count: initialHandSize)
            allPlayersInfo.append(
                Player(
                    id: p.gamePlayerID, displayName: p.displayName,
                    hand: playerHand, books: 0))
        }

        if isVsAI {
            let aiPlayer1 = Player(
                id: "AI-1",
                displayName: "SketchyBot 🤖 1",
                hand: deck.deal(count: initialHandSize),
                books: 0
            )
            let aiPlayer2 = Player(
                id: "AI-2",
                displayName: "SketchyBot 🤖 2",
                hand: deck.deal(count: initialHandSize),
                books: 0
            )
            allPlayersInfo.append(contentsOf: [aiPlayer1, aiPlayer2])
        }

        self.players = allPlayersInfo
        if isVsAI, let currentId = self.players.first?.id, currentId.starts(with: "AI") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.runAITurn()
            }
        }
        // Remember all dealt cards for memory tracking
        self.dealtCards = allPlayersInfo.flatMap { $0.hand }
        self.usedCards = self.dealtCards

        for player in self.players {
            checkForBooks(forPlayerId: player.id)
        }

        let remainingCount = self.deck.cardsRemaining
        let gameData = GameData(
            players: self.players,
            cardsRemainingInDeck: remainingCount,
            isGameOver: false,
            winners: nil,
            currentPlayerId: self.players.first?.id,
            gameLog: self.gameLog,
            shuffledDeck: deck.getCards()
        )
        sendData(gameData)

        DispatchQueue.main.async {
            self.cardsRemainingInDeck = remainingCount
            self.gameState = .inGame
            self.currentPlayerId = self.players.first?.id
        }
    }
    // Return all books (completed sets of 4) collected by a specific player
    func booksForPlayer(id: String) -> [Card.Rank] {
        return players.first(where: { $0.id == id })?.bookRanks ?? []
    }

    func checkForBooks(forPlayerId: String) {
        guard
            let playerIndex = players.firstIndex(where: { $0.id == forPlayerId }
            )
        else { return }

        let groupedByRank = Dictionary(
            grouping: players[playerIndex].hand, by: { $0.rank })

        for (rank, cards) in groupedByRank {
            if cards.count == 4 {
                players[playerIndex].books += 1
                players[playerIndex].hand.removeAll { $0.rank == rank }
                usedCards.removeAll { $0.rank == rank }
                players[playerIndex].bookRanks.append(rank)
                let playerName = players[playerIndex].displayName
                let logMessage =
                    "🎉 \(playerName) made a book of \(rank.rawValue)!"
                gameLog.append(logMessage)
                print(logMessage)
                lastCompletedBook = CompletedBook(playerId: forPlayerId, rank: rank)
            }
        }
        
        let gameData = GameData(
            players: self.players,
            cardsRemainingInDeck: self.deck.cardsRemaining,
            isGameOver: false,
            winners: nil,
            currentPlayerId: self.currentPlayerId,
            gameLog: self.gameLog,
            shuffledDeck: deck.getCards()
        )
        sendData(gameData)
    }

    @discardableResult
    func checkGameOver() -> Bool {
        if players.contains(where: { $0.hand.isEmpty }) {
            endGame()
            return true
        }

        if cardsRemainingInDeck <= 0 || deck.isEmpty {
            endGame()
            return true
        }

        return false
    }

    // Handle a player's turn: asking another player for a rank
    func takeTurn(
        askingPlayerId: String, askedPlayerId: String, requestedRank: Card.Rank
    ) {
        guard gameState == .inGame else {
            print("Game is not active.")
            return
        }

        guard currentPlayerId == askingPlayerId else {
            print("Not this player's turn.")
            return
        }

        guard
            let askerIndex = players.firstIndex(where: {
                $0.id == askingPlayerId
            }),
            let askedIndex = players.firstIndex(where: {
                $0.id == askedPlayerId
            })
        else { return }

        let askedPlayer = players[askedIndex]
        let matchingCards = askedPlayer.hand.filter { $0.rank == requestedRank }

        if !matchingCards.isEmpty {
            // Transfer matching cards to asker
            players[askerIndex].hand.append(contentsOf: matchingCards)
            players[askedIndex].hand.removeAll { $0.rank == requestedRank }

            let message =
                "\(players[askerIndex].displayName) got \(matchingCards.count) \(requestedRank.rawValue)(s) from \(askedPlayer.displayName)."
            gameLog.append(message)
            print(message)

            // Check for books
            checkForBooks(forPlayerId: askingPlayerId)

            // AI gets another turn if it succeeded
            if isVsAI, askingPlayerId.starts(with: "AI") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.runAITurn()
                }
            }
        } else {
            // Go Fish
            if let drawnCard = deck.deal(count: 1).first {
                players[askerIndex].hand.append(drawnCard)
                usedCards.append(drawnCard)
                gameLog.append(
                    "\(players[askerIndex].displayName) asked for \(requestedRank.rawValue) from \(askedPlayer.displayName) but got nothing. Sketchy!"
                )
                print("\(players[askerIndex].displayName) drew a card.")
                cardsRemainingInDeck = deck.cardsRemaining

                // Check for book from drawn card
                checkForBooks(forPlayerId: askingPlayerId)
            }

            advanceTurn()
        }

        // Sync data with other players
        let gameData = GameData(
            players: self.players,
            cardsRemainingInDeck: deck.cardsRemaining,
            isGameOver: false,
            winners: nil,
            currentPlayerId: self.currentPlayerId,
            gameLog: self.gameLog,
            shuffledDeck: deck.getCards()

        )
        sendData(gameData)

        _ = checkGameOver()
    }

    // Rotate to the next player's turn
    func advanceTurn() {
        guard let currentId = currentPlayerId,
            let index = players.firstIndex(where: { $0.id == currentId })
        else { return }
        let nextIndex = (index + 1) % players.count
        currentPlayerId = players[nextIndex].id
        gameLog.append("It's now \(players[nextIndex].displayName)'s turn.")
        let gameData = GameData(
            players: self.players,
            cardsRemainingInDeck: self.deck.cardsRemaining,
            isGameOver: false,
            winners: nil,
            currentPlayerId: self.currentPlayerId,
            gameLog: self.gameLog,
            shuffledDeck: deck.getCards()
        )
        sendData(gameData)
        if isVsAI, let currentId = currentPlayerId, currentId.starts(with: "AI") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.runAITurn()
            }
        }
    }

    func determineWinner() {
        guard let maxBooks = players.map({ $0.books }).max() else {
            return
        }

        let allWinners = players.filter { $0.books == maxBooks }

        self.winners = allWinners

        if allWinners.count == 1, let winner = allWinners.first {
            gameLog.append("🏆 \(winner.displayName) wins the game!")
        } else {
            let winnerNames = allWinners.map { $0.displayName }.joined(
                separator: ", ")
            gameLog.append("🏆 It's a tie between: \(winnerNames)!")
        }
    }

    func endGame() {
        guard gameState != .gameOver else { return }

        gameState = .gameOver
        determineWinner()

        let gameOverData = GameData(
            players: self.players,
            cardsRemainingInDeck: self.deck.cardsRemaining,
            isGameOver: true,
            winners: self.winners,
            currentPlayerId: self.currentPlayerId,
            gameLog: self.gameLog,
            shuffledDeck: deck.getCards()
        )
        sendData(gameOverData)
    }

    func resetGame() {
        DispatchQueue.main.async {
            self.gameState = .menu
            self.match = nil
            self.players = []
            self.otherPlayers = []
            self.gameLog = ["It's Sketchy Time!"]
        }
    }
    
    func getGKPlayer(by id: String) -> GKPlayer? {
        if id == localPlayer.gamePlayerID {
            return localPlayer
        }
        return otherPlayers.first(where: { $0.gamePlayerID == id })
    }

    func sendData(_ data: GameData) {
        guard let match = match else { return }
        do {
            let encodedData = try JSONEncoder().encode(data)
            try match.sendData(toAllPlayers: encodedData, with: .reliable)
        } catch {
            print(
                "Error encoding or sending data: \(error.localizedDescription)")
        }
    }
    
    func runAITurn() {
        guard let aiPlayer = players.first(where: { $0.id == currentPlayerId && $0.id.starts(with: "AI") }) else { return }
        guard let rank = aiPlayer.hand.randomElement()?.rank else {
            advanceTurn()
            return
        }
        let targets = players.filter { $0.id != aiPlayer.id }
        guard let target = targets.randomElement() else {
            advanceTurn()
            return
        }

        takeTurn(
            askingPlayerId: aiPlayer.id,
            askedPlayerId: target.id,
            requestedRank: rank
        )
    }
    /// Start a local AI-only game, bypassing Game Center
    func startAIGame() {
        self.isVsAI = true
        self.gameState = .inGame
        self.dealInitialCards()
    }
}
