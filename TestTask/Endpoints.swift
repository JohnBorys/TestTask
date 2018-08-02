//
//  Endpoints.swift
//  TestTask
//
//  Created by Іван on 8/1/18.
//  Copyright © 2018 Ivan. All rights reserved.
//

import UIKit

var searchingPhrase = "Trump"
var country = "us"

enum Endpoints: Int {
    case topHeadlines
    case everything
    case sources
    
    static let count: Int = {
        var max: Int = 0
        while let _ = Endpoints(rawValue: max) { max += 1 }
        return max
    }()
    
    func getString() -> String {
        switch self {
        case .topHeadlines:
            return "/v2/top-headlines?country=\(country)&"
        case .everything:
            return "/v2/everything?q=\(searchingPhrase)&"
        case .sources:
            return "/v2/sources?"
        }
    }
    
    func getName() -> String {
        switch self {
        case .topHeadlines:
            return "Top Headlines"
        case .everything:
            return "Everything"
        case .sources:
            return "Sources"
        }
    }
}


