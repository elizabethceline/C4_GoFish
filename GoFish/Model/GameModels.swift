//
//  GameModels.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import Foundation

enum GameState {
    case menu
    case matchmaking
    case inGame
    case gameOver
}

// encode to JSON, will be sent to other players
struct GameData: Codable {
    let players: [Player]?
    let cardsRemainingInDeck: Int?
    let isGameOver: Bool?
    let winners: [Player]?
    let currentPlayerId: String?
    let gameLog: [String]?

    init(
        players: [Player]? = nil,
        cardsRemainingInDeck: Int? = nil,
        isGameOver: Bool? = nil,
        winners: [Player]? = nil,
        currentPlayerId: String? = nil,
        gameLog: [String]? = nil
    ) {
        self.players = players
        self.cardsRemainingInDeck = cardsRemainingInDeck
        self.isGameOver = isGameOver
        self.winners = winners
        self.currentPlayerId = currentPlayerId
        self.gameLog = gameLog
    }
}
