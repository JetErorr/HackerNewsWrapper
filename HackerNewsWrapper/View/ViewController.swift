//
//  ViewController.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 27/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

// ViewController for MVVM pattern
import UIKit
import SwiftyJSON

class ViewController: UITableViewController {
    //swiftlint:enable all
    // Require Model, Set model values into cellForRowAt //
    // Change level of object access

    @IBOutlet var newsTable: UITableView!

    var newsModel: [NewsModel] = []

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return model.count
        return newsModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell: CustomCell = tableView.dequeueReusableCell(withIdentifier: "newsList", for: indexPath) as! CustomCell

        cell.newsTitle.text = newsModel[indexPath.row].title
        cell.newsAuthor.text = newsModel[indexPath.row].author
        cell.newsTime.text = newsModel[indexPath.row].time
        cell.newsScore.text = String(newsModel[indexPath.row].score)
        cell.newsComments.text = String(newsModel[indexPath.row].comments)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        // Use the default size for all other rows.
        //        return UITableView.automaticDimension
        return 120
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NewsViewModel().fetchModel { (newsModel) in

            self.newsModel = newsModel

            // Reloading UI on the main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    //  Implement onclick overview page
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    //    }

    // Implement refresh function
    //    override func viewDidAppear(_ animated: Bool) {
    //
    //    }

}
