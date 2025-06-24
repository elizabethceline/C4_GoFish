//
//  SoundManager.swift
//  GoFish
//
//  Created by Elizabeth Celine Liong on 24/06/25.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?
    private var player2: AVAudioPlayer?

    private init() {}
    
    func playBackgroundMusic() {
        playMusic(named: "soundtrack.mp3", withExtension: "mp3")
    }

    func playCardDealSound() {
        playSound(named: "card_deal.wav", withExtension: "wav")
    }

    func playGameOverSound() {
        playSound(named: "game_over.wav", withExtension: "wav")
    }
    
    func playBookSound() {
        playSound(named: "book.wav", withExtension: "wav")
    }

    private func playSound(named name: String, withExtension ext: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            print("Sound file \(name).\(ext) not found.")
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            //            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
    
    private func playMusic(named name: String, withExtension ext: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            print("Sound file \(name).\(ext) not found.")
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            player2 = try AVAudioPlayer(contentsOf: url)
            player2?.play()
            player2?.volume = 0.2
            player2?.numberOfLoops = -1
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }

    func stopSound() {
        player?.stop()
        player = nil
    }
}
