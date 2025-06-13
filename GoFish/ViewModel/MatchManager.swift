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

        var allPlayersInfo = [Player]()
        var dealData = [String: [Card]]()

        let initialHandSize = 5

        // local player's card
        let localPlayerHand = deck.deal(count: initialHandSize)
        allPlayersInfo.append(
            Player(
                id: localPlayer.gamePlayerID,
                displayName: localPlayer.displayName, hand: localPlayerHand,
                books: 0))
        dealData[localPlayer.gamePlayerID] = localPlayerHand

        // other player's card
        for p in otherPlayers {
            let playerHand = deck.deal(count: initialHandSize)
            allPlayersInfo.append(
                Player(
                    id: p.gamePlayerID, displayName: p.displayName,
                    hand: playerHand, books: 0))
            dealData[p.gamePlayerID] = playerHand
        }

        let remainingCount = self.deck.cardsRemaining

        // send data bagi kartu ke all player
        let gameData = GameData(
            initialDeal: dealData, cardsRemaining: remainingCount)
        sendData(gameData)

        // update local game state
        DispatchQueue.main.async {
            self.players = allPlayersInfo.sorted(by: {
                $0.displayName < $1.displayName
            })
            self.currentPlayerId = self.players.first?.id
            self.cardsRemainingInDeck = remainingCount
            self.gameState = .inGame
            self.gameLog.append("Cards have been dealt.")
        }
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
