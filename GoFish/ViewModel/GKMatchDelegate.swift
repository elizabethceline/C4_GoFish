//
//  GKMatchDelegate.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import GameKit

extension MatchManager: GKMatchDelegate {
    func match(
        _ match: GKMatch, didReceive data: Data,
        fromRemotePlayer player: GKPlayer
    ) {
        do {
            let decodedData = try JSONDecoder().decode(
                GameData.self, from: data)

            // update players and game state
            if let receivedPlayers = decodedData.players {
                DispatchQueue.main.async {
                    self.players = receivedPlayers
                    self.gameState = .inGame
                }
            }

            // update cards remaining in deck
            if let remainingCount = decodedData.cardsRemainingInDeck {
                DispatchQueue.main.async {
                    self.cardsRemainingInDeck = remainingCount
                }
            }

            // check game over
            if decodedData.isGameOver == true {
                DispatchQueue.main.async {
                    self.gameState = .gameOver
                }
            }

            // check winners
            if let receivedWinners = decodedData.winners {
                DispatchQueue.main.async {
                    self.winners = receivedWinners
                }
            }

        } catch {
            print("Error decoding data: \(error.localizedDescription)")
        }
    }
    func match(
        _ match: GKMatch, player: GKPlayer,
        didChange state: GKPlayerConnectionState
    ) {
        guard state == .disconnected else { return }

        let alert = UIAlertController(
            title: "Player Disconnected",
            message: "\(player.displayName) has left the game.",
            preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: "OK", style: .default,
                handler: { _ in
                    self.match?.disconnect()
                    self.resetGame()
                }))

        DispatchQueue.main.async {
            self.rootViewController?.present(alert, animated: true)
        }
    }
}
