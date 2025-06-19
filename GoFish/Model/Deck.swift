//
//  Deck.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import Foundation

struct Deck {
    private var cards: [Card] = []

    init() {
        self.createFullDeck()
    }

    mutating func createFullDeck() {
        cards = []
        for suit in Card.Suit.allCases {
            for rank in Card.Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
    }

    mutating func shuffle() {
        cards.shuffle()
    }

    mutating func deal(count: Int) -> [Card] {
        let countToDeal = min(count, cards.count)
        let dealtCards = Array(cards.prefix(countToDeal))
        cards.removeFirst(countToDeal)
        return dealtCards
    }

    var cardsRemaining: Int {
        return cards.count
    }

    var isEmpty: Bool {
        return cards.isEmpty
    }

    var topCardDescription: String? {
        cards.first.map { "\($0.rank.rawValue) of \($0.suit.rawValue)" }
    }
}
