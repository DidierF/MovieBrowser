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
    }

}
