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

    @IBOutlet weak var searchView: UIView! // view item

//    var searchController: UISearchController!

//    var filteredNews: [NewsModel] = []

    var newsViewModel: NewsViewModel! // data item

//    var refreshControl = UIRefreshControl() // view logic item

    var newsModel: [NewsModel] = [] // data item

    var isDataLoading = false // view logic item

//    var emptyResult = false

    var firstLoad = false // view logic item

    override func viewDidLoad() {
        super.viewDidLoad()
//        print("Load")

        newsTable.dataSource = self
        newsTable.delegate = self
        newsViewModel.reporterDelegate = self
//        print("Onload")
        newsViewModel.fetchModel()

//        searchController = UISearchController(searchResultsController: nil)
//        searchController.searchResultsUpdater = self
//        searchController.searchBar.delegate = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchView.addSubview(searchController.searchBar)

//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
//        newsTable.addSubview(refreshControl)

        let name = NSNotification.Name.init("favToggle")
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRows), name: name, object: nil)

//        filteredNews = newsModel
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        print("Appear")
        if !firstLoad {
            newsViewModel.updateIndex()
            firstLoad = true
        }
    }
}

extension ViewController {

//    @objc func refresh() {
//        if !searchController.isActive {
//            isDataLoading = true
//            newsModel.removeAll()
//            newsTable.reloadData()
//            newsViewModel.updateIndex()
//        } else {
//            refreshControl.endRefreshing()
//        }
//    }

    @objc func reloadRows(notification: Notification) {
//        print("notified")

        guard let userInfo = notification.userInfo,
            let newsID = userInfo["newsID"] as? Int,
            let item = userInfo["newsItem"] as? NewsModel
        else {
                print("No userInfo found in notification")
                return
        }

        for index in self.newsModel.indices where self.newsModel[index].newsID == newsID {
            self.newsModel[index] = item
            getNews(newsModel)
//            newsTable.reloadRows(at: [indexPath], with: .none)
        }
        newsTable.reloadData()
    }
}

// MARK: - Filter extension
//extension ViewController {
//    func filterNews(_ searchString: String) {
//
//        if searchString.count > 0 {
//
//            filteredNews = newsModel
//
//            let filtered = filteredNews.filter {
//$0.title.replacingOccurrences(of: " ", with: "").lowercased().contai
//ns(searchString.replacingOccurrences(of: " ", with: "").lowercased())
//            }
//
//            if filtered.count == 0 {
//                filteredNews.removeAll()
//                emptyResult = true
//            } else {
//                filteredNews = filtered
//            }
//
//            newsTable.reloadData()
//        }
//
//        filteredNews = newsModel
//    }
//}

// MARK: - Table extension
extension ViewController {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newsViewModel.favouriteToggled(indexPath)
//        searchController.isActive = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isFiltering { return filteredNews.count }
//        if searchController.isActive {
//            return filteredNews.count
//        } else {
            return newsModel.count
//        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
        //        swiftlint:disable force_cast
        let cell: CustomCell = tableView.dequeueReusableCell(
            withIdentifier: "newsList", for: indexPath
            ) as! CustomCell
        //         swiftlint:enable force_cast

//        var newsItem: NewsModel

//        if searchController.isActive {
//            if emptyResult { return cell }
//            newsItem = filteredNews[indexPath.row]
//        } else {
        let newsItem = self.newsModel[indexPath.row]
//        }

        cell.newsTitle.text = newsItem.title

        cell.newsTime.text = String(newsItem.since)

        cell.newsDesc.text = newsItem.desc

        cell.newsSaved.text = newsItem.saved

        cell.layoutIfNeeded()

        return cell
    }
}

// MARK: - Reload when scrolled to bottom
//extension ViewController {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if !searchController.isActive {
//            let height = scrollView.frame.size.height
//            let contentYoffset = scrollView.contentOffset.y
//            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
//            if distanceFromBottom + 150 < height && !isDataLoading {
//                isDataLoading = true
//                newsViewModel.fetchModel()
//            }
//        }
//    }
//}

// MARK: - Segue to DetailVC // fixme // merge with main extension
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
//        self.filteredNews = newsModel
        newsTable.reloadData()
//        refreshControl.endRefreshing()
        isDataLoading = false
    }
}

//extension ViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        if let searchText = searchController.searchBar.text {
//            filterNews(searchText)
//        }
//    }
//}

//extension ViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchController.isActive = false
//
//        if let searchText = searchBar.text {
//            filterNews(searchText)
//        }
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchController.isActive = false
//
//        if let searchText = searchBar.text, !searchText.isEmpty {
//            filteredNews = newsModel
//        }
//    }
//}
