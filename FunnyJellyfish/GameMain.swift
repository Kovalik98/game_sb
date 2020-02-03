//
//  ViewController.swift
//  FunnyJellyfish
//
//  Created by Nazar on 22.03.2019.
//  Copyright © 2019 Nazar. All rights reserved.
//


import Foundation
import UIKit

class GameMain {
    private var view: UIView
    private var level = 1
    private var screen: ScreenInfo
    private var game: GameInfo
    private var topFieldMargin: CGFloat = 16.0
    private var mice = [Mouse]()
    
    private var livesViews = [UIView]()
    private var cheeseViews = [UIView]()
    private var labelLevel: UILabel?
    
    private var viewResult: UIView?
    
    private var gamePaused = false
    
    init(view: UIView) {
        self.view = view
        self.screen = ScreenInfo()
        self.game = GameInfo()
        self.game.mouseCount = 5
        self.game.cheeseCount = 10
    }

    func startGame(level: Int) {
        viewResult?.removeFromSuperview()
        for m in mice {
            m.kill()
        }
        gamePaused = false
        game.cheeseCount = 10
        game.mouseCount = 5 + ((level-1) * 5)
        self.level = level
        buildLevel()
    }
    
    func buildLevel() {
        labelLevel?.removeFromSuperview()
        labelLevel = UILabel(frame: CGRect(x: 0.0, y: screen.marginTop + 4, width: screen.width, height: 24))
        labelLevel?.textColor = .white
        labelLevel?.text = "Level".localized + " \(level)"
        labelLevel?.textAlignment = .center
        view.addSubview(labelLevel!)

        // build mouse lives at the top
        makeLives()
        // build mouse grid
        makeGrid()
    }
    
    func clearLevel() {
        
    }
    
    func makeLives() {
        for v in livesViews {
            v.removeFromSuperview()
        }
        livesViews.removeAll()

        for v in cheeseViews {
            v.removeFromSuperview()
        }
        cheeseViews.removeAll()

        let w = (screen.width - 32.0) / CGFloat(10)
        topFieldMargin = screen.marginTop + (w * 2)
        
        var lineCount = game.mouseCount
        if game.mouseCount > 10 {
            lineCount = 9
        }
        for i in 0..<lineCount {
            let line = Int(i / 10)
            let leftIndent = i % 10

            let lineMargin: CGFloat = (CGFloat(line) * w) + 16
            let live = UIImageView(frame: CGRect(x: 16.0 + (CGFloat(leftIndent) * w), y: lineMargin + screen.marginTop + 16, width: w, height: w))
            live.image = UIImage(named: "dollar")
            live.contentMode = .scaleAspectFit
            view.addSubview(live)
            
            livesViews.append(live)
        }
        // add lives label
        if game.mouseCount > 10 {
            let label = UILabel(frame: CGRect(x: 16.0 + (w * 9.0), y: screen.marginTop + (w / 1), width: w + 15.0, height: 32.0))
            label.text = String(game.mouseCount)
            label.textAlignment = .center
            label.font = UIFont.monospacedDigitSystemFont(ofSize: 15.0, weight: .medium)
            view.addSubview(label)
            livesViews.append(label)
        }
        
        // add cheese
        for i in 0..<self.game.cheeseCount {
            let leftIndent = i % 10
            let live = UIImageView(frame: CGRect(x: 16.0 + (CGFloat(leftIndent) * w), y: topFieldMargin, width: w, height: w))
            live.image = UIImage(named: "thief")
            live.contentMode = .scaleAspectFit
            live.contentMode = .center
            view.addSubview(live)
            cheeseViews.append(live)
        }
        
        topFieldMargin = topFieldMargin + w
    }
    
    func makeGrid() {
        for m in mice {
            m.removeFromParent()
        }
        mice.removeAll()
        
        let w: CGFloat = ((screen.width - (16.0 * 4)) / 3.0)
        let rowCount: Int = Int((screen.height-topFieldMargin) / (w + 16.0))
        
        for row in 0..<rowCount {
            for i in 0..<3 {
                let rand = Int.random(in: 0...level+1)
                if rand == 0 || rand == level {
                    continue
                }

                let left: CGFloat = (w * CGFloat(i)) + (16.0 * CGFloat(i + 1))
                let top = topFieldMargin + (CGFloat(row) * w) + (16.0 * CGFloat(row + 1))
                let mouse = Mouse(view: view, frame: CGRect(x: left, y: top, width: w, height: w))
                mouse.delegate = self
                mice.append(mouse)
                if mice.count > (level + 2) {
                    break
                }
            }
            if mice.count > (level + 2) {
                break
            }
        }
        for m in mice {
            m.startMouse()
        }
    }
}

extension GameMain: MouseDelegate {
    func killAll() {
        for m in mice {
            m.kill()
        }
    }
    
    func onMouseCathed() {
        guard gamePaused == false else { return }
        game.mouseCount -= 1
        if game.mouseCount < 1 {
            killAll()
            gamePaused = true
            // you win!
            level += 1
            showWin()
            game.mouseCount = 10 + (level * 5)
            // startGame(level: level)
            return
        }
        makeLives()
    }
    
    func onCheeseEaten() {
        guard gamePaused == false else { return }
        game.cheeseCount -= 1
        if game.cheeseCount < 1 {
            killAll()
            gamePaused = true
            // you lose!
            showLose()
            game.mouseCount = 10 + (level * 5)
            // startGame(level: level)
            return
        }
        makeLives()
    }
}


extension GameMain {
    func showWin() {
        SoundEngine.shared.soundWin?.play()
        let i = UserDefaults.standard.integer(forKey: "top-level")
        if level > i {
            UserDefaults.standard.set(level - 1, forKey: "top-level")
        }
        showFinal(text: "You win!".localized)
    }
    func showLose() {
        SoundEngine.shared.soundLose?.play()
        showFinal(text: "You lose!".localized)
    }
    
    func showFinal(text: String) {
        viewResult?.removeFromSuperview()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            if self.gamePaused {
                SoundEngine.shared.playMusic(player: SoundEngine.shared.musicMenu)
            }
        })
        
        let height: CGFloat = 300.0
        let width: CGFloat = screen.width - 64.0

        let y = (screen.height / 2) - (height / 2)
        viewResult = UIView(frame: CGRect(x: 32.0, y: y, width: width, height: height))
    
        viewResult?.backgroundColor = .blue
        viewResult?.backgroundColor = UIColor(white: 1, alpha: 0.8)
        viewResult?.alpha = 1.0
        viewResult?.layer.cornerRadius = 16.0
        
        
        let labelResult = UILabel(frame: CGRect(x: 16.0, y: 10, width: width - 32.0, height: height - 40.0))
        labelResult.textAlignment = .center
        labelResult.text = text
        labelResult.numberOfLines = 2
        labelResult.font = UIFont.systemFont(ofSize: 32.0, weight: .medium)
        labelResult.textColor = .blue
        viewResult?.addSubview(labelResult)
        
        
        let imgMouse = UIImageView(frame: CGRect(x: 4, y: 4, width: 32, height: 32))
        imgMouse.image = UIImage(named: "dollar")
        viewResult?.addSubview(imgMouse)
        let lbMouse = UILabel(frame: CGRect(x: 40.0, y: 8.0, width: 64.0, height: 30.0))
        lbMouse.text = String(game.mouseCount)
        lbMouse.textColor = .blue
        viewResult?.addSubview(lbMouse)

        
        let imgCheese = UIImageView(frame: CGRect(x: width - 40, y: 5, width: 32, height: 32))
        imgCheese.image = UIImage(named: "thief")
        viewResult?.addSubview(imgCheese)
        let lbCheese = UILabel(frame: CGRect(x: width - 60.0, y: 8.0, width: 64.0, height: 30.0))
        lbCheese.text = String(game.cheeseCount)
        lbCheese.textColor = .blue
        viewResult?.addSubview(lbCheese)

        let labelTapToContinue = UILabel(frame: CGRect(x: 0.0, y: 272.0, width: width, height: 28.0))
        labelTapToContinue.textAlignment = .center
        labelTapToContinue.text = "Tap to start game👆🏼".localized
        labelTapToContinue.textColor = .blue
        viewResult?.addSubview(labelTapToContinue)
        
        viewResult?.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.viewResult?.alpha = 1.0
        })
        
        view.addSubview(viewResult!)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onContinueTap))
        viewResult?.isUserInteractionEnabled = true
        viewResult?.addGestureRecognizer(tap)
        
        let topLevel = UserDefaults.standard.integer(forKey: "top-level")
        if topLevel > 0 {
            let labelTopLevel = UILabel(frame: CGRect(x: 16.0, y: 170.0, width: width - 32.0, height: 30.0))
            labelTopLevel.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
            labelTopLevel.textColor = .white
            labelTopLevel.textAlignment = .center
            labelTopLevel.text = "Top level".localized + " \(topLevel)"
            labelTopLevel.textColor = .blue
            viewResult?.addSubview(labelTopLevel)
        }
    }
    
    @objc func onContinueTap() {
        SoundEngine.shared.stopMusic(player: SoundEngine.shared.musicMenu)
        viewResult?.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.viewResult?.alpha = 0.0
        }, completion: ({_ in
            self.viewResult?.removeFromSuperview()
            self.startGame(level: self.level)
        }))
    }
    
    func initGame() {
        SoundEngine.shared.playMusic(player: SoundEngine.shared.musicMenu)
        makeLives()
        showFinal(text: "I love jellyfish!".localized)
    }
}
