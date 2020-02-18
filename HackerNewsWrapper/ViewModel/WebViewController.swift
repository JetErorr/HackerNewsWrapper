//
//  WebViewController.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 17/02/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var url: URL!
    var webView: WKWebView!

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.load(URLRequest(url: url))
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        toolbarItems = [refresh]
        navigationController?.isToolbarHidden = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = self.webView.title
    }
}
