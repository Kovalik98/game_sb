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

class Mouse: NSObject {
    var view: UIView
    var frame: CGRect
    var delegate: MouseDelegate?
    
    private var container: UIView!
    private var mouse: UIImageView!
    private var hole: UIImageView!
    
    private var isCathed = false
    private var timer: Timer?
    private var timerAlive: Timer?
    
    private var showTime: TimeInterval = 1.0
    private var waitTime: TimeInterval = 1.0
    private var hideTime: TimeInterval = 0.3
    
    private var isKilled = false
    
    private var mouseShowSound: AVAudioPlayer?
    private var mouseEatedSound: AVAudioPlayer?
    private var mouseKillSound: AVAudioPlayer?
    
    private var mouseKilledTime = 0

    init(view: UIView, frame: CGRect) {
        self.view = view
        self.frame = frame
        super.init()
        buildHoleAndMouse()

        mouseShowSound = SoundEngine.shared.initSound("show.wav")
        mouseEatedSound = SoundEngine.shared.initSound("show.wav")
        mouseKillSound = SoundEngine.shared.initSound("eated.wav")
    }
    
    func buildHoleAndMouse() {
        container = UIView(frame: frame)
        container.backgroundColor = .clear
        
        hole = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height))
        hole.contentMode = .scaleAspectFit
        hole.image = UIImage(named: "hole")
        hole.clipsToBounds = true
        hole.layer.cornerRadius = frame.width / 3
        
        container.addSubview(hole)
        view.addSubview(container)
        
        mouse = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height))
        mouse.contentMode = .scaleAspectFit
        mouse.image = UIImage(named: "dollar")
        mouse.transform = CGAffineTransform.identity.translatedBy(x: 0.0, y: frame.height)
        
        mouse.isUserInteractionEnabled = true
        hole.isUserInteractionEnabled = true
        container.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onMouseTap))
        mouse.addGestureRecognizer(tap)
        
        hole.addSubview(mouse)
    }
    
    @objc
    func onMouseTap() {
        delegate?.onMouseCathed()
        isCathed = true
        mouseKilledTime += 1
        mouseKillSound?.play()
        timer?.invalidate()
        UIView.animate(withDuration: 0.15, animations: {
            self.mouse.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        }, completion: ({_ in
            self.mouse.transform = CGAffineTransform.identity.translatedBy(x: 0.0, y: self.frame.height)
            self.startMouse()
        }))
    }
    
    func removeFromParent() {
        isKilled = true
        timerAlive?.invalidate()
        timer?.invalidate()
        mouse.removeFromSuperview()
        hole.removeFromSuperview()
        container.removeFromSuperview()
    }
    
    func show(showTime: TimeInterval, waitTime: TimeInterval) {
        self.showTime = showTime
        self.waitTime = waitTime
        
        isCathed = false
        
        mouseShowSound?.play()
        UIView.animate(withDuration: showTime, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.mouse.transform = CGAffineTransform.identity.translatedBy(x: 0.0, y: 0.0)
        }, completion: ({_ in
            self.hideAnimated()
        }))
    }
    
    func hideAnimated() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: waitTime, repeats: false, block: ({_ in
            if self.isCathed == false {
                UIView.animate(withDuration: self.hideTime, animations: {
                    self.mouse.transform = CGAffineTransform.identity.translatedBy(x: 0.0, y: self.frame.height)
                }, completion: ({_ in
                    if self.isCathed == false && self.isKilled == false && self.mouse.superview != nil {
                        self.mouseEatedSound?.play()
                        self.delegate?.onCheeseEaten()
                    }
                    if self.isKilled == false {
                        self.startMouse()
                    }
                }))
            }
            self.timer?.invalidate()
        }))
    }
    
    func startMouse() {
        isKilled = false
        let time: TimeInterval = TimeInterval(CGFloat.random(in: 1...8))
        
        timerAlive = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: ({_ in
            if self.isKilled {
                return
            }
            let showTime = TimeInterval(CGFloat.random(in: 0.3...0.8))
            let waitTime = TimeInterval(CGFloat.random(in: 0.2...1.4))
            self.show(showTime: showTime, waitTime: waitTime)
        }))
    }
    
    func kill() {
        isKilled = true
        mouse.isHidden = true
        timerAlive?.invalidate()
        timer?.invalidate()
        
        timerAlive = nil
        timer = nil
        
        mouseKillSound = nil
        mouseEatedSound = nil
        mouseShowSound = nil
    }
    
}

protocol MouseDelegate {
    func onMouseCathed()
    func onCheeseEaten()
}
