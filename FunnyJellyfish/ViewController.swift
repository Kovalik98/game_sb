//
//  ViewController.swift
//  FunnyJellyfish
//
//  Created by Nazar on 22.03.2019.
//  Copyright © 2019 Nazar. All rights reserved.
//


import UIKit

class ViewController: UIViewController {
    var gameMain: GameMain?

    override func viewDidLoad() {
        super.viewDidLoad()
        gameMain = GameMain(view: view)
        // gameMain?.startGame(level: 1)
        gameMain?.initGame()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }

    

}

