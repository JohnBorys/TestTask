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
    let apiKey = "e6b65ba5499f4b1f8817d582038435a6"
    var country = ""
    
    
    func getAllNews(endpoint: Endpoints, nextPage: Int, complition: @escaping (_ recipes: [NewsModel])->()) {
        // 1 URL
        var stringURL = "https://newsapi.org/v2/top-headlines"
        //        stringURL = stringURL + "?" + country + "&" + "apiKey=\(apaKey)"
        stringURL = "https://newsapi.org" + endpoint.getString() + "page=\(nextPage)&" + "apiKey=\(apiKey)"
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
                for newItem in reseepsDictionariesArray {
                    let newsModel = NewsModel()
                    
                    if let title = newItem["title"] as? String {
                        newsModel.title = title
                    }
                    
                    if let description = newItem["description"] as? String {
                        newsModel.description = description
                    }
                    
                    if let author = newItem["author"] as? String {
                        newsModel.author = author
                    }
                    
//                    if let source = encodedData["source"] as? [String: Any] {
//                        if let name = source["name"] {
//                            print(name)
//                        }
//                    }
                    
                    if let source = newItem["source"] as? [String : Any] {
                        newsModel.name = source["name"] as! String
//                        for item in source {
//                            print(item.values.count)
//                            if let name = item["name"] as? String {
//                                newsModel.name = name
//                            }
//                        }
                    }
                    
                    if let image = newItem["urlToImage"] as? String {
                        newsModel.imageURLString = image
                    }
                    
                    if let url = newItem["url"] as? String {
                        newsModel.url = url
                    }
                    
                    recipesModelsArray.append(newsModel)
                }
                
                complition(recipesModelsArray)
            }
        }
        
        task.resume()
        
    }
    
}
