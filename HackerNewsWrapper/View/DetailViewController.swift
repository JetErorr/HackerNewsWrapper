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
    var newsViewModel: NewsViewModel!

    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDesc: UILabel!

    @IBAction func newsAuthor(_ sender: Any) {
        newsViewModel.openStory(newsModel.author, "author")
    }

    @IBAction func newsArticle(_ sender: Any) {
        if let model = newsModel {
            newsViewModel.openStory("\(model.newsID)", "article")
        } else { print("Error opening the linked url page") }
    }

    @IBAction func newsURL(_ sender: Any) {
        if let url = newsModel.url {
            newsViewModel.openStory(url)
        } else { print("Error opening the linked url page") }
    }

    @IBOutlet weak var newsAuthor: UIButton!
    @IBOutlet weak var newsArticle: UIButton!
    @IBOutlet weak var newsURL: UIButton!
    @IBOutlet weak var newsScore: UILabel!
    @IBOutlet weak var newsComments: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        newsTitle.text = newsModel.title
        newsDesc.text = newsModel.desc
        newsAuthor.setTitle(newsModel.author, for: .normal)
        newsArticle.setTitle(newsModel.article, for: .normal)
        newsURL.setTitle(newsModel.url, for: .normal)
        newsScore.text = "Points: \(newsModel.score)"
        newsComments.text = "Comments: \(newsModel.kids!.count)"
    }
}
