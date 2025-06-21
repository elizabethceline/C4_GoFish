//
//  GameOverView.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 17/06/25.
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var matchManager: MatchManager

    var body: some View {

        VStack(spacing: 15) {
            Spacer()

           // Text("Game Over!")
             //   .font(.largeTitle.bold())
             //   .foregroundColor(.yellow)
             //   .padding(.bottom, 20)
            
            ZStack {
                    Image("gameoverbackground")
                        .resizable()
                        .frame(width: 450, height: 600)
                        .aspectRatio(contentMode: .fit)
                        .edgesIgnoringSafeArea(.all)
                
                
                VStack(spacing: 15) {
                    ForEach(matchManager.players.sorted { $0.books > $1.books }) {
                        player in
                        
                        let isWinner = matchManager.winners.contains(player)
                        
                       
                        HStack(spacing: 15) {
                            Text(player.displayName)
                                .font(isWinner ? .system(size: 20).bold() : .system(size: 20))
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            
                            if isWinner {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title2)
                            }
                            
                            Spacer()
                            
                            Text("Books: \(player.books)")
                                .font(isWinner ? .system(size: 20).bold() : .system(size: 20))
                        }
                        .padding()
                        .background(
                            isWinner
                            ? Color.yellow.opacity(0.2)
                            : Color.black.opacity(0.3)
                        )
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    isWinner ? Color.yellow : Color.clear,
                                    lineWidth: 3)
                        )
                        .shadow(
                            color: isWinner ? .yellow.opacity(0.5) : .clear,
                            radius: 10
                        )
                        .scaleEffect(isWinner ? 1.05 : 1.0)
                    }
                }
                
                .frame(width: 300, height: 70)
            }
            .padding(.horizontal)

            Spacer()
//gantiimage
            Button {
                matchManager.resetGame()
            } label: {
                Image("backtomenubutton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 70)
                }

            Spacer()
        }
        .padding()
        .foregroundColor(.white)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.6),
            value: matchManager.players)
    }
}

#Preview {
    let manager = MatchManager()

    let player1 = Player(id: "1", displayName: "Player A", hand: [], books: 2)
    let player2 = Player(id: "2", displayName: "Player asdasdasdB", hand: [], books: 3)
    let player3 = Player(id: "3", displayName: "Player C", hand: [], books: 1)

    manager.players = [player1, player2, player3]

    manager.winners = [player2]

    // Draw
    // let player1 = Player(id: "1", displayName: "Pemain A (Tie)", hand: [], books: 3)
    // let player2 = Player(id: "2", displayName: "Pemain B (Tie)", hand: [], books: 3)
    // manager.players = [player1, player2, player3]
    // manager.winners = [player1, player2]

    return GameOverView(matchManager: manager)
}
