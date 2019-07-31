//
//  DashboardViewController.swift
//  BubblePop
//
//  Created by Krishna Hingu on 1/5/19.
//  Copyright © 2019 Krishna Hingu. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func settingButtonClick(_ sender: Any) {
        performSegue(withIdentifier: "SettingViewSegue", sender: nil)
    }
    
    @IBAction func playButtonClick(_ sender: Any) {
        performSegue(withIdentifier: "LoginViewSegue", sender: nil)
    }
    
    @IBAction func scoreButtonClick(_ sender: Any) {
        print("score")
        performSegue(withIdentifier: "ScoreViewSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
