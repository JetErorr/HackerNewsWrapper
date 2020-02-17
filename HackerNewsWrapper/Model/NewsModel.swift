//
//  NewsModel.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 27/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

// Model for the MVVM pattern
import Foundation

let dateFormatter = DateFormatter()

struct NewsModel: Codable {

    let title: String
    let desc: String?
    let author: String
    let time: Double
    let score: Int
    let kids: [Int]?
    let url: String?

    var saved: String = String()
    var newsID: Int = Int()
    var article: String? = String()
    var since: String = String()

    enum CodingKeys: String, CodingKey {
        case title
        case desc = "text"
        case author = "by"
        case time
        case score
        case kids
        case url
    }

    init(_ title: String, _ desc: String?, _ author: String, _ time: Double, _ score: Int,
         _ kids: [Int]?, _ newsID: Int, _ url: String?, _ article: String, _ saveState: Bool) {

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        self.title = title

        if let desc = desc {
            self.desc = desc
        } else { self.desc = "No description provided" }

        self.author = author

        self.time = time

        self.score = score

        if let kids = kids {
            self.kids = kids
        } else { self.kids = [] }

        if let url = url {
            self.url = url
        } else { self.url = "No URL provided" }

        self.newsID = newsID

        self.article = article

        if saveState {
            self.saved = "Favourite ⭐️"
        } else {
            self.saved = ""
        }

        self.since = dateFormatter.string(from: Date(timeIntervalSince1970: time))
    }

    // MARK: - Make new initializer to create model from 
}
