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

    var refreshControl = UIRefreshControl() // view logic item
    var searchController: UISearchController! // view item

    var firstLoad = true // view state item
    var isDataLoading = false // view state item
    var isFiltering = false // view state item

    var newsViewModel: NewsViewModel! // data item
    var newsModel: [NewsModel] = [] // data item
    var displayModel: [NewsModel] = [] // data item

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchView.addSubview(searchController.searchBar)

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        newsTable.addSubview(refreshControl)

        newsTable.dataSource = self
        newsTable.delegate = self
        newsViewModel.reporterDelegate = self
        newsViewModel.fetchModel()

        // Delegate
        let name = NSNotification.Name.init("modelChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRows), name: name, object: nil)
        // Delaware
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if firstLoad {
            newsViewModel.updateIndex()
            firstLoad = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "detailSeg" {
            //swiftlint:disable force_cast
            // Downcasting
            let controller = segue.destination as! DetailViewController
            if let indexPath = newsTable.indexPath(for: sender as! UITableViewCell) {
                //swiftlint:enable force_cast
                controller.newsModel = displayModel[indexPath.row]
            }
        }
    }
}

// MARK: - Table methods
extension ViewController {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newsViewModel.favouriteToggled(indexPath)
        searchController.isActive = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if isFiltering { return filteredModel.count }
//        if searchController.isActive {
//            return filteredNews.count
//        } else {
            return displayModel.count
//        }
    }

    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableView.automaticDimension
    //    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        //        swiftlint:disable force_cast
        let cell: CustomCell = tableView.dequeueReusableCell(
            withIdentifier: "newsList", for: indexPath
            ) as! CustomCell
        //         swiftlint:enable force_cast

//        if searchController.isActive {
//            if emptyResult { return cell }
//            newsItem = filteredNews[indexPath.row]
//        } else {
        let newsItem = displayModel[indexPath.row]
//        }

        cell.layoutIfNeeded()

        cell.newsTitle.text = newsItem.title

        cell.newsTime.text = String(newsItem.since)

        //        cell.newsDesc.text = newsItem.desc

        cell.newsSaved.text = newsItem.saved

        return cell
    }
}

// MARK: - @obj-c methods
extension ViewController {
    @objc func reloadRows(notification: Notification) {

        guard let userInfo = notification.userInfo,
            let newsID = userInfo["newsID"] as? Int,
            let item = userInfo["newsItem"] as? NewsModel
            else {
                print("ERROR: No userInfo found in notification")
                return
        }

        for index in self.newsModel.indices where self.newsModel[index].newsID == newsID {
            self.newsModel[index] = item
        }

        displayModel = newsModel

        newsTable.reloadData()
    }

    @objc func refresh() {
        if !searchController.isActive {
            isDataLoading = true
            newsModel.removeAll()//
            newsTable.reloadData()
            newsViewModel.updateIndex()
        } else {
            refreshControl.endRefreshing()
        }
    }
}

// MARK: - Reload when scrolled to bottom
extension ViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if !searchController.isActive {
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom + 150 < height && !isDataLoading {
                isDataLoading = true
                newsViewModel.fetchModel()
            }
        }
    }
}

// MARK: - Callback method to update local newsModel
extension ViewController: NewsReporter {
    func receiveNews(_ newsModel: [NewsModel]) {
        self.newsModel = newsModel
        self.displayModel = newsModel
        newsTable.reloadData()
        refreshControl.endRefreshing()
        isDataLoading = false
    }
}

// MARK: - Search bar delegates and methods
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterNews(searchText)
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = true

        if let searchText = searchBar.text {
            filterNews(searchText)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
    }
}

extension ViewController {
    func filterNews(_ searchString: String) {

        displayModel = newsModel
        if searchString.count != 0 {

            // Get a fresh copy of the full data
            displayModel = newsModel

            let filteredModel = displayModel.filter {
                $0.title
                    //                    .replacingOccurrences(of: " ", with: "")
                    .lowercased()
                    .contains(searchString
                        //                        .replacingOccurrences(of: " ", with: "")
                        .lowercased()
                )
            }

            if filteredModel.count == 0 {
                displayModel.removeAll()
            } else {
                displayModel = filteredModel
            }

        } else {
            displayModel = newsModel
        }
        newsTable.reloadData()
    }
}
