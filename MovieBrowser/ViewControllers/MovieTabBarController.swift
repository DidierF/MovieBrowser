//
//  MovieTabBarController.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit
import CoreData
import Moya

class MovieTabBarController: UITabBarController {
    
    var movies = [Movie]()
    let movieProvider = MoyaProvider<MovieClient>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = (Bundle.main.infoDictionary!["CFBundleName"] as! String)
        
        setupTabs()
        fetchMovies()
    }
    
    fileprivate func setupTabs() {
        UITabBar.appearance().barTintColor = AppDelegate.backgroundColor
        self.tabBar.unselectedItemTintColor = AppDelegate.tintColor
        
        let mainViewController = ViewController()
        mainViewController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "movieIcon"), selectedImage: #imageLiteral(resourceName: "movieIcon"))
        
        let favViewController = FavoritesViewController()
        favViewController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "favEmpty"), selectedImage: #imageLiteral(resourceName: "favFilled"))
        
        self.viewControllers = [mainViewController, favViewController]
    }
    
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
    
    func fetchMovies(page: Int = 1) {
        movieProvider.request(.fetchMoviesByRating(page: page)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
                    let movies = json["results"] as! [[String:Any]]
                    
                    self.movies = self.parseMovies(fromDict: movies, context: AppDelegate.viewContext, storedIds: self.getStoredMovieIds())
                } catch let error as NSError {
                    print("\(error)")
                }
                (self.selectedViewController as? UICollectionViewController)?.collectionView.reloadData()
            case .failure(let error):
                print("Error fetching movies from TMDB:\n\(error)")
            }
        }
    }
    
    func parseMovies(fromDict movies: [[String: Any]], context: NSManagedObjectContext, storedIds: Set<Int16>) -> [Movie] {
        var temp = [Movie]()
        
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
                    temp.append(newMovie)
                    
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

}
