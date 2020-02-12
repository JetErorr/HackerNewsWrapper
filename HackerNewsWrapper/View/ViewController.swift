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

    @IBOutlet weak var newsTable: UITableView! // view item

    var newsViewModel: NewsViewModel! // data item

    var refreshControl = UIRefreshControl() // view logic item

    var newsModel: [NewsModel] = [] // data item

    var isDataLoading = false // view logic item

    var firstLoad = false // view logic item

    override func viewDidLoad() {
        super.viewDidLoad()
//        print("Load")

        newsTable.dataSource = self
        newsTable.delegate = self
        newsViewModel.reporterDelegate = self
        newsViewModel.fetchModel()

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        newsTable.addSubview(refreshControl)

        let name = NSNotification.Name.init("favToggle")
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRows), name: name, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !firstLoad {
            newsViewModel.updateIndex()
            firstLoad = true
        }
    }
}

extension ViewController {

    @objc func refresh() {
        isDataLoading = true
        newsModel.removeAll()
        newsTable.reloadData()
        newsViewModel.updateIndex()
    }

    @objc func reloadRows(notification: Notification) {
//        print("notified")

        guard let userInfo = notification.userInfo,
            let newsID = userInfo["newsID"] as? Int,
            let item = userInfo["newsItem"] as? NewsModel
        else {
                print("No userInfo found in notification")
                return
        }

        for indices in self.newsModel.indices where self.newsModel[indices].newsID == newsID {
            self.newsModel[indices] = item
        }

        newsTable.reloadData()
    }
}

// MARK: - Table extension
extension ViewController {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newsViewModel.favouriteToggled(indexPath)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsModel.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //        swiftlint:disable force_cast
        let cell: CustomCell = tableView.dequeueReusableCell(
            withIdentifier: "newsList", for: indexPath
            ) as! CustomCell
        //         swiftlint:enable force_cast

        let newsItem = newsModel[indexPath.row]

        cell.newsTitle.text = newsItem.title

        cell.newsTime.text = String(newsItem.since)

        cell.newsDesc.text = newsItem.desc

        cell.newsSaved.text = newsItem.saved

        cell.layoutIfNeeded()

        return cell
    }
}

// MARK: - Reload when scrolled to bottom
extension ViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom + 150 < height && !isDataLoading {
            isDataLoading = true
            newsViewModel.fetchModel()
        }
    }
}

// MARK: - Segue to DetailVC // fixme
extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "detailSeg" {
            //swiftlint:disable force_cast
            // Downcasting
            let controller = segue.destination as! DetailViewController
            if let indexPath = newsTable.indexPath(for: sender as! UITableViewCell) {
                //swiftlint:enable force_cast
                controller.newsModel = newsModel[indexPath.row]
            }
        }
    }
}

extension ViewController: NewsReporter {
    func getNews(_ newsModel: [NewsModel]) {
        self.newsModel = newsModel
        newsTable.reloadData()
        refreshControl.endRefreshing()
        isDataLoading = false
    }
}
