//
//  Score.swift
//  BubblePop
//
//  Created by Krishna Hingu on 5/5/19.
//  Copyright © 2019 Krishna Hingu. All rights reserved.
//

import Foundation
import UIKit

// Class for gained Scores label
class Score: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set default attributes
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 0
        self.font = UIFont.boldSystemFont(ofSize: 22)
        self.font = UIFont(name: "Noteworthy", size: 22)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
}
