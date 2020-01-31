//
//  BestStoriesViewController.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 31/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import UIKit

class BestStoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var newsTable: UITableView!

    var newsModel: [NewsModel] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        swiftlint:disable force_cast
        let cell: CustomCell = tableView.dequeueReusableCell(
            withIdentifier: "newsList", for: indexPath
            ) as! CustomCell

        let newsItem = newsModel[indexPath.row]
        cell.newsTitle.text = newsItem.title
        cell.newsAuthor.text = "By: \(newsItem.author)"
        if let time = newsItem.since {
            cell.newsTime.text = "\(time) Ago"
        }
        cell.newsScore.text = "\(newsItem.score) Points"
        if let comments = newsItem.kids {
            cell.newsComments.text = "\(comments.count) Comments"
        }
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        newsTable.dataSource = self
        newsTable.delegate = self

        NewsViewModel().fetchModel("beststories") { (newsModel) in
            self.newsModel = newsModel

            // Reloading UI on the main thread
            DispatchQueue.main.async {
                self.newsTable.reloadData()
            }
        }
    }

    //  Implement onclick overview page
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    //    }

    //  Implement refresh function
    //    override func viewDidAppear(_ animated: Bool) {
    //
    //    }
}
