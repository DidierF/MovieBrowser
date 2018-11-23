//
//  FavoritesViewController.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: MovieCollectionViewController {

    var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You have no favorite movies!"
        label.textColor = UIColor.white
        label.font = UIFont(name: label.font.fontName, size: 18)
        return label
    }()
    
    override func getMoviesRequest() -> NSFetchRequest<Movie> {
        let movieReq: NSFetchRequest<Movie> = Movie.fetchRequest()
        movieReq.sortDescriptors = [
            NSSortDescriptor(key: "rating", ascending: false)
        ]
        movieReq.predicate = NSPredicate(format: "favorite = true")
        return movieReq
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector((favoriteNotificationHandler(notification:))), name: MovieCollectionViewCell.favoriteNotificationName, object: nil)
    }
    
    @objc func favoriteNotificationHandler(notification: Notification) {
        loadMovies()
        if movies.isEmpty {
            view.addSubview(emptyLabel)
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        } else {
            emptyLabel.removeFromSuperview()
        }
    }

}
