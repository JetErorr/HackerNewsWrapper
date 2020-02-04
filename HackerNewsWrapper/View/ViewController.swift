//
//  ViewController.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 31/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import UIKit

class ViewController:
UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate {

    @IBOutlet weak var newsTable: UITableView!

    var newsViewModel: NewsViewModel!

    var isDataLoading = false
    var newsModel: [NewsModel] = []

    func loadNews() {
        isDataLoading = true
        newsViewModel.fetchModel { result in
            switch result {
            case .failure(let err):
                print("ViewController: \(err)")
            case .success(let newsModel):
                self.newsModel = newsModel
                self.isDataLoading = false
            }
            // Reloading UI on the main thread
            DispatchQueue.main.async {
                self.newsTable.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        newsTable.dataSource = self
        newsTable.delegate = self

        loadNews()
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

// Table extension
extension ViewController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //        swiftlint:disable force_cast
        let cell: CustomCell = tableView.dequeueReusableCell(
            withIdentifier: "newsList", for: indexPath
            ) as! CustomCell
        //         swiftlint:enable force_cast

        let newsItem = newsModel[indexPath.row]

        cell.newsTitle.text = newsItem.title
//        cell.newsAuthor.text = "By: \(newsItem.author)"
        if let time = newsItem.since {
            cell.newsTime.text = "\(time) Ago"
        }
        if let desc = newsItem.desc {
            cell.newsDesc.text = desc
        }
//        cell.newsScore.text = "\(newsItem.score) Points"
//        if let comments = newsItem.kids {
//            cell.newsComments.text = "\(comments.count) Comments"
//        }
        return cell
    }
}

// Scroll to the bottom to load more entries
extension ViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if !isDataLoading {
                print("Load new data")
                loadNews()
            }
        }
    }
}
