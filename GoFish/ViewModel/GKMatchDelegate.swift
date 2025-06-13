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

            // bagi kartu awal
            if let initialDeal = decodedData.initialDeal {
                var allPlayersInfo = [Player]()

                for (playerID, hand) in initialDeal {
                    let displayName: String
                    if playerID == localPlayer.gamePlayerID {
                        displayName = localPlayer.displayName
                    } else {
                        displayName =
                            self.otherPlayers.first(where: {
                                $0.gamePlayerID == playerID
                            })?.displayName ?? "Unknown Player"
                    }
                    allPlayersInfo.append(
                        Player(
                            id: playerID, displayName: displayName, hand: hand,
                            books: 0))
                }

                DispatchQueue.main.async {
                    self.players = allPlayersInfo.sorted(by: {
                        $0.displayName < $1.displayName
                    })
                    self.gameState = .inGame
                    self.gameLog.append("Received cards from host.")
                }
            }

            if let remainingCount = decodedData.cardsRemaining {
                DispatchQueue.main.async {
                    self.cardsRemainingInDeck = remainingCount
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
