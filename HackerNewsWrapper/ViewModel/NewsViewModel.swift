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

    let newsService = NewsService()
    let saveService = SaveService()
    var newsIndices = [Int]()

    var await = true

    var startIdx = 0
    var endIdx = 10

    weak var reporterDelegate: NewsReporter?

    // Local use
    let category: String

    // Prop Inject
    init(cat: String) {
        let myGroup = DispatchGroup()
        category = cat
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
                print(self.category, "fetch Complete")
                self.await = false
                self.fetchModel()
            }
        }
    }

    var newsModel: [NewsModel] = []

    func fetchModel() {

        if !await {
//            && startIdx < newsIndices.count {

            if newsIndices.count < 10 {
                startIdx = 0
                endIdx = newsIndices.count
            }

//            if endIdx < newsModel.count {
//                return
//            }

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
                        if self.newsModel.count == self.newsIndices.count { break }
                        self.newsModel.append(newsItem)
                        myGroup.leave()
                    }
                }
            }
            myGroup.notify(queue: .main) {

                // Return Model
                if self.endIdx+10 < self.newsIndices.count {
                    self.startIdx += 10
                    self.endIdx += 10
                    //                    self.reporterDelegate?.getNews(self.newsModel)
                } else {
                    self.startIdx += 10
                    self.endIdx = self.newsIndices.count
                }
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
