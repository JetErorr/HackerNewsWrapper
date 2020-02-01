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

    var newsModel: [NewsModel] = []
    var newsViewModel = NewsViewModel()

    var items = 10
    var categoryID = "topstories"

    @IBOutlet weak var newsTable: UITableView!
    @IBOutlet weak var loadMoreButton: UIButton!

    @IBAction func loadMore(_ sender: Any) {
        items += 10
        loadNews(items)
    }

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

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        switch tabBarIndex {
        case 1:
            categoryID = "newstories"
        case 2:
            categoryID = "beststories"
        default:
            categoryID = "topstories"
        }
    }

    func loadNews(_ items: Int) {

        loadMoreButton.setTitle("Loading...", for: .normal)
        loadMoreButton.alpha = 0.3

        newsViewModel.fetchModel(items, categoryID) { result in
            switch result {
            case .failure(let err):
                print("ViewController: \(err)")
            case .success(let newsModel):
                self.newsModel = newsModel
            }
            // Reloading UI on the main thread
            DispatchQueue.main.async {
                self.loadMoreButton.setTitle("Load More", for: .normal)
                self.loadMoreButton.alpha = 1
                self.newsTable.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.delegate = self
        newsTable.dataSource = self
        newsTable.delegate = self

        loadNews(items)
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
