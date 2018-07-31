//
//  NetworkDataManager.swift
//  TestTask
//
//  Created by Іван on 7/26/18.
//  Copyright © 2018 Ivan. All rights reserved.
//

import UIKit

class NetworkDataManager {
    static let sharedNetworkDataManager = NetworkDataManager()
    let apaKey = "e6b65ba5499f4b1f8817d582038435a6"
    let country = "us"
    
    func getAllNews(complition: @escaping (_ recipes: [NewsModel])->()) {
        // 1 URL
        var stringURL = "https://newsapi.org/v2/top-headlines"
        //        stringURL = stringURL + "?" + country + "&" + "apiKey=\(apaKey)"
        stringURL = "https://newsapi.org/v2/everything?q=bitcoin&" + "sortBy=popularity&" + "apiKey=e6b65ba5499f4b1f8817d582038435a6"
        guard let url = URL(string: stringURL) else {
            return
        }
        
        var request = URLRequest(url: url)
        // 2 HTTP method
        request.httpMethod = "GET"
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("resieve error, \(error.debugDescription)")
            }
            if let _data = data {
                var encodedData: [String : Any] = [:]
                do {
                    encodedData = try JSONSerialization.jsonObject(with: _data, options: .mutableContainers) as?
                        [String : Any] ?? [:]
                }
                catch {
                    print("serialization error")
                }
                print(encodedData)
                guard let reseepsDictionariesArray = encodedData["articles"] as? [[String : Any]] else {
                    return
                }
                var recipesModelsArray: [NewsModel] = []
                for newsDictionary in reseepsDictionariesArray {
                    let newsModel = NewsModel()

                    if let title = newsDictionary["title"] as? String {
                        newsModel.title = title
                    }
                    if let description = newsDictionary["description"] as? String {
                        newsModel.description = description
                    }
                    if let author = newsDictionary["author"] as? String {
                        newsModel.author = author
                    }
                    if let name = newsDictionary["name"] as? String {
                        newsModel.name = name
                    }
                    if let image = newsDictionary["urlToImage"] as? String {
                        newsModel.imageURLString = image
                    }
                    if let url = newsDictionary["url"] as? String {
                        newsModel.url = url
                    }
                    
                    
                    recipesModelsArray.append(newsModel)
                }
                print("recived response frome server")
                complition(recipesModelsArray)
                
            }
        }
        
        task.resume()
        
    }
}
