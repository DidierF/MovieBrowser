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
    let movieClient = MovieWSClient()
    let firebase = FirebaseClient()
    let picker = UIPickerView()
    let sortOptions: [String] = [
        "Rating",
        "Publication, old first",
        "Publication, new first",
        "Name, A-Z",
        "Name, Z-A"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = (Bundle.main.infoDictionary!["CFBundleName"] as! String)
        
        setupPicker()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "filter"), style: .plain, target: self, action: #selector(sortMovies))
        navigationItem.rightBarButtonItem?.tintColor = AppDelegate.tintColor
        
        setupTabs()
        movieClient.fetchMoviesByRating(completion: { newMovies in
            let sort: Movie.Sort = .Rating
            self.movies = newMovies
            (self.selectedViewController as! MovieCollectionViewController).set(sort: sort)
        }, andImageCompletion: {
            (self.selectedViewController as! MovieCollectionViewController).loadMovies()
        })
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
        controller.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        switch row {
        case 0:
            controller.set(sort: .Rating)
            movieClient.fetchMoviesByRating(completion:{ newMovies in
                let sort: Movie.Sort = .Rating
                self.movies = newMovies
                (self.selectedViewController as! MovieCollectionViewController).set(sort: sort)
            }, andImageCompletion: {
                (self.selectedViewController as! MovieCollectionViewController).loadMovies()
            })
        case 1:
            controller.set(sort: .YearAsc)
            movieClient.fetchMoviesByYear(ascending: true, completion: { newMovies in
                let sort: Movie.Sort = .YearAsc
                self.movies = newMovies
                (self.selectedViewController as! MovieCollectionViewController).set(sort: sort)
            }, andImageCompletion: {
                (self.selectedViewController as! MovieCollectionViewController).loadMovies()
            })
        case 2:
            controller.set(sort: .YearDesc)
            movieClient.fetchMoviesByYear(ascending: false, completion: { newMovies in
                let sort: Movie.Sort = .YearDesc
                self.movies = newMovies
                (self.selectedViewController as! MovieCollectionViewController).set(sort: sort)
            }, andImageCompletion: {
                (self.selectedViewController as! MovieCollectionViewController).loadMovies()
            })
        case 3:
            controller.set(sort: .NameAsc)
            movieClient.fetchMoviesByRating(completion: { newMovies in
                let sort: Movie.Sort = .YearAsc
                self.movies = newMovies
                (self.selectedViewController as! MovieCollectionViewController).set(sort: sort)
            }, andImageCompletion: {
                (self.selectedViewController as! MovieCollectionViewController).loadMovies()
            })
        case 4:
            controller.set(sort: .NameDesc)
            movieClient.fetchMoviesByRating(completion: { newMovies in
                let sort: Movie.Sort = .YearAsc
                self.movies = newMovies
                (self.selectedViewController as! MovieCollectionViewController).set(sort: sort)
            }, andImageCompletion: {
                (self.selectedViewController as! MovieCollectionViewController).loadMovies()
            })
        default:
            controller.set(sort: .Rating)
            movieClient.fetchMoviesByRating(completion: { newMovies in
                let sort: Movie.Sort = .YearAsc
                self.movies = newMovies
                (self.selectedViewController as! MovieCollectionViewController).set(sort: sort)
            }, andImageCompletion: {
                (self.selectedViewController as! MovieCollectionViewController).loadMovies()
            })
        }
        controller.loadMovies()
        picker.isHidden = true
    }

}
