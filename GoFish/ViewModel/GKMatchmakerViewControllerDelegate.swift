//
//  GKMatchmakerViewControllerDelegate.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 11/06/25.
//

import GameKit

extension MatchManager: GKMatchmakerViewControllerDelegate {
    func matchmakerViewController(
        _ viewController: GKMatchmakerViewController, didFind match: GKMatch
    ) {
        viewController.dismiss(animated: true)
        setupGame(newMatch: match)
    }

    func matchmakerViewControllerWasCancelled(
        _ viewController: GKMatchmakerViewController
    ) {
        viewController.dismiss(animated: true)
        gameState = .menu
    }

    func matchmakerViewController(
        _ viewController: GKMatchmakerViewController,
        didFailWithError error: Error
    ) {
        viewController.dismiss(animated: true)
        print("Matchmaking failed with error: \(error.localizedDescription)")
        gameState = .menu
    }
}
