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
    // bagi kartu awal
    let initialDeal: [String: [Card]]?
    let cardsRemaining: Int?

    init(initialDeal: [String: [Card]]? = nil, cardsRemaining: Int? = nil) {
        self.initialDeal = initialDeal
        self.cardsRemaining = cardsRemaining
    }

    // update game state yang lain nanti
}
