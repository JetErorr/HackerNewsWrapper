//
//  ViewController.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 31/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITabBarControllerDelegate {

    @IBOutlet weak var newsTable: UITableView! // view item
    @IBOutlet weak var searchView: UIView! // view item

    var refreshControl = UIRefreshControl() // view logic item
    var searchController: UISearchController! // view item

    var firstLoad = true // view state item
    var isDataLoading = false // view state item
    var isFiltering = false // view state item

    var newsViewModel: NewsViewModel! // data item
    var newsModel: [NewsModel] = [] // data item

    override func viewDidLoad() {
        super.viewDidLoad()

        #if DEV
        print("Development Version")
        print("The data for description text label has been disabled to check for row height consistency")
        #else
        print("Release Version")
        #endif

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
        newsTable.keyboardDismissMode = .onDrag
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
                controller.newsModel = newsModel[indexPath.row]
                controller.newsViewModel = newsViewModel
            }
        }
    }
}

// MARK: - Table methods
extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newsViewModel.favouriteToggled(newsModel[indexPath.row].newsID)
        #if DEV
        print("Favourite toggled")
        #endif
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsModel.count
    }

    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableView.automaticDimension
    //    }
    //
    //    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableView.automaticDimension
    //    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //        swiftlint:disable force_cast
        let cell: CustomCell = tableView.dequeueReusableCell(
            withIdentifier: "newsList", for: indexPath
            ) as! CustomCell
        //         swiftlint:enable force_cast

        let newsItem = newsModel[indexPath.row]

        cell.layoutIfNeeded()

        cell.newsTitle.text = newsItem.title

        cell.newsTime.text = String(newsItem.since)

        #if !DEV
        cell.newsDesc.text = newsItem.desc
        #endif

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

        newsTable.reloadData()
    }

    @objc func refresh() {
        #if DEV
        print("Refreshing")
        #endif
        if !searchController.isActive {
            isDataLoading = true
            newsModel.removeAll()
            newsTable.reloadData()
            newsViewModel.updateIndex()
        } else {
            refreshControl.endRefreshing()
        }
        #if DEV
        print("Done refreshing")
        #endif
    }
}

// MARK: - Reload when scrolled to bottom
extension ViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        #if DEV
        print("Scrolled to bottom")
        print("Loading 10 new entries")
        #endif
        if !searchController.isActive {
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom + 150 < height && !isDataLoading {
                isDataLoading = true
                newsViewModel.fetchModel()
            }
        }
        #if DEV
        print("Done loading")
        #endif
    }
}

// MARK: - Callback method to update local newsModel
extension ViewController: NewsReporter {
    func receiveNews(_ newsModel: [NewsModel]) {
        #if DEV
        print("Received updated news model")
        #endif
        self.newsModel = newsModel
        newsTable.reloadData()
        refreshControl.endRefreshing()
        isDataLoading = false
    }
}

// MARK: - Search bar delegates and methods
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        #if DEV
        print("Changed search string")
        #endif
        if let searchText = searchController.searchBar.text {
            #if DEV
            print(searchText)
            #endif
            newsViewModel.filterNews(true, searchText)
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        #if DEV
        print("Search clicked")
        #endif
        searchController.isActive = true

        if let searchText = searchBar.text {
            newsViewModel.filterNews(true, searchText)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        #if DEV
        print("Search Cancel clicked")
        #endif
        searchController.isActive = false
        newsViewModel.filterNews(false, "")
    }
}
