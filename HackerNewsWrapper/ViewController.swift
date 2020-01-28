//
//  ViewController.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 27/01/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UITableViewController {
    
    var jsonData:JSON = JSON()
    var itemData:[JSON] = [JSON]()
    
    enum procError: Error {
        case fetch
        case parse
    }
    
    @IBOutlet var newsTable: UITableView!
    
    // TODO : Implement onclick overview page
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CustomCell = tableView.dequeueReusableCell(withIdentifier: "newsList", for: indexPath) as! CustomCell
        
        //
        cell.newsTitle.text = self.itemData[indexPath.row]["title"].rawString()
        
        cell.newsAuthor.text = self.itemData[indexPath.row]["by"].rawString()
        cell.newsScore.text = self.itemData[indexPath.row]["score"].rawString()
        print(self.itemData[indexPath.row]["score"])
        
        cell.newsComments.text = String(self.itemData[indexPath.row]["kids"].count)
        print("Kids", self.itemData[indexPath.row]["kids"])
        
        let currentTime = Date().timeIntervalSince1970
        let postTime = Double(self.itemData[indexPath.row]["time"].double!)

        let seconds = currentTime - postTime
        
        var secondsAgo = Int(seconds)
        var timeAgo = String()
        
        if secondsAgo > 3600 {
            secondsAgo = secondsAgo / 3600
            timeAgo = "\(secondsAgo) hours/s ago"
        }
        else if secondsAgo > 60 {
            secondsAgo = secondsAgo / 60
            timeAgo = "\(secondsAgo) minute/s ago"
        }else if secondsAgo < 60 {
            timeAgo = "\(secondsAgo) second/s ago"
        }

        cell.newsTime.text = timeAgo
        //
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Use the default size for all other rows.
        //        return UITableView.automaticDimension
        return 120
    }
    
    
    func fetchJSON() -> Result<String?, procError>{
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: Result<String?, procError>!
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            
            if let data = data {
                result = .success(String(data: data, encoding: .utf8))
                do {
                    self.jsonData = try JSON(data: data)
                    //                    print(self.jsonData)
                } catch {
                    print("Json err")
                }
            } else {
                result = .failure(.parse)
            }
            
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        _ = parseJSON()
        return result
    }
    
    func parseJSON() -> Result<String?, procError>{
        
        let semaphore1 = DispatchSemaphore(value: 0)
        
        var result1: Result<String?, procError>!
        
        for i in 0...3 {
            //        var i = 0
            //            print(self.jsonData[i])
            let url2String = "https://hacker-news.firebaseio.com/v0/item/\(self.jsonData[i].rawString()!).json"
            //            let url2String = "https://hacker-news.firebaseio.com/v0/item/8863.json"
            print(url2String)
            let url2 = URL(string: url2String)!
            URLSession.shared.dataTask(with: url2) { data, _, _ in
                
                if let data = data {
                    result1 = .success(String(data: data, encoding: .utf8))
//                    print(data)
                    do {
                        let tmp = try JSON(data: data)
                        self.itemData.append(tmp)
//                        print(self.itemData[i]["title"])
                    } catch {
                        print("Item err")
                    }
                } else {
                    result1 = .failure(.parse)
                }
                semaphore1.signal()
            }.resume()
            
            _ = semaphore1.wait(timeout: .distantFuture)
        }
        return result1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = fetchJSON()
    }
}
