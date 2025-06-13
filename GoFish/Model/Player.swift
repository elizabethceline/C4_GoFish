//
//  Player.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import Foundation
import GameKit

struct Player: Identifiable, Codable, Hashable {
    let id: String
    let displayName: String
    var hand: [Card]
    var books: Int

    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum PlayerAuthState: String {
    case authenticating = "Logging in to Game Center..."
    case unauthenticated = "Please sign in to Game Center to play."
    case authenticated = ""
    case error = "There was an error logging into Game Center."
    case restricted = "You're not allowed to play multiplayer games!"
}
