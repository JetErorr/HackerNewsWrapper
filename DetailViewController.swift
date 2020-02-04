//
//  DetailViewController.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 04/02/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {

    var newsModel: NewsModel!

    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDesc: UILabel!
    @IBOutlet weak var newsAuthor: UIButton!
    @IBOutlet weak var newsArticle: UIButton!
    @IBOutlet weak var newsURL: UIButton!
    @IBOutlet weak var newsScore: UILabel!
    @IBOutlet weak var newsComments: UILabel!

    override func viewDidLoad() {
        print("In here")
        newsTitle.text = newsModel.title
        newsDesc.text = newsModel.desc
        newsAuthor.setTitle(newsModel.author, for: .normal)
        newsArticle.setTitle(newsModel.article, for: .normal)
        newsURL.titleLabel?.text = newsModel.url
        newsScore.text = "\(newsModel.score)"
        newsComments.text = "\(newsModel.kids!.count)"
    }
}
