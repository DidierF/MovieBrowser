//
//  MovieProvider.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum MovieProvider {
    case fetchMoviesByRating(apiKey: String, page: Int16)
    case fetchMoviesByYear(apiKey: String, page: Int16, ascending: Bool)
}

let firebase = FirebaseClient()

extension MovieProvider: TargetType {
    
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
        var params: [String: Any] = [:]
        
        switch self {
        case .fetchMoviesByRating(let apiKey, let page):
            params["api_key"] = apiKey
            params["page"] = page
            
        case .fetchMoviesByYear(let apiKey, let page, let ascending):
            params["api_key"] = apiKey
            params["page"] = page
            params["sort_by"] = ascending ? "release_date.asc" : "release_date.desc"
        }
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
    
}

