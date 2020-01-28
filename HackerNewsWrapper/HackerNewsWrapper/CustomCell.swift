//
//  CustomCell.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 27/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import Foundation
import UIKit

class CustomCell : UITableViewCell{
    
    @IBOutlet weak var newsTitle: UILabel!
    
    @IBOutlet weak var newsAuthor: UILabel!
    @IBOutlet weak var newsScore: UILabel!

    @IBOutlet weak var newsComments: UILabel!
    @IBOutlet weak var newsTime: UILabel!
}
