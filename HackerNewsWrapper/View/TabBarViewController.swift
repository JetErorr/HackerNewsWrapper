//
//  TabBarViewController.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 31/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //swiftlint:disable force_cast
        let topNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsList") as! ViewController
        topNewsVC.newsViewModel = NewsViewModel(cat: "topstories")
        topNewsVC.tabBarItem.title = "Top Stories"
        topNewsVC.tabBarItem.image = UIImage(systemName: "arrow.up.circle.fill")

        let newNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsList") as! ViewController
        newNewsVC.newsViewModel = NewsViewModel(cat: "newstories")
        newNewsVC.tabBarItem.title = "New Stories"
        newNewsVC.tabBarItem.image = UIImage(systemName: "pencil.circle.fill")

        let bestNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsList") as! ViewController
        bestNewsVC.newsViewModel = NewsViewModel(cat: "beststories")
        bestNewsVC.tabBarItem.title = "Best Stories"
        bestNewsVC.tabBarItem.image = UIImage(systemName: "star.circle.fill")

        let savedNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "NewsList") as! ViewController
        savedNewsVC.newsViewModel = NewsViewModel(cat: "saved")
        savedNewsVC.tabBarItem.title = "Saved Stories"
        savedNewsVC.tabBarItem.image = UIImage(systemName: "star.circle.fill")
        //swiftlint:enable force_cast

        viewControllers = [topNewsVC, newNewsVC, bestNewsVC, savedNewsVC]

        tabBarController?.selectedIndex = 0
    }
}
