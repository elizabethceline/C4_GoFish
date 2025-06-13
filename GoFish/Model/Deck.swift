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
        guard count <= cards.count else { return [] }
        let dealtCards = Array(cards.prefix(count))
        cards.removeFirst(count)
        return dealtCards
    }

    var cardsRemaining: Int {
        return cards.count
    }
}
