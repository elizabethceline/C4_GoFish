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
        //gantiwarna
        case .hearts, .diamonds:
            return .newRed
        case .clubs, .spades:
            return .black
        }
    }
//gantiviewamel
    private var cardBackgroundName: String {
          switch card.rank {
          case .ace:
              return "cardimageace" // Nama file gambar untuk As
          case .two:
              return "cardimage2"
          case .three:
              return "cardimage3"
          case .four:
              return "cardimage4"
          case .five:
              return "cardimage5"
          case .six:
              return "cardimage6"
          case .seven:
              return "cardimage7"
          case .eight:
              return "cardimage8"
          case .nine:
              return "cardimage9"
          case .ten:
              return "cardimage10"
          case .jack:
              return "cardimagejack"
          case .queen:
              return "cardimagequeen"
          case .king:
              return "cardimageking"
          }
      }
      //gantibackground
      var body: some View {
          RoundedRectangle(cornerRadius: 10)
              .stroke(Color.gray, lineWidth: 1)
              .background(
                  Image(cardBackgroundName)
                      .resizable()
                      .scaledToFill()
              )
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .aspectRatio(2.5 / 3.5, contentMode: .fit)
              .overlay(alignment: .topLeading) {
                  VStack(spacing: 2) {
                                     Text(card.rank.rawValue)
                                         .font(.headline)
                                         .foregroundColor(cardColor)
                                     
                                     Image(systemName: card.suit.symbolName)
                                 }
                                 .padding(6)
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
