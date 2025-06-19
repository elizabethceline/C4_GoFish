//
//  Deck.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import Foundation

@Observable
class  Deck {
    private var cards: [Card] = []

    init() {
        self.createFullDeck()
    }
    
    init(from cards: [Card]) {
        self.cards = cards
    }

    func createFullDeck() {
        cards = []
        for suit in Card.Suit.allCases {
            for rank in Card.Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
    }

    func shuffle() {
        cards.shuffle()
    }

    func deal(count: Int) -> [Card] {
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

    func getCards() -> [Card] {
        return cards
    }
}
