//
//  NewsModel.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 27/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

// Model for the MVVM pattern
import Foundation

struct NewsModel: Codable {
    let title: String
    let desc: String?
    let author: String
    let time: Double
    let score: Int
    let kids: [Int]?
    let url: String?
    var since: String? = String()

    enum CodingKeys: String, CodingKey {
        case title
        case desc = "text"
        case author = "by"
        case time
        case score
        case kids
        case url
    }

    init(_ title: String, _ desc: String, _ author: String, _ time: Double,
         _ score: Int, _ kids: [Int], _ url: String, _ since: String) {
        self.title = title
        self.desc = desc
        self.author = author
        self.time = time
        self.score = score
        self.kids = kids
        self.url = url
        self.since = since
    }
}
