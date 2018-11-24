//
//  MovieCollectionViewController.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class MovieCollectionViewController: UICollectionViewController {
    
    var movies: [Movie] = []
    var sorting: Movie.Sort = .Rating
    
    init() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 130, height: 235)
        super.init(collectionViewLayout: layout)
    }
    
    override init(collectionViewLayout: UICollectionViewLayout) {
        super.init(collectionViewLayout: collectionViewLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = AppDelegate.backgroundColor
        
        loadMovies()
    }
    
    private func getMoviesSortDescriptor(sort: Movie.Sort) -> [NSSortDescriptor]{
        switch sort {
        case .Rating:
            return [NSSortDescriptor(key: "rating", ascending: false)]
        case .YearAsc:
            return [NSSortDescriptor(key: "publication", ascending: true)]
        case .YearDesc:
            return [NSSortDescriptor(key: "publication", ascending: false)]
        }
    }
    
    func getRequestPredicate() -> NSPredicate? {
        return nil
    }
    
    private func getMoviesRequest(withSort sortDescriptors: [NSSortDescriptor]) -> NSFetchRequest<Movie> {
        let movieReq: NSFetchRequest<Movie> = Movie.fetchRequest()
        movieReq.sortDescriptors = sortDescriptors
        movieReq.predicate = self.getRequestPredicate()
        return movieReq
    }
    
    func loadMovies() {
        // Load stored movies
        do {
            movies = try AppDelegate.viewContext.fetch(getMoviesRequest(withSort: getMoviesSortDescriptor(sort: sorting)))
        } catch let error as NSError {
            print("Error getting stored movies: \(error)")
        }
        collectionView.reloadData()
    }
    
    func set(sort: Movie.Sort) {
        self.sorting = sort
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MovieCollectionViewCell
        
        // Configure the cell
        cell.setupWithMovie(movie: movies[indexPath.row])
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = MovieDetailViewController(movie: movies[indexPath.row])
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
