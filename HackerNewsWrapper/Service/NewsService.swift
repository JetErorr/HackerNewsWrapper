//
//  FetchAndParse.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 29/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

// Service for fetching and parsing JSON data
import Foundation

class NewsService {

    let decoder = JSONDecoder()

    // Get indices for new news items
    func refreshNewsList(_ category: String, completion: @escaping (Result<[Int], Error>) -> Void) {

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

                } catch {

                    print("ERROR: Couldn't load news index")
                    print(indexURLString)
                    print("Service: \(error.localizedDescription)")

                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // Refactoring names
    func fetchNews(newsID: Int, completion: @escaping (Result<NewsModel, Error>) -> Void) {

        // Insert newsID index in the newsURL
        let newsURLString = "https://hacker-news.firebaseio.com/v0/item/\(newsID).json"
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

                    // Formatting seconds into human readable time strings
                    let since = Date().offsetFrom(date: Date(timeIntervalSince1970: news.time))

                    // Returning a new object with values from the fetch
                    completion(.success(
                        NewsModel(news.title, news.author, news.time,
                                  news.score, news.kids ?? [], news.url ?? "", since))
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

extension Date {

    func offsetFrom(date: Date) -> String {

        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self)

        let seconds = "\(difference.second ?? 0)s"
        let minutes = "\(difference.minute ?? 0)m" + " " + seconds
        let hours = "\(difference.hour ?? 0)h" + " " + minutes
        let days = "\(difference.day ?? 0)d" + " " + hours

        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
}
