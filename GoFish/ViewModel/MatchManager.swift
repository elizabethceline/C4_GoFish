//
//  MatchManager.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import Foundation
import GameKit

class MatchManager: NSObject, ObservableObject {
    @Published var authenticationState = PlayerAuthState.authenticating
    @Published var match: GKMatch?
    var otherPlayers = [GKPlayer]()
    var localPlayer = GKLocalPlayer.local

    @Published var gameState: GameState = .menu
    @Published var players = [Player]()
    @Published var gameLog: [String] = ["Welcome to Go Fish!"]
    @Published var currentPlayerId: String?
    @Published var cardsRemainingInDeck: Int = 52
    @Published var winners: [Player] = []

    // Properti baru untuk mengontrol animasi pembagian kartu
    @Published var cardsBeingDealt: [(card: Card, playerID: String, dealOrder: Int)] = []
    
    var deck = Deck()

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
        request.inviteMessage = "Would you like to play SKETCHY?"

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

        if localPlayer.gamePlayerID == hostID {
            print("I am the host. Dealing cards...")
            dealInitialCards()
        } else {
            print("I am a client. Waiting for host to deal.")
        }
    }
    
    private func dealInitialCards() {
        deck.createFullDeck()
        deck.shuffle()

        var initialPlayers = [Player]()
        let allGKPlayers = (self.match?.players.map { $0.gamePlayerID } ?? []) + [localPlayer.gamePlayerID]

        // Buat objek Player awal dari GKPlayer yang ada
        for gkPlayerID in allGKPlayers {
            // Temukan GKPlayer yang sesuai untuk mendapatkan displayName
            let gkPlayer = (self.match?.players.first(where: { $0.gamePlayerID == gkPlayerID })) ?? localPlayer
            initialPlayers.append(
                Player(
                    id: gkPlayerID, displayName: gkPlayer.displayName,
                    hand: [], books: 0))
        }

        DispatchQueue.main.async {
            self.players = initialPlayers
        }

        var tempPlayerHands = [String: [Card]]()
        allGKPlayers.forEach { tempPlayerHands[$0] = [] } // Menggunakan gamePlayerID string sebagai key

        let initialHandSize = 5
        let totalCardsToDeal = allGKPlayers.count * initialHandSize
        var dealtCardsCount = 0

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] timer in // Gunakan [weak self]
            guard let self = self else { // Pastikan self masih ada
                timer.invalidate()
                return
            }

            guard let card = self.deck.deal(count: 1).first else {
                timer.invalidate()
                // Setelah semua kartu terbagi, panggil finalizeInitialDeal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.finalizeInitialDeal(finalHands: tempPlayerHands)
                }
                return
            }

            let playerIndex = dealtCardsCount % allGKPlayers.count
            let receivingPlayerID = allGKPlayers[playerIndex] // Cukup ID-nya saja, bukan objek GKPlayer lagi

            // 1. Tambahkan kartu ke data tangan SEMENTARA.
            tempPlayerHands[receivingPlayerID]?.append(card)

            // 2. Tambahkan kartu ke properti animasi. Ini akan memicu UI update.
            // Pastikan ini di main thread karena ini mengubah @Published
            DispatchQueue.main.async {
                self.cardsBeingDealt.append((card: card, playerID: receivingPlayerID, dealOrder: dealtCardsCount))
            }

            dealtCardsCount += 1

            if dealtCardsCount == totalCardsToDeal {
                timer.invalidate()
                // Panggil finalizeInitialDeal setelah semua kartu terbagi
                // Ini akan memastikan animasi memiliki waktu untuk selesai sebelum kartu dihapus dari cardsBeingDealt
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.finalizeInitialDeal(finalHands: tempPlayerHands)
                }
            }
        }
    }
       
    private func finalizeInitialDeal(finalHands: [String: [Card]]) {
            // 4. Update state permainan utama dengan data final.
            for i in 0..<players.count {
                let playerID = players[i].id
                players[i].hand = finalHands[playerID] ?? []
            }
            
            // 5. Kosongkan array animasi agar kartu yang terbang menghilang.
            self.cardsBeingDealt.removeAll()
            
            // Sekarang, lanjutkan logika permainan seperti biasa.
            for player in self.players {
                checkForBooks(forPlayerId: player.id)
            }

            let remainingCount = self.deck.cardsRemaining
            let gameData = GameData(
                players: self.players, cardsRemainingInDeck: remainingCount)
            sendData(gameData)

            DispatchQueue.main.async {
                self.cardsRemainingInDeck = remainingCount
                self.gameState = .inGame
                self.currentPlayerId = self.players.first?.id
                if !self.gameLog.contains(where: { $0.contains("made a book") }) {
                    self.gameLog.append("Cards have been dealt.")
                }
            }
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

                let playerName = players[playerIndex].displayName
                let logMessage =
                    "🎉 \(playerName) made a book of \(rank.rawValue)!"
                gameLog.append(logMessage)
                print(logMessage)
            }
        }
    }

    @discardableResult
    func checkGameOver() -> Bool {
        if players.contains(where: { $0.hand.isEmpty }) {
            endGame()
            return true
        }

        if cardsRemainingInDeck <= 0 {
            endGame()
            return true
        }

        return false
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
            players: self.players, isGameOver: true, winners: self.winners)
        sendData(gameOverData)
    }

    func resetGame() {
        DispatchQueue.main.async {
            self.gameState = .menu
            self.match = nil
            self.players = []
            self.otherPlayers = []
            self.gameLog = ["Welcome to Go Fish!"]
        }
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
}
