//
//  MovieWSClient.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/24/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit
import Moya
import AlamofireImage
import Alamofire
import CoreData

class MovieWSClient: NSObject {
    
    let movieProvider = MoyaProvider<MovieProvider>()
    
    
    func getStoredMovieIds() -> Set<Int16> {
        let idReq: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        idReq.propertiesToFetch = ["extId"]
        idReq.resultType = .dictionaryResultType
        do {
            if let results = try AppDelegate.viewContext.fetch(idReq) as? [[String: Any]] {
                let idSet = Set<Int16>(results.compactMap({ (dict) -> Int16? in
                    return dict["extId"] as? Int16
                }))
                print("Stored extIds: \n \(idSet)")
                return idSet
            }
        } catch let error as NSError {
            print("Error getting stored ids: \(error)")
        }
        return Set<Int16>()
    }
    
    func getLastPage(forType type: Movie.Sort) -> Int16 {
        
        let pageRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "MoviesPage")
        pageRequest.predicate = NSPredicate(format: "pageType = \(type.rawValue)")
        pageRequest.propertiesToFetch = ["last"]
        pageRequest.resultType = .dictionaryResultType
        
        do {
            if let pages = try AppDelegate.viewContext.fetch(pageRequest) as? [[String: Int16]] {
                if pages.count == 0 {
                    return 0
                } else {
                    return pages.first!["last"]!
                }
            }
        } catch let err {
            print("Error getting last page: \(err)")
        }
        return 0
    }
    
    func saveLastPage(newPage page: Int16, forType type: Movie.Sort) {
        
        let pageRequest: NSFetchRequest<MoviesPage> = MoviesPage.fetchRequest()
        pageRequest.predicate = NSPredicate(format: "pageType = \(type.rawValue)")
        
        do {
            if let pages = try AppDelegate.viewContext.fetch(pageRequest) as [MoviesPage]? {
                if pages.count == 0 {
                    let newPage = MoviesPage(context: AppDelegate.viewContext)
                    newPage.pageType = type.rawValue
                    newPage.last = page
                } else {
                    pages.first!.last = page
                }
                try AppDelegate.viewContext.save()
            }
        } catch let err {
            print("Error saving last page: \(err)")
        }
        
    }
    
    func fetchMoviesByRating(page: Int16 = 1, completion: @escaping ([Movie]) -> Void, andImageCompletion imageCompletion: @escaping () -> Void) {
        if page > getLastPage(forType: .Rating) {
            firebase.getTmdbApiKey { (apiKey) in
                self.movieProvider.request(.fetchMoviesByRating(apiKey: apiKey, page: page)) { (result) in
                    switch result {
                    case .success(let response):
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
                            let movies = json["results"] as! [[String:Any]]
                            
                            self.saveLastPage(newPage: page, forType: .Rating)
                            
                            completion(self.parseMovies(fromDict: movies, context: AppDelegate.viewContext, storedIds: self.getStoredMovieIds(), withCompletion: imageCompletion))
                            
                        } catch let error as NSError {
                            print("\(error)")
                        }
                    case .failure(let error):
                        print("Error fetching movies from TMDB:\n\(error)")
                    }
                }
            }
        }
    }
    
    func fetchMoviesByYear(page: Int16 = 1, ascending: Bool = false, completion: @escaping ([Movie]) -> Void, andImageCompletion imageCompletion: @escaping () -> Void) {
        let sort: Movie.Sort = ascending ? .YearAsc : .YearDesc
        if page > getLastPage(forType: sort) {
            firebase.getTmdbApiKey { (apiKey) in
                self.movieProvider.request(.fetchMoviesByYear(apiKey: apiKey, page: page, ascending: ascending)) { (result) in
                    switch result {
                    case .success(let response):
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
                            let movies = json["results"] as! [[String:Any]]
                            
                            self.saveLastPage(newPage: page, forType: sort)
                            
                            completion(self.parseMovies(fromDict: movies, context: AppDelegate.viewContext, storedIds: self.getStoredMovieIds(), withCompletion: imageCompletion))
                        } catch let error as NSError {
                            print("\(error)")
                        }
                    case .failure(let error):
                        print("Error fetching movies from TMDB:\n\(error)")
                    }
                }
            }
        }
    }
    
    func parseMovies(fromDict movies: [[String: Any]], context: NSManagedObjectContext, storedIds: Set<Int16>, withCompletion completion: @escaping () -> Void) -> [Movie] {
        var temp = [Movie]()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd"
        
        for movie in movies {
            if let newId = movie["id"] {
                let intId = (newId as! NSNumber).int16Value
                if !storedIds.contains(intId) {
                    let newMovie = Movie(context: context)
                    newMovie.extId = intId
                    newMovie.title = movie["title"] as? String
                    newMovie.sinopsis = movie["overview"] as? String
                    newMovie.rating = (movie["vote_average"] as! NSNumber).doubleValue
                    newMovie.favorite = false
                    guard let dateString = movie["release_date"] as? String else {
                        AppDelegate.viewContext.delete(newMovie)
                        continue
                    }
                    
                    newMovie.publication = formatter.date(from: dateString)
                    guard let posterPath = movie["poster_path"] as? String else {
                        AppDelegate.viewContext.delete(newMovie)
                        continue
                    }
                    temp.append(newMovie)
                    self.fetchImage(withName: posterPath) { (image: UIImage) in
                        newMovie.image = image.pngData()
                        do {
                            try AppDelegate.viewContext.save()
                        } catch let er {
                            print("Error saving movie:\n\(er)")
                        }
                        
                        completion()
                    }
                    do {
                        try AppDelegate.viewContext.save()
                    } catch let er {
                        print("Error saving movie:\n\(er)")
                    }
                }
            }
        }
        
        return temp
    }
    
    func fetchImage(withName imageName: String, andCompletion completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global(qos: .background).async {
            Alamofire.request("https://image.tmdb.org/t/p/w300/\(imageName)?api_key=3e1ebc5c2fbd4ca68824378351d25f3e").responseImage(completionHandler: { response in
                DispatchQueue.main.async {
                    completion(UIImage(data:(response.result.value?.pngData())!)!)
                }
            })
        }
    }

}
