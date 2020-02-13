//
//  CreateModel.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 29/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

// ViewModel for the MVVM pattern
import Foundation

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
    // 3. ToggleFav / toggle the favs for the given newsID
    // 4. Send the newsModel / with a delegate
    // 5. Send the newsModel / with a delegate / by a method call from the VC
    // 6. Update VC's local view model / notify

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
                print("Fetch complete")
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

            print(startIdx, "->", endIdx-1)
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
                        if self.newsModel.count < self.newsIndices.count {
                            self.newsModel.append(newsItem)//
                        }
                        myGroup.leave()
                    }
                }
            }

            myGroup.notify(queue: .main) {

                // Handle if the next iteration returns an indexOutOfBounds
                if self.endIdx + 10 < self.newsIndices.count {
                    self.startIdx += 10
                    self.endIdx += 10
                } else {
                    //                    self.startIdx += 10//
                    self.endIdx = self.newsIndices.count
                }
                print("Call to send model")
                self.sendModel()
            }
        }
    }
    // 2. API call for a news item, collect a modelArray and send to VC

    func toggleFavourite(_ index: IndexPath) {
        print("Toggling fav")
        let newsID = newsModel[index.row].newsID

        if saveService.checkSaved(newsID) {
            saveService.removeFromSaved(newsID)
            newsModel[index.row].saved = ""
        } else {
            saveService.addToSaved(newsID)
            newsModel[index.row].saved = "Favourite ⭐️"
        }
    }
    // 3. Toggle favourite state in model and core data

    func favouriteToggled(_ index: IndexPath) {
        print("Fav was toggled")

        toggleFavourite(index)

//        sendModel() // Change base data model
        notifyVC(newsModel[index.row].newsID, newsModel[index.row]) // Change local data model
    }
    // 4. Toggle favourite state and update models

    func sendModel() {
        print("Sending model")
        self.reporterDelegate?.receiveNews(self.newsModel)
    }
    // 5. Send whole model

    func notifyVC(_ newsID: Int, _ newsItem: NewsModel) {
        print("Notifying VC")
        let msg = NSNotification.Name.init("modelChanged")
               NotificationCenter.default.post(
                   name: msg,
                   object: nil,
                   userInfo: ["newsID": newsID, "newsItem": newsItem]
               )
    }
    // 6. Send 1 item
}
