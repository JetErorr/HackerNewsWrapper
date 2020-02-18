//
//  DetailViewModel.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 17/02/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import Foundation
import WebKit

class DetailViewModel {

    func openStory(_ target: String, _ mode: String = "") -> URL {

        switch mode {

        case "article":
            if let articleURL = URL(string: "https://news.ycombinator.com/item?id=\(target)") {
                return articleURL
            } else { return URL(string: "")! }

        case "author":
            if let authorURL = URL(string: "https://news.ycombinator.com/user?id=\(target)") {
                return authorURL
            } else { return URL(string: "")! }

        default:
            if let directURL = URL(string: target) {
                return directURL
            } else { return URL(string: "")! }
        }
    }
}
