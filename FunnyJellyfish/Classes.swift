//
//  ViewController.swift
//  FunnyJellyfish
//
//  Created by Nazar on 22.03.2019.
//  Copyright © 2019 Nazar. All rights reserved.
//


import AVFoundation
import Foundation
import UIKit

class ScreenInfo {
    var width: CGFloat
    var height: CGFloat
    var marginTop: CGFloat
    init() {
        self.width = UIScreen.main.bounds.width
        self.height = UIScreen.main.bounds.height
        self.marginTop = UIApplication.shared.statusBarFrame.height
    }
}

class GameInfo {
    var mouseCount: Int = 10
    var cheeseCount: Int = 10
    
}

class SoundEngine {
    static var shared = SoundEngine()
    var soundLose: AVAudioPlayer?
    var soundWin: AVAudioPlayer?
    var musicMenu: AVAudioPlayer?

    init() {
        soundLose = initSound("jellyfish-jam.mp3")
        soundWin = initSound("win.wav")
        musicMenu = initSound("jellyfish-jam.mp3")
    }
    
    func initSound(_ name: String) -> AVAudioPlayer? {
        let s: AVAudioPlayer?
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            let url = URL(fileURLWithPath: path)
            do {
                s = try AVAudioPlayer(contentsOf: url)
                return s
            } catch {
                // couldn't load file :(
            }
        }
        return nil
    }
    
    func playMusic(player: AVAudioPlayer?) {
        player?.numberOfLoops = 100
        player?.play()
    }
    
    func stopMusic(player: AVAudioPlayer?) {
        player?.stop()
    }
    
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
