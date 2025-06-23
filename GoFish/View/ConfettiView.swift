//
//  ConfettiView.swift
//  GoFish
//
//  Created by Amelia on 21/06/25.
//

import SwiftUI
import UIKit

struct ConfettiView: UIViewRepresentable {
    var colors: [UIColor] = [.white, .black]

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)

        let cells: [CAEmitterCell] = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime = 5.0
            cell.lifetimeRange = 0
            cell.velocity = 150
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.spin = 3.5
            cell.spinRange = 1.0
            cell.scale = 0.04
            cell.scaleRange = 0.02
            cell.color = color.cgColor
            cell.contents = UIImage(systemName: "circle.fill")?
                .withTintColor(color, renderingMode: .alwaysOriginal)
                .cgImage
            return cell
        }

        emitter.emitterCells = cells
        view.layer.addSublayer(emitter)

        // Stop confetti after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            emitter.birthRate = 0
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
