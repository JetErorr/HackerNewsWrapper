//
//  FetchAndParse.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 29/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

// Service for fetching and parsing JSON data
import Foundation
import SwiftyJSON

class NewsService {
    //swiftlint:enable all
    
    // Get indices for new news items
    func refreshNewsList(completion: @escaping ([Int]) -> Void) {
        
        var indexArray: JSON = JSON()
        
        // URL for getting top 500 news IDs
        let indexUrl = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
        
        URLSession.shared.dataTask(with: indexUrl) { data, _, _ in
            if let data = data {
                do {
                    try indexArray = JSON(data: data)
                    
                    // Returning an array of indices // NEXT: Try to avoid force unwrapping / downcasting
                    completion(indexArray.arrayObject as! [Int])
                } catch {
                    print("Index Fetch err")
                }
            } else {
                print("Index Data Fetch err")
            }
        }.resume()
    }
    
    // Refactoring names
    func fetchNews(newsID: Int, completion: @escaping (NewsModel) -> Void) {
        
        // Insert newsID index in the newsURL
        let newsURLString = "https://hacker-news.firebaseio.com/v0/item/\(newsID).json"
        let newsURL = URL(string: newsURLString)!
        
        URLSession.shared.dataTask(with: newsURL) { data, _, _ in
            if let data = data {
                
                // Convert json data to presentable strings and integers
                do {
                    // Parse News JSON
                    let news = try JSON(data: data)

                    // Parse News Title
                    let title = news["title"].rawString()!
                    
                    // Parse News Author
                    let author = news["by"].rawString()!
                    
                    // Parse number of Comments
                    let comments = news["kids"].count
                    
                    // Parse Score number
                    let score = Int(news["score"].rawString()!)!
                    
                    // Calculating time gap from UNIX time given in json data
                    var secondsAgo = Int(Date().timeIntervalSince1970 - Double(news["time"].double!))
                    
                    // Formatting seconds into human readable time strings
                    var timeAgo = String()
                    if secondsAgo > 3600 {
                        secondsAgo /= 3600
                        timeAgo = "\(secondsAgo) hours/s ago"
                    } else if secondsAgo > 60 {
                        secondsAgo /= 60
                        timeAgo = "\(secondsAgo) minute/s ago"
                    } else if secondsAgo < 60 {
                        timeAgo = "\(secondsAgo) second/s ago"
                    }
                    
                    // Returning new NewsModel with data parsed from the News JSON
                    completion(NewsModel(title: title, author: author, time: timeAgo, score: score, comments: comments))
                } catch {
                    print("News Fetch err")
                }
            } else {
                print("News Data Fetch err")
            }
        }.resume()
    }
}
