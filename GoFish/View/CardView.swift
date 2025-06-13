//
//  Card.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import SwiftUI

struct CardView: View {
    let card: Card
    
    private var cardColor: Color {
        switch card.suit {
        case .hearts, .diamonds:
            return .red
        case .clubs, .spades:
            return .black
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .stroke(Color.gray, lineWidth: 1)
            .aspectRatio(2.5 / 3.5, contentMode: .fit)
            .overlay(alignment: .topLeading) {
                VStack(spacing: 2) {
                    Text(card.rank.rawValue)
                        .font(.headline)
                        .foregroundColor(cardColor)
                    
                    Image(systemName: card.suit.symbolName)
                }
                .padding(8)
            }
            .foregroundColor(cardColor)
    }
}

#Preview {
    HStack {
        CardView(card: Card(rank: .king, suit: .hearts))
        CardView(card: Card(rank: .ten, suit: .spades))
    }
    .padding()
    .frame(height: 200)
}
