//
//  MovieClient.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum MovieClient {
    case fetchMoviesByRating(page: Int)
    case fetchMoviesByYear(page: Int, ascending: Bool)
}

let TMDB_API_KEY = "3e1ebc5c2fbd4ca68824378351d25f3e"

extension MovieClient: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3")!
    }
    
    var path: String {
        switch self {
        case .fetchMoviesByRating:
            return "/movie/top_rated"
        case .fetchMoviesByYear:
            return "/discover/movie"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchMoviesByRating:
            return .get
        case .fetchMoviesByYear:
            return .get
        }
    }
    
    var sampleData: Data {
        return "{}".data(using: .utf8)!
    }
    
    var task: Task {
        var params: [String: Any] = ["api_key": TMDB_API_KEY]
        
        switch self {
        case .fetchMoviesByRating(let page):
            params["page"] = page
        case .fetchMoviesByYear(let page, let ascending):
            params["page"] = page
            params["sort_by"] = ascending ? "release_date.asc" : "release_date.desc"
        }
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    
}

