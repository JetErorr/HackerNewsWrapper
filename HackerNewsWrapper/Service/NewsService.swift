//
//  FetchAndParse.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 29/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

// Service for fetching and parsing JSON data
import Foundation
import UIKit

class NewsService {

    let decoder = JSONDecoder()
    let saveService = SaveService()

    // Get indices for new news items
    func refreshNewsList(_ category: String, completion: @escaping (Result<[Int], Error>) -> Void) {
//        print(category)

        if category == "saved" {
            let localID = saveService.getSavedIDs()
            print(localID.count, "Favourites")
//            if localID.count != 0 {
                completion(.success(localID))
//            }
        } else {

            // URL for getting top 500 news IDs
            // Add Configurable code for things like New, Best, Job Stories, Ask, Show, etc and other things
            let indexURLString = "https://hacker-news.firebaseio.com/v0/\(category).json"
            guard let indexURL = URL(string: indexURLString) else {
                print("ERROR: Invalid index URL")
                return
            }

            URLSession.shared.dataTask(with: indexURL) { data, _, err in
                if let err = err {

                    print("ERROR: Couldn't fetch index")
                    print("Service: \(err.localizedDescription)")

                    completion(.failure(err))

                } else if let data = data {

                    do {
                        let index = try self.decoder.decode([Int].self, from: data)
                        completion(.success(index))
                        //                    print(index) //debug

                    } catch {

                        print("ERROR: Couldn't load news index")
                        print(indexURLString)
                        print("Service: \(error.localizedDescription)")

                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }

    // Refactoring names
    func fetchNews(newsID: Int, completion: @escaping (Result<NewsModel, Error>) -> Void) {

        // Insert newsID index in the newsURL
        let newsURLString = "https://hacker-news.firebaseio.com/v0/item/\(newsID).json"
        //        let newsURLString = "https://hacker-news.firebaseio.com/v0/item/22200229.json"

        guard let newsURL = URL(string: newsURLString) else {
            print("ERROR: Invalid news URL")
            return
        }
        URLSession.shared.dataTask(with: newsURL) { data, _, err in
            if let err = err {
                print("ERROR: Couldn't fetch news item")
                print("Service: \(err.localizedDescription)")
                completion(.failure(err))
            }
            if let data = data {
                do {
                    let news = try self.decoder.decode(NewsModel.self, from: data)

                    let saveState: Bool
                    if self.saveService.checkSaved(newsID) {
                        saveState = true
                    } else {
                        saveState = false
                    }

                    // Returning a new object with values from the fetch
                    completion(.success(
                        NewsModel(news.title, news.desc, news.author, news.time, news.score,
                                  news.kids, newsID, news.url, newsURLString, saveState))
                    )
                } catch {
                    print(newsURL)
                    print("ERROR: Couldn't load news item")
                    print("Service: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
