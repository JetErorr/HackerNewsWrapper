//
//  CreateModel.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 29/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

// ViewModel for the MVVM pattern
import Foundation
import UIKit

protocol NewsReporter: class {
    func receiveNews(_ newsModel: [NewsModel])
}

class NewsViewModel {

    weak var reporterDelegate: NewsReporter?

    var newsModel: [NewsModel] = []
    let newsService = NewsService()
    let saveService = SaveService()
    var newsIndices = [Int]()

    var await = true

    var startIdx = 0
    var endIdx = 10

    // Local use
    let category: String

    // Prop Inject
    init(cat: String) {
        category = cat
    }

    // Methods
    // 1. Fetch Index / refresh the 500 ids
    // 2. Fetch news models from the index / dependent on 1.
    // 3. Send the newsModel / with a delegate
    // 4. Send the newsModel / with a delegate / by a method call from the VC
    // 5. Update VC's local view model / notify

    func updateIndex() {

        startIdx = 0
        endIdx = 10
        newsModel.removeAll()

        let myGroup = DispatchGroup()

        newsService.refreshNewsList(category) { result in

            myGroup.enter()
            self.await = true

            switch result {

            case .failure(let err):
                print("ViewModel: \(err)")
                myGroup.leave()
            case .success(let indexArray):
                self.newsIndices = indexArray
                myGroup.leave()
            }

            myGroup.notify(queue: .main) {
                self.await = false
                self.fetchModel()
            }
        }
    }
    // 1. API call for news list, empties the modelArray beforehand

    func fetchModel() {

        if !await {

            if newsIndices.count < 10 {
                startIdx = 0
                endIdx = newsIndices.count
            }

            let myGroup = DispatchGroup()

//            print(startIdx, "->", endIdx-1)
            for newsID in startIdx..<endIdx {
                myGroup.enter()

                //Get Data from NewsService
                newsService.fetchNews(newsID: newsIndices[newsID]) { result in

                    switch result {
                    case .failure(let err):
                        print("ViewModel: \(err)")
                        myGroup.leave()
                    case .success(let newsItem):
                        // Set data into Model
                        if self.newsModel.count < self.newsIndices.count
                            && !self.saveService.checkSaved(newsID) {
                            self.newsModel.append(newsItem)//
                        }
                        myGroup.leave()
                    }
                }
            }

            myGroup.notify(queue: .main) {

                // Handle if the next iteration returns an indexOutOfBounds
                if self.startIdx + 10 > self.newsIndices.count {
                } else if self.endIdx + 10 < self.newsIndices.count {
                    self.startIdx += 10
                    self.endIdx += 10
                } else {
                    self.startIdx += 10
                    self.endIdx = self.newsIndices.count
                }
                self.sendModel(self.newsModel)
            }
        }
    }
    // 2. API call for a news item, collect a modelArray and send to VC

    func favouriteToggled(_ newsID: Int) {

        var changeIndex: Int = 0

        for index in newsModel.indices where newsModel[index].newsID == newsID {
            changeIndex = index
            break
        }

        if saveService.checkSaved(newsID) {
            saveService.removeFromSaved(newsID)
            newsModel[changeIndex].saved = ""
        } else {
            saveService.addToSaved(newsID)
            newsModel[changeIndex].saved = "Favourite ⭐️"
        }

        notifyVC(newsModel[changeIndex].newsID, newsModel[changeIndex])

        if category == "saved" {
            newsModel.remove(at: changeIndex)
            sendModel(self.newsModel)
        }

    }
    // 3. Toggle favourite state and update models

    func filterNews(_ isFiltering: Bool, _ searchString: String) {

        if isFiltering && searchString.count != 0 {

            let filteredModel = newsModel.filter {
                $0.title
                    //                    .replacingOccurrences(of: " ", with: "")
                    .lowercased()
                    .contains(searchString
                        //                        .replacingOccurrences(of: " ", with: "")
                        .lowercased()
                )
            }
            sendModel(filteredModel)
        } else {
            sendModel(newsModel)
        }
    }
    // 4. Send back the filtered newsModel

    func sendModel(_ newsModel: [NewsModel]) {
        self.reporterDelegate?.receiveNews(newsModel)
    }
    // 5. Send whole model

    func notifyVC(_ newsID: Int, _ newsItem: NewsModel) {
        let msg = NSNotification.Name.init("modelChanged")
        NotificationCenter.default.post(
            name: msg,
            object: nil,
            userInfo: ["newsID": newsID, "newsItem": newsItem]
        )
    }
    // 6. Send 1 item for UI change

    func openStory(_ target: String, _ mode: String = "") {

//        let newsURLString = "https://hacker-news.firebaseio.com/v0/item/\.json"
        //        let newsURLString = "https://hacker-news.firebaseio.com/v0/item/22200229.json"

//        guard let newsURL = URL(string: newsURLString) else {
//            print("ERROR: Invalid news URL")
//            return
//        }
        let url: URL

        switch mode {

        case "article":
            if let articleURL = URL(string: "https://news.ycombinator.com/item?id=\(target)") {
                url = articleURL
            } else { return }

        case "author":
            if let authorURL = URL(string: "https://news.ycombinator.com/user?id=\(target)") {
                url = authorURL
            } else { return }

        default:
            if let directURL = URL(string: target) {
                url = directURL
            } else { return }
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    // 7. Open the URL with the default browser
}
