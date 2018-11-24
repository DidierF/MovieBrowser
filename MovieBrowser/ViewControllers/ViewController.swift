//
//  ViewController.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit

class ViewController: MovieCollectionViewController {
    
    private let movieClient = MovieWSClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector((favoriteNotificationHandler(notification:))), name: Movie.favoriteNotificationName, object: nil)
    }
    
    @objc func favoriteNotificationHandler(notification: Notification) {
        loadMovies()
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
            self.view.isUserInteractionEnabled = false
            // reached the bottom
            let nextPage = movieClient.getLastPage(forType: self.sorting) + 1
            let completion: ([Movie]) -> Void = { (newMovies) in
                self.view.isUserInteractionEnabled = true
                self.loadMovies()
            }
            let imageCompletion: () -> Void = {
                self.loadMovies()
            }
            
            switch self.sorting {
            case .Rating:
                DispatchQueue.global().async {
                    self.movieClient.fetchMoviesByRating(page: nextPage, completion: completion, andImageCompletion: imageCompletion)
                }
            case .YearAsc:
                DispatchQueue.global().async {
                    self.movieClient.fetchMoviesByYear(page: nextPage, ascending: true, completion: completion, andImageCompletion: imageCompletion)
                }
            case .YearDesc:
                DispatchQueue.global().async {
                    self.movieClient.fetchMoviesByYear(page: nextPage, ascending: false, completion: completion, andImageCompletion: imageCompletion)
                }
            case .NameAsc:
                DispatchQueue.global().async {
                    self.movieClient.fetchMoviesByRating(page: nextPage, completion: completion, andImageCompletion: imageCompletion)
                }
            case .NameDesc:
                DispatchQueue.global().async {
                    self.movieClient.fetchMoviesByRating(page: nextPage, completion: completion, andImageCompletion: imageCompletion)
                }
            }
        }
    }


}

