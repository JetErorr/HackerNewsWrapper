//
//  DetailViewModel.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 17/02/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import Foundation
import SafariServices
import UIKit

class DetailViewModel {

    var url = URL(string: "")

}

extension DetailViewModel {

    func openStory(_ target: String, _ mode: String = "") -> SFSafariViewController {

        switch mode {

        case "article":
            if let articleURL = URL(string: "https://news.ycombinator.com/item?id=\(target)") {
                url = articleURL
            } else { print("Items") }

        case "author":
            if let authorURL = URL(string: "https://news.ycombinator.com/user?id=\(target)") {
                url = authorURL
            } else { print("any") }

        default:
            if let directURL = URL(string: target) {
                url = directURL
            } else { print("...") }
        }

        let safariVC = SFSafariViewController(url: url!)
        return safariVC
    }
}
