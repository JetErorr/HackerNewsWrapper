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
//    let saveService = SaveService()

    //    var detailViewController: DetailViewController!

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

    // ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        newsTable.dataSource = self
        newsTable.delegate = self

        loadNews()
    }

    //  Implement refresh function
    //    override func viewDidAppear(_ animated: Bool) {
    //
    //    }
}

// MARK: - Table extension
extension ViewController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsModel.count
    }

//    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        var newsItem = self.newsModel[indexPath.row]
//
//        if saveService.checkSaved(newsItem.newsID) {
//            saveService.removeFromSaved(newsItem.newsID)
//            newsItem.saved = false
//
//        } else {
//            saveService.addToSaved(newsItem.newsID)
//            newsItem.saved = true
//        }
//        tableView.reloadData()
//        tableView.reloadRows(at: [indexPath], with: .none)
//    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //swiftlint:disable force_cast
        let cell: CustomCell = tableView.dequeueReusableCell(
            withIdentifier: "newsList", for: indexPath
            ) as! CustomCell

        var newsItem = self.newsModel[indexPath.row]

        if saveService.checkSaved(newsItem.newsID) {
            saveService.removeFromSaved(newsItem.newsID)
            newsItem.saved = false
            cell.newsSaved.alpha = 0

        } else {
            saveService.addToSaved(newsItem.newsID)
            newsItem.saved = true
            cell.newsSaved.alpha = 1
        }

        tableView.reloadRows(at: [indexPath], with: .none)

        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //        swiftlint:disable force_cast
        let cell: CustomCell = tableView.dequeueReusableCell(
            withIdentifier: "newsList", for: indexPath
            ) as! CustomCell
        //         swiftlint:enable force_cast

        let newsItem = self.newsModel[indexPath.row]

        cell.newsTitle.text = newsItem.title

        cell.newsTime.text = String(newsItem.since)

        cell.newsDesc.text = newsItem.desc

        if newsItem.saved {
            cell.newsSaved.alpha = 1
        } else {
            cell.newsSaved.alpha = 0
        }
        return cell
    }
}

// MARK: - Reload when scrolled to bottom
extension ViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if !isDataLoading {
                // Loading new data
                loadNews()
            }
        }
    }
}

// MARK: - Segue to DetailVC
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
