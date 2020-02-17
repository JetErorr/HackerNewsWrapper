//
//  DetailViewModel.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 17/02/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import Foundation
import UIKit

class DetailViewModel {

    func openStory(_ target: String, _ mode: String = "") {

        let url: URL

        switch mode {

        case "article":
            if let articleURL = URL(string: "https://news.ycombinator.com/item?id=\(target)") {
                url = articleURL
            } else { return }

        case "author":
            if let authorURL = URL(string: "https://news.ycombinator.com/user?id=\(target)") {
                url = authorURL
            } else { return }

        default:
            if let directURL = URL(string: target) {
                url = directURL
            } else { return }
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    // 7. Open the URL with the default browser
}
