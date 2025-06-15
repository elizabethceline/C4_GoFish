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
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
            
            Image(systemName: "staroflife.fill")
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 40))
                .shadow(radius: 2)
        }
    }
}

#Preview {
    CardBackView()
        .frame(width: 80, height: 110)
}
