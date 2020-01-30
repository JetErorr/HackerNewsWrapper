//
//  NewsModel.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 27/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

// Model for the MVVM pattern
import Foundation

struct NewsModel {
    //swiftlint:enable all
    let title: String
    let author: String
    let time: String
    let score: Int
    let comments: Int
    
    init() {
        title = ""
        author = ""
        time = ""
        score = Int()
        comments = Int()
    }
    
    init(title: String, author: String, time: String, score: Int, comments: Int) {
        self.title = title
        self.author = author
        self.time = time
        self.score = score
        self.comments = comments
    }
}
