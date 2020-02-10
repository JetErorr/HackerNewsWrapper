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

    var newsModel: [NewsModel] = []

    var isDataLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()

        newsTable.dataSource = self
        newsTable.delegate = self
        newsViewModel.reporterDelegate = self
        newsViewModel.fetchModel(0)
    }
}

// MARK: - Table extension
extension ViewController {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newsViewModel.favouriteToggled(indexPath.row)
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

        let newsItem = self.newsModel[indexPath.row]

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
        if distanceFromBottom < height {
            if !isDataLoading {
                // Loading new data
                isDataLoading = true
                newsViewModel.fetchModel()
            }
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
                print(newsModel[indexPath.row])
                controller.newsModel = newsModel[indexPath.row]
            }
        }
    }
}

extension ViewController: NewsReporter {
    func getNews(_ newsModel: [NewsModel]) {
        self.newsModel = newsModel
        newsTable.reloadData()
        isDataLoading = false
    }
}

//  Implement refresh function
//    override func viewDidAppear(_ animated: Bool) {
//
//    }
