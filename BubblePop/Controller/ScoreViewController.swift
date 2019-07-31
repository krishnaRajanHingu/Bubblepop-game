//
//  ScoreViewController.swift
//  BubblePop
//
//  Created by Krishna Hingu on 5/5/19.
//  Copyright © 2019 Krishna Hingu. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var finalScoreLabel: UILabel!
    @IBOutlet weak var scoreTable: UITableView!
    
    var playerName: String?
    var finalScore: Int!
    
    let dataStorage: DataStorage = DataStorage()
    var scoreboard: [ScoreBoard] = []
    let maxRows: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Ranking Data
        do {
            scoreboard = try dataStorage.showScoreboard()
        } catch {
            nameLabel.text = "No Available High Scores"
        }
        
        scoreSorting()
        
        scoreTable.dataSource = self
        scoreTable.delegate = self
        
        // if player finished game, show name and score
        if let name = playerName {
            nameLabel.text = name
            finalScoreLabel.text = "\(finalScore!)"
            
            let newScore = ScoreBoard(name: name, score: finalScore)
            
            // Add the new entry, sort and reload the scoreboard table view
            scoreboard.append(newScore)
            scoreSorting()
            scoreTable.reloadData()
            
            // Save Rankings
            do {
                try dataStorage.storeScores(scores: scoreboard)
            } catch {
                print("Error while storing scores")
            }
            
        }
        else {
            nameLabel.text = ""
            finalScoreLabel.text = ""
        }
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
         self.navigationController?.popToRootViewController(animated: true)
    }

    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(scoreboard.count, maxRows)
    }
    
    // Row cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NameScoreCell", for: indexPath)
        let tableRow = indexPath.row
        
        // Get and display the labels the row cells
        let nameCell: UILabel = cell.viewWithTag(1) as! UILabel
        let scoreCell: UILabel = cell.viewWithTag(2) as! UILabel
        
        nameCell.text = "\(tableRow + 1).  \(scoreboard[tableRow].name)"
        scoreCell.text = ":  \(scoreboard[indexPath.row].score)"
        
        nameCell.font = UIFont.boldSystemFont(ofSize: 20.0)
        nameCell.font = UIFont(name: "Noteworthy", size: 20.0)
        scoreCell.font = UIFont(name: "Noteworthy", size: 20.0)
        
        // Alternate cell background color
        if tableRow % 2 == 0 {
            cell.backgroundColor = UIColor.lightGray
        }
        else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    // Table Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Top 5 Players"
    }
    
    // score sorting
    func scoreSorting() {
        scoreboard.sort(by: { $0.score > $1.score })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
