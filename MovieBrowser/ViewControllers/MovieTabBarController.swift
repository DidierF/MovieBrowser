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

class MovieTabBarController: UITabBarController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var movies = [Movie]()
    let firebase = FirebaseClient()
    let movieProvider = MoyaProvider<MovieProvider>()
    let picker = UIPickerView()
    let sortOptions: [String] = [
        "Rating",
        "Publication old first",
        "Publication new first"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = (Bundle.main.infoDictionary!["CFBundleName"] as! String)
        
        setupPicker()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "filter"), style: .plain, target: self, action: #selector(sortMovies))
        navigationItem.rightBarButtonItem?.tintColor = AppDelegate.tintColor
        
        setupTabs()
        fetchMoviesByRating()
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
    
    fileprivate func setupPicker() {
        picker.isHidden = true
        picker.delegate = self
        picker.dataSource = self
        
        view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        picker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        picker.backgroundColor = AppDelegate.backgroundColor
        picker.tintColor = AppDelegate.tintColor
        picker.layer.cornerRadius = 15
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
    
    @objc func sortMovies() {
        picker.isHidden = false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.sortOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: sortOptions[row], attributes: [NSAttributedString.Key.foregroundColor: AppDelegate.tintColor])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let controller = self.selectedViewController as! MovieCollectionViewController
        switch row {
        case 0:
            controller.set(sort: .Rating)
            fetchMoviesByRating()
        case 1:
            controller.set(sort: .YearAsc)
            fetchMoviesByYear(ascending: true)
        case 2:
            controller.set(sort: .YearDesc)
            fetchMoviesByYear(ascending: false)
        default:
            controller.set(sort: .Rating)
            fetchMoviesByRating()
        }
        controller.loadMovies()
        picker.isHidden = true
    }
    
    func fetchMoviesByRating(page: Int = 1) {
        firebase.getTmdbApiKey { (apiKey) in
            self.movieProvider.request(.fetchMoviesByRating(apiKey: apiKey, page: page)) { (result) in
                switch result {
                case .success(let response):
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
                        let movies = json["results"] as! [[String:Any]]
                        
                        let sort: Movie.sort = .Rating
                        (self.selectedViewController as! MovieCollectionViewController).set(sort: sort)
                        self.movies = self.parseMovies(fromDict: movies, context: AppDelegate.viewContext, storedIds: self.getStoredMovieIds())
                    } catch let error as NSError {
                        print("\(error)")
                    }
                case .failure(let error):
                    print("Error fetching movies from TMDB:\n\(error)")
                }
            }
        }
    }
    
    func fetchMoviesByYear(page: Int = 1, ascending: Bool = false) {
        firebase.getTmdbApiKey { (apiKey) in
            self.movieProvider.request(.fetchMoviesByYear(apiKey: apiKey, page: page, ascending: ascending)) { (result) in
                switch result {
                case .success(let response):
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
                        let movies = json["results"] as! [[String:Any]]
                        
                        let sort: Movie.sort = ascending ? .YearAsc : .YearDesc
                        (self.selectedViewController as! MovieCollectionViewController).set(sort: sort)
                        self.movies = self.parseMovies(fromDict: movies, context: AppDelegate.viewContext, storedIds: self.getStoredMovieIds())
                    } catch let error as NSError {
                        print("\(error)")
                    }
                case .failure(let error):
                    print("Error fetching movies from TMDB:\n\(error)")
                }
            }
        }
    }
    
    func parseMovies(fromDict movies: [[String: Any]], context: NSManagedObjectContext, storedIds: Set<Int16>) -> [Movie] {
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
                    ImagesClient().fetchImage(withName: posterPath) { (image: UIImage) in
                        newMovie.image = image.pngData()
                        do {
                            try AppDelegate.viewContext.save()
                        } catch let er {
                            print("Error saving movie:\n\(er)")
                        }
                        
                        (self.selectedViewController as! MovieCollectionViewController).loadMovies()
                    }
                    do {
                        try AppDelegate.viewContext.save()
                    } catch let er {
                        print("Error saving movie:\n\(er)")
                    }
                }
            }
            (selectedViewController as! MovieCollectionViewController).loadMovies()
        }
        
        return temp
    }

}
