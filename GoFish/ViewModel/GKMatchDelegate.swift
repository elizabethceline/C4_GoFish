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
            let decodedData = try JSONDecoder().decode(GameData.self, from: data)

            DispatchQueue.main.async {
                self.players = decodedData.players ?? self.players
                self.cardsRemainingInDeck = decodedData.cardsRemainingInDeck ?? self.cardsRemainingInDeck
                self.currentPlayerId = decodedData.currentPlayerId ?? self.currentPlayerId
                self.gameLog = decodedData.gameLog ?? self.gameLog

                if decodedData.isGameOver ?? false {
                    self.gameState = .gameOver
                    self.winners = decodedData.winners ?? []
                } else {
                    self.gameState = .inGame
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
