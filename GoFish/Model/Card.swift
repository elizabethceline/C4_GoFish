//
//  Card.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import Foundation

struct Card: Identifiable, Codable, Hashable, Equatable {
    var id: String { "\(rank.rawValue)-\(suit.rawValue)" }

    let rank: Rank
    let suit: Suit

    enum Rank: String, CaseIterable, Codable, Comparable {
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"
        case nine = "9"
        case ten = "10"
        case jack = "J"
        case queen = "Q"
        case king = "K"
        case ace = "A"

        private var sortValue: Int {
            switch self {
            case .two: return 2
            case .three: return 3
            case .four: return 4
            case .five: return 5
            case .six: return 6
            case .seven: return 7
            case .eight: return 8
            case .nine: return 9
            case .ten: return 10
            case .jack: return 11
            case .queen: return 12
            case .king: return 13
            case .ace: return 14
            }
        }

        static func < (lhs: Card.Rank, rhs: Card.Rank) -> Bool {
            return lhs.sortValue < rhs.sortValue
        }
    }

    enum Suit: String, CaseIterable, Codable {
        case spades = "♠️"
        case hearts = "♥️"
        case clubs = "♣️"
        case diamonds = "♦️"

        var symbolName: String {
            switch self {
            case .hearts:
                return "suit.heart.fill"
            case .diamonds:
                return "suit.diamond.fill"
            case .clubs:
                return "suit.club.fill"
            case .spades:
                return "suit.spade.fill"
            }
        }
    }
}
