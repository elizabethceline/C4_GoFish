//
//  AIPlayer.swift
//  GoFish
//
//  Created by Christian Andrew Sinaga on 23/06/25.
//

import Foundation

class AIPlayerLogic {
    func chooseRank(fromHand hand: [Card]) -> Card.Rank? {
        return hand.randomElement()?.rank
    }

    func chooseOpponent(from players: [Player], excluding aiId: String) -> Player? {
        let opponents = players.filter { $0.id != aiId }
        return opponents.randomElement()
    }
}
