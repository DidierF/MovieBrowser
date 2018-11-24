//
//  MovieDetailViewController.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    var movie: Movie?
    
    var movieImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    var movieTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    var movieRating: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    var favImage: UIImageView = {
        var image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .white
        image.isUserInteractionEnabled = true
        return image
    }()
    var movieSinopsis: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    convenience init() {
        self.init(movie: nil)
    }
    
    init(movie: Movie?) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupWithMovie(movie: Movie) {
        self.movie = movie
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        view.backgroundColor = AppDelegate.backgroundColor
        
        let screenPadding = 16
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scroll.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(contentView)
        contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scroll.trailingAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scroll.leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.addSubview(movieImage)
        if let imageData: Data = movie?.image {
            movieImage.image = UIImage(data: imageData)
        }
        
        movieImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        movieImage.widthAnchor.constraint(equalToConstant:Movie.imageWidth).isActive = true
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-24-[v0(\(Movie.imageWidth * 1.5))]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0":movieImage]))
        
        contentView.addSubview(movieTitle)
        movieTitle.text = movie!.title
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(screenPadding)-[v0]-\(screenPadding)-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": movieTitle]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1]-8-[v0]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0":movieTitle, "v1":movieImage]))
        
        contentView.addSubview(movieRating)
        movieRating.text = "\(movie!.rating)"
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(screenPadding)-[v0]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": movieRating]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1]-8-[v0]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0":movieRating, "v1":movieTitle]))
        
        contentView.addSubview(favImage)
        favImage.image = movie!.favorite ? #imageLiteral(resourceName: "favFilled") : #imageLiteral(resourceName: "favEmpty")
        favImage.image = favImage.image?.withRenderingMode(.alwaysTemplate)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1]-8-[v0]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0":favImage, "v1":movieTitle]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0]-\(screenPadding)-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": favImage]))
        
        let tapRecoginizer = UITapGestureRecognizer(target: self, action: #selector(favoriteMovie(recognizer:)))
        tapRecoginizer.cancelsTouchesInView = false
        favImage.addGestureRecognizer(tapRecoginizer)
        
        contentView.addSubview(movieSinopsis)
        movieSinopsis.text = movie!.sinopsis
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v1]-24-[v0]", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0":movieSinopsis, "v1":movieRating]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(screenPadding)-[v0]-\(screenPadding)-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": movieSinopsis]))
    }
    
    @objc func favoriteMovie(recognizer: UITapGestureRecognizer) {
        movie!.toggleFavorite()
        favImage.image = movie!.favorite ? #imageLiteral(resourceName: "favFilled") : #imageLiteral(resourceName: "favEmpty")
        favImage.image = favImage.image?.withRenderingMode(.alwaysTemplate)
    }

}
