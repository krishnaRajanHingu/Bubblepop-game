//
//  SettingViewController.swift
//  BubblePop
//
//  Created by Krishna Hingu on 1/5/19.
//  Copyright © 2019 Krishna Hingu. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var selectedBubbleLabel: UILabel!
    @IBOutlet weak var bubbleSelectionSlider: UISlider!
    @IBOutlet weak var minBubbleLabel: UILabel!
    @IBOutlet weak var maxBubbleLabel: UILabel!
    
    @IBOutlet weak var selectedGameTimeLabel: UILabel!
    @IBOutlet weak var gameTimeSelectionSlider: UISlider!
    @IBOutlet weak var minGameTimeLabel: UILabel!
    @IBOutlet weak var maxGameTimeLabel: UILabel!
    
    let dataStorage = DataStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize previous settings
        do {
            let gameSettings = try dataStorage.showGameSettings()
            gameTimeSelectionSlider.value = Float(setSliderValue(time: gameSettings.gameTime))
            bubbleSelectionSlider.value = Float(setSliderValue(limit: gameSettings.maxBubbles))
        } catch { // Default
            let gameSettings = GameSettings()
            gameTimeSelectionSlider.value = Float(setSliderValue(time: gameSettings.gameTime))
            bubbleSelectionSlider.value = Float(setSliderValue(limit: gameSettings.maxBubbles))
        }
        
        // Update the slider values
        gameTimeSliderChange(self)
        bubbleSliderChange(self)
    }
    
    // set time in slider value
    func setSliderValue(time: Int) -> Int {
        var value: Int = 0
        
        switch time {
        case 15:
            value = 0
        case 30:
            value = 1
        case 60:
            value = 2
        case 90:
            value = 3
        case 120:
            value = 4
        default:
            value = 2
        }
        return value
    }
    
    // set max bubble in slider value
    func setSliderValue(limit: Int) -> Int {
        var value: Int = 0
        
        switch limit {
        case 5:
            value = 0
        case 10:
            value = 1
        case 15:
            value = 2
        case 20:
            value = 3
        case 25:
            value = 4
        default:
            value = 2
        }
        return value
    }
    
    // convert to current time
    func setTimeValue(_ sliderValue: Int) -> Int {
        var time: Int = 0
        
        switch sliderValue {
        case 0:
            time = 15
        case 1:
            time = 30
        case 2:
            time = 60
        case 3:
            time = 90
        case 4:
            time = 120
        default:
            time = 60
        }
        return time
    }

    // Time formation
    func formateTime(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    @IBAction func onSubmitTapped(_ sender: UIButton) {
        // Save the game settings
        let settings = GameSettings(gameTime: setTimeValue(Int(gameTimeSelectionSlider.value)), maxBubbles: Int(selectedBubbleLabel.text!)!)
        do {
            try dataStorage.storeSettings(settings: settings)
        } catch {
            print(error)
        }
         self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func bubbleSliderChange(_ sender: Any) {
        let value: Int = Int(bubbleSelectionSlider.value)
        var limit: Int = 0
        
        switch value {
        case 0:
            limit = 5
        case 1:
            limit = 10
        case 2:
            limit = 15
        case 3:
            limit = 20
        case 4:
            limit = 25
        default:
            limit = 15
        }
        
        selectedBubbleLabel.text = String(limit)
    }
    
    @IBAction func gameTimeSliderChange(_ sender: Any) {
        let time: Int = setTimeValue(Int(gameTimeSelectionSlider.value))
        
        selectedGameTimeLabel.text = formateTime(time)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
