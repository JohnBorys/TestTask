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
    
    
    func getAllNews(searchingPhrase: String, nextPage: Int?, country: String? = nil, category: String? = nil, source: String?, complition: @escaping (_ recipes: [NewsModel])->()) {
        var stringURL = "https://newsapi.org/v2/top-headlines"
        var categoryString = ""
        var countryString = ""
        var searchString = ""
        var sourceString = ""
        if let category = category {
            categoryString = "category=\(category)&"
        }
        if let country = country {
            countryString = "country=\(country)&"
        }
        if searchingPhrase.count > 0 {
            searchString = "q=\(searchingPhrase)&"
        }
        
        if let _source = source {
            sourceString = "sources=\(_source)&"
        }
        
        stringURL = "https://newsapi.org" + "/v2/top-headlines?"
            + "page=\(nextPage)&" + countryString + categoryString + searchString
            + sourceString + "apiKey=\(apiKey)"
        guard let url = URL(string: stringURL) else {
            return
        }
        var request = URLRequest(url: url)
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
                    
                    if let source = newItem["source"] as? [String : Any] {
                        newsModel.name = source["name"] as! String
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
