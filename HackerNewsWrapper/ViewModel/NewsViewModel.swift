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
    // 1. Create Model, 2.Get Data from NewsService, 3. Set Data into Model & 4.Return Model

    // Get 10 news entries and return a [NewsModel]
    func fetchModel(_ items: Int, _ category: String, completion: @escaping (Result<[NewsModel], Error>) -> Void) {

        let myGroup = DispatchGroup()
        let newsService = NewsService()

        // Create Model
        var newsIndices = [Int]()
        var newsModel: [NewsModel] = []

        // Get indices for the news item
        newsService.refreshNewsList(category) { result in
            switch result {
            case .failure(let err):
                print("ViewModel: \(err)")
                completion(.failure(err))
            case .success(let indexArray):
                // Set fetched index as local one
                newsIndices = indexArray
            }

            for newsID in 0..<items {
                myGroup.enter()

                //Get Data from NewsService
                newsService.fetchNews(newsID: newsIndices[newsID] ) { result in
                    switch result {
                    case .failure(let err):
                        print("ViewModel: \(err)")
                        myGroup.leave()
                        completion(.failure(err))
                    case .success(let newsItem):
                        // Set data into Model
                        newsModel.append(newsItem)
                        myGroup.leave()
                    }
                }
            }
            myGroup.notify(queue: .main) {
                // Return Model
                completion(.success(newsModel))
            }
        }
    }
}
