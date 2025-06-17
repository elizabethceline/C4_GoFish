//
//  CardBackView.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import SwiftUI

struct CardBackView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
                .background(
                    Image("cardbackview")
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .aspectRatio(2.5 / 3.5, contentMode: .fit)
                .overlay(alignment: .topLeading) {
                }
        }
    }
}

#Preview {
    CardBackView()
        .padding()
}
