//
//  BookCardView.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 23/06/25.
//

import SwiftUI

struct BookCardView: View {
    let rank: Card.Rank

    var body: some View {
        HStack(spacing: -30) {
            ForEach(Card.Suit.allCases, id: \.self) { suit in
                CardView(card: Card(rank: rank, suit: suit))
                    .frame(width: 80, height: 120)
                    .transition(.scale)
            }
        }
        .padding()
        .background(Color.white.opacity(0.85).blur(radius: 1))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

#Preview {
    BookCardView(rank: .ace)
        .padding()
}
