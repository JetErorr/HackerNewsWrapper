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

//        for _ in 0...100 {
//            saveService.removeFromSaved(893)
//        }

        tabBarController?.selectedIndex = 0

        if let topStory = viewControllers?[0] as? ViewController {
            topStory.newsViewModel = NewsViewModel(cat: "topstories")
        }
        if let newStory = viewControllers?[1] as? ViewController {
            newStory.newsViewModel = NewsViewModel(cat: "newstories")
        }
        if let bestStory = viewControllers?[2] as? ViewController {
            bestStory.newsViewModel = NewsViewModel(cat: "beststories")
        }
        if let savedStory = viewControllers?[3] as? ViewController {
            savedStory.newsViewModel = NewsViewModel(cat: "saved")
        }

        let items = tabBar.items!
        items[0].title = "Top Stories"
        items[0].image = UIImage(systemName: "arrow.up.circle.fill")
        items[1].title = "New Stories"
        items[1].image = UIImage(systemName: "pencil.circle.fill")
        items[2].title = "Best Stories"
        items[2].image = UIImage(systemName: "star.circle.fill")
        items[3].title = "Saved Stories"
        items[3].image = UIImage(systemName: "star.circle.fill")
    }
}
