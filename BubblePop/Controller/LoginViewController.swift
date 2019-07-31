//
//  LoginViewController.swift
//  BubblePop
//
//  Created by Krishna Hingu on 1/5/19.
//  Copyright © 2019 Krishna Hingu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
   @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backgButtonClick(_ sender: Any) {
       self.navigationController?.popToRootViewController(animated: true)
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func startButtonClick(_ sender: UIButton) {
        // check and animate text field if it is empty
        if nameTextField.text!.isEmpty {
            let alert = UIAlertController(title: "Alert", message: "Please enter your name.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
        else {
            performSegue(withIdentifier: "GameViewSegue", sender: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameViewSegue" {
            let gameViewController = segue.destination as! GameViewController
            do {
                gameViewController.playerName = nameTextField.text
                gameViewController.gameSettings = try DataStorage().showGameSettings()
            } catch {
                gameViewController.gameSettings = GameSettings()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
