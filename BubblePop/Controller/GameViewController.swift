//
//  GameViewController.swift
//  BubblePop
//
//  Created by Krishna Hingu on 1/5/19.
//  Copyright © 2019 Krishna Hingu. All rights reserved.
//

import UIKit
import GameKit // for random number generator

extension UILabel {
    //MARK: StartBlink
    func startBlink() {
        UIView.animate(withDuration: 0.8,//Time duration
            delay:0.0,
            options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
            animations: { self.alpha = 0 },
            completion: nil)
    }
    
    //MARK: StopBlink
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}


class GameViewController: UIViewController {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    @IBOutlet weak var bubbleView: UIView!
    
    var gameSettings: GameSettings?
    var playerName: String?
    
    var countdownTimer: Timer?
    var gameTimer: Timer?
    var bubbleTimer: Timer?
    
    var countdownLeft: Int = 3
    var remainningTime: Int = 60
    var maxBubbles: Int = 15
    let removalRate: Int = 3
    
    var oldSpeedTime: Int = 0
    var originalTime: Int = 0
    var floatSpeed: CGFloat = 1.0
    var score: Int = 0
    var highScore: Int = 0
    
    var bubbles: [BubbleType] = []
    var oldBubble: BubbleType?
    var isDoubleScore: Bool = false
    
    // Custom UIColors
    let pink: UIColor = UIColor(red: 249/255.0, green: 174/255.0, blue: 200/255.0, alpha: 1)
    let customBlue: UIColor = UIColor(red: 113/255.0, green: 181/255.0, blue: 246/255.0, alpha: 1)
    
    let gkRandomSource: GKRandomSource = GKARC4RandomSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // game settings
        if let settings = gameSettings {
            remainningTime = settings.gameTime
            maxBubbles = settings.maxBubbles
        }
        
        // Store bubbles
        bubbles.append(BubbleType(color: .red, scores: 1))
        bubbles.append(BubbleType(color: pink, scores: 2))
        bubbles.append(BubbleType(color: .green, scores: 5))
        bubbles.append(BubbleType(color: customBlue, scores: 8))
        bubbles.append(BubbleType(color: .black, scores: 10))
        
        timeLeftLabel.text = timeFormation(remainningTime)
        showHighScore()
    }
    
    // change coutdown
    @objc func changeCountdown() {
        countdownLeft -= 1
        
        // Countdown, change, and remove it after finish it
        if countdownLeft <= 0 {
            countdownTimer?.invalidate()
            countdownTimer = nil
            
            countLabel.isHidden = true
        }
        else {
            countLabel.text = String(countdownLeft)
            countLabel.startBlink()
        }
    }
    
    // Update High Score
    func updateHighScore() {
        if score > highScore {
            highScore = score
            highScoreLabel.text = String(highScore)
        }
    }
    
    // Show high score from data storage
    func showHighScore() {
        do {
            var scoreboard = try DataStorage().showScoreboard()
            scoreboard.sort(by: { $0.score > $1.score })
            highScore = scoreboard[0].score
            highScoreLabel.text = String(highScore)
        } catch {
            // Set default value
            highScore = 0
        }
    }
    
    //change game timer
    @objc func changeGameTime() {
        guard countdownLeft <= 0 else { return } // for if time finished
        // finish it when time finish, redirected to score view.
        if remainningTime <= 0 {
            gameTimer?.invalidate()
            gameTimer = nil
            
            bubbleTimer?.invalidate()
            bubbleTimer = nil
            self.performSegue(withIdentifier: "ScoreViewSegue", sender: self)
        }
        else {
            let newSpeedTime = self.oldSpeedTime - (self.originalTime / 6)
            
            // Increase speed every certain time:
            // [originalTime : changeSpeedTime/interval]
            // [15s:2s, 30s:5s, 60s:10s, 90s:15s, 120s:20s]
            if remainningTime == oldSpeedTime {
                self.oldSpeedTime = newSpeedTime
                self.floatSpeed += 0.05
            }
            
            remainningTime -= 1
            
            if remainningTime <= 10 {
                alertTimeUp()
            }
            timeLeftLabel.text = timeFormation(remainningTime)
            
            addBubbles()
            deleteRandomBubbles()
        }
    }
    
    // For Bubble's image
    func setBubbleImage(of currBubble: Bubble) {
        if let color = currBubble.bubbleType?.color {
            switch color {
            case UIColor.red:
                currBubble.image = UIImage(named: "bubble-red.png")
            case pink:
                currBubble.image = UIImage(named: "bubble-pink.png")
            case UIColor.green:
                currBubble.image = UIImage(named: "bubble-green.png")
            case customBlue:
                currBubble.image = UIImage(named: "bubble-blue.png")
            case UIColor.black:
                currBubble.image = UIImage(named: "bubble-black.png")
            default:
                break
            }
        }
    }
    
    // For Bubble's Possibility
    func setBubblePossibility() -> BubbleType {
        var bag: [BubbleType] = []
        for _ in 1...40 {
            bag.append(bubbles[0])
        }
        for _ in 1...30 {
            bag.append(bubbles[1])
        }
        for _ in 1...15 {
            bag.append(bubbles[2])
        }
        for _ in 1...10 {
            bag.append(bubbles[3])
        }
        for _ in 1...5 {
            bag.append(bubbles[4])
        }
        
        let choice: Int = gkRandomSource.nextInt(upperBound: bag.count)
        return bag[choice]
    }
    
    //checkl location for ovoiding overlapping
    func checkLocation(of newBubble: Bubble) -> Bool {
        for subview in self.bubbleView.subviews {
            if let isBubble = subview as? Bubble {
                if isBubble.frame.intersects(newBubble.frame) {
                    return false
                }
            }
        }
        return true
    }
    
    // set Unique tag
    func setUniqueTag() -> Int {
        // Loop until a valid tag is available between range 1 to 50
        while true {
            let uniqueTag = gkRandomSource.nextInt(upperBound: 50) + 1
            guard let _ = self.bubbleView.viewWithTag(uniqueTag) else {
                return uniqueTag
            }
        }
    }
    
    // Form Bubble Randomly
    @objc func formBubble() {
        // Set random position within the view frame
        let randomX = CGFloat(gkRandomSource.nextUniform()) * (self.bubbleView.frame.width-100)
        let randomY = CGFloat(gkRandomSource.nextUniform()) * (self.bubbleView.frame.height-100)
        
        let currentBubble = Bubble(frame: CGRect(x: randomX, y: randomY, width: 80, height: 80))
        currentBubble.bubbleType = setBubblePossibility()
        setBubbleImage(of: currentBubble)
        
        let isAvailableLocation = checkLocation(of: currentBubble)
        if isAvailableLocation {
            currentBubble.tag = setUniqueTag();
            
            self.bubbleView.addSubview(currentBubble)
            self.bubbleView.sendSubviewToBack(currentBubble)
            
            // animate growing bubble
            currentBubble.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animate(withDuration: 0.1, animations: {
                currentBubble.transform = CGAffineTransform.identity
            })
        }
    }
    
    // Add bubble as per the settings
    func addBubbles() {
        if bubbleNumbers() < maxBubbles {
            let minBubbles = gkRandomSource.nextInt(upperBound: (maxBubbles - bubbleNumbers()))
            for _ in 0...minBubbles {
                formBubble()
            }
        }
    }
    
    // Delete randomly bubbles
    func deleteRandomBubbles() {
        guard remainningTime % removalRate == 0 else { return }
        
        var deletedBubbleCount = gkRandomSource.nextInt(upperBound: bubbleNumbers())
        for subview in self.bubbleView.subviews {
            if subview.tag > 0 {
                if deletedBubbleCount > 0 {
                    deleteBubble(subview as! Bubble)
                    deletedBubbleCount -= 1
                }
                else {
                    break
                }
            }
        }
    }
    
    // Delete Bubble
    func deleteBubble(_ bubble: Bubble) {
        if let availableBubble = self.bubbleView.viewWithTag(bubble.tag) {
            
            // Animate fading bubble
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn,
                           animations: {
                            availableBubble.alpha = 0.02
            }) { (_) in
                availableBubble.removeFromSuperview()
            }
        }
    }
    
    // delete all bubbles
    func deleteAllBubbles() {
        for subview in self.bubbleView.subviews {
            if subview is Bubble {
                subview.removeFromSuperview()
            }
        }
    }
    
    // Total Number of Bubbles
    func bubbleNumbers() -> Int {
        var count: Int = 0
        for subview in self.bubbleView.subviews {
            if subview is Bubble {
                count += 1
            }
        }
        return count
    }
    
    // Animation of Bubbles
    @objc func updateBubbleView() {
      
        guard countdownLeft <= 0 else { return } // For time finish
        
        for subview in self.bubbleView.subviews {
            if subview is Bubble {
                // Float bubble up
                subview.center.y -= self.floatSpeed
                
                // Remove bubble when it floats outside the view
                if subview.frame.maxY < 0 {
                    subview.removeFromSuperview()
                }
            }
        }
    }
   
    // Score Calculation
    // For same bubble popped score 1.5 X Original Score of Bubble
    func achievedScores(from currentBubble: BubbleType) -> Int {
        if oldBubble?.color == currentBubble.color {
            let scores = 1.5 * Double(currentBubble.scores)
            isDoubleScore = true
            return Int(round(scores))
        }
        else {
            oldBubble = currentBubble
            isDoubleScore = false
            return currentBubble.scores
        }
    }
    
    // Show the indivisual scores, at the time when achieved
    func showScoreView(for currentBubble: Bubble, achievedScore: Int) {
        let scoreView = Score(frame: CGRect(x: currentBubble.frame.minX, y: currentBubble.frame.minY, width: 150, height: 150))
        
        scoreView.textColor = currentBubble.bubbleType?.color
        
        if isDoubleScore {
            scoreView.text = "1.5 X COMBO! \n +\(achievedScore)"
            scoreView.font = scoreView.font.withSize(16)
            scoreView.adjustsFontSizeToFitWidth = true
            scoreView.sizeToFit()
        }
        else {
            scoreView.text = "+\(achievedScore)"
        }
        self.bubbleView.addSubview(scoreView)
        
        // Points Animation towards up
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlUp, animations: {
            scoreView.center.y -= 50
            scoreView.alpha = 0.02
        }) { (_) in
            scoreView.removeFromSuperview()
        }
    }
    
    // Touch event for popped bubble
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchArea = touch?.location(in: self.bubbleView)
        
        for subview in self.bubbleView.subviews {
            if let touchedBubble = subview as? Bubble {
                if (touchedBubble.layer.presentation()?.hitTest(touchArea!)) != nil {
                    
                    // Calculate and show points
                    let points = achievedScores(from: touchedBubble.bubbleType!)
                    showScoreView(for: touchedBubble, achievedScore: points)
                    
                    self.score += points
                    scoreLabel.text = String(self.score)
                    
                    showHighScore()
                    
                    // Animate shrinking bubble
                    UIView.animate(withDuration: 0.1, animations: {
                        touchedBubble.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
                    }) { (_) in
                        touchedBubble.removeFromSuperview()
                    }
                    
                }
            }
            
        }
    }
    
    // Time Text Formatting
    func timeFormation(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    // Alert for Times Up!!
    func alertTimeUp() {
        timeLeftLabel.textColor = .red
        timeLeftLabel.font = UIFont.boldSystemFont(ofSize: timeLeftLabel.font.pointSize)
        timeLeftLabel.startBlink()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Keep the original time and set the time of when to increase speed
        
        countLabel.startBlink()
        originalTime = remainningTime
        oldSpeedTime = originalTime

        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeCountdown), userInfo: nil, repeats: true)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeGameTime), userInfo: nil, repeats: true)
        
        bubbleTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateBubbleView), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deleteAllBubbles()   // Delete all bubble
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        timeLeftLabel.stopBlink()
        if segue.identifier == "ScoreViewSegue" {
            let scoreViewController = segue.destination as! ScoreViewController
            scoreViewController.playerName = self.playerName
            scoreViewController.finalScore = self.score
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
