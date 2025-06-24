//
//  GameAvatarView.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 21/06/25.
//

import SwiftUI
import GameKit

struct GameCenterAvatarView: View {
    let player: GKPlayer
    var size: CGSize = CGSize(width: 50, height: 50)

    @State private var image: Image?

    var body: some View {
        ZStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                    .foregroundColor(.white)
                    .background(Color.gray.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .onAppear {
            player.loadPhoto(for: GKPlayer.PhotoSize.normal, withCompletionHandler: { uiImage, error in
                if let uiImage = uiImage {
                    self.image = Image(uiImage: uiImage)
                }
            })
        }
    }
}
