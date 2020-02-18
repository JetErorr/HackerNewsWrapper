//
//  DetailViewController.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 04/02/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import Foundation
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate {

    var newsModel: NewsModel!
    var detailVM = DetailViewModel()
//    swiftlint:disable force_cast
    let webVC = UIStoryboard(name: "Main", bundle: nil)
        .instantiateViewController(withIdentifier: "WebVC") as! WebViewController
//    swiftlint:enable force_cast

    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDesc: UILabel!

    @IBAction func newsAuthor(_ sender: Any) {

        webVC.url = detailVM.openStory(newsModel.author, "author")
        showURL()
    }

    @IBAction func newsArticle(_ sender: Any) {
        if let model = newsModel {
            webVC.url = detailVM.openStory("\(model.newsID)", "article")
            showURL()
        }
    }

    @IBAction func newsURL(_ sender: Any) {
        if let url = newsModel.url {
            webVC.url = detailVM.openStory(url)
            showURL()
        }
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

    func showURL() {
        present(webVC, animated: true, completion: nil)
    }
}
