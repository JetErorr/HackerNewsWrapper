//
//  CreateModel.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 29/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

// ViewModel for the MVVM pattern
import Foundation

struct NewsViewModel {
    //swiftlint:enable all
    // Create Model, Get Data from FetchAndParse, Set Data into Model, Return Model

    // Get 10 news entries and return a [NewsModel]
    func fetchModel(completion: @escaping ([NewsModel]) -> Void) {
        var newsModel: [NewsModel] = []
        var newsIndices = [Int]()
        let myGroup = DispatchGroup()

        // Get indices for the news item
        NewsService().refreshNewsList { (indexArray) in
            newsIndices = indexArray

            for newsID in 0...9 {

                myGroup.enter()
                NewsService().fetchNews(newsID: newsIndices[newsID] ) { (newsItem) in
                    newsModel.append(newsItem)
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {
                completion(newsModel)
            }
        }
    }
}
