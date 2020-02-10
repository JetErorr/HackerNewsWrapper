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
    func getNews(_ newsModel: [NewsModel])
}

class NewsViewModel {

    let saveService = SaveService()

    var items: Int = 0 // todo remove assignment

    weak var reporterDelegate: NewsReporter?
    // Local use
    let category: String

    // Prop Inject
    init(cat: String) {
        category = cat
    }
    // Prop Inject

    var newsModel: [NewsModel] = []

    func fetchModel() {

        if items < 499 {
            items += 10
        }
        // todo remove values, replace with limits

        let myGroup = DispatchGroup()
        let newsService = NewsService()

        // Create Model
        var newsIndices = [Int]()

        // Get indices for the news item
        newsService.refreshNewsList(category) { result in
            switch result {
            case .failure(let err):
                print("ViewModel: \(err)")
            case .success(let indexArray):
                // Set fetched index as local one
                newsIndices = indexArray
            }

            if self.category == "saved" { self.items = newsIndices.count }
            // todo: remove jugad

            for newsID in 0..<self.items {
                myGroup.enter()

                //Get Data from NewsService
                newsService.fetchNews(newsID: newsIndices[newsID] ) { result in
                    switch result {
                    case .failure(let err):
                        print("ViewModel: \(err)")
                        myGroup.leave()
                    case .success(let newsItem):
                        // Set data into Model
                        self.newsModel.append(newsItem)
                        myGroup.leave()
                    }
                }
            }
            myGroup.notify(queue: .main) {
                // Return Model
                self.reporterDelegate?.getNews(self.newsModel)
            }
        }
    }

    func favouriteToggled(_ index: Int) {
        let newsID = self.newsModel[index].newsID

        if saveService.checkSaved(newsID) {
            saveService.removeFromSaved(newsID)
            self.newsModel[index].saved = ""
        } else {
            saveService.addToSaved(newsID)
            self.newsModel[index].saved = "Favourite ⭐️"
        }
        self.reporterDelegate?.getNews(self.newsModel)
    }
}
