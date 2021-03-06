//
//  MovieCollectionViewCell.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        return label
    }()
    var favImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = UIColor.white
        image.isUserInteractionEnabled = true
        return image
    }()
    var backImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    var movie: Movie?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppDelegate.backgroundColor
    }
    
    init(frame aFrame: CGRect, andMovie movie: Movie) {
        super.init(frame:aFrame)
        setupWithMovie(movie: movie)
    }
    
    public func setupWithMovie(movie: Movie) {
        self.movie = movie
        
        if let imageData: Data = movie.image {
            addSubview(backImage)
            backImage.image = UIImage(data:imageData)
            backImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
            backImage.heightAnchor.constraint(equalToConstant: bounds.width * 1.5).isActive = true
            backImage.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            backImage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            sendSubviewToBack(backImage)
        }
        
        addSubview(ratingLabel)
        ratingLabel.text = "\(movie.rating)"
        ratingLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        ratingLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        addSubview(favImage)
        favImage.image = movie.favorite ? #imageLiteral(resourceName: "favFilled") : #imageLiteral(resourceName: "favEmpty")
        favImage.image = favImage.image?.withRenderingMode(.alwaysTemplate)
        favImage.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        favImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        let tapRecoginizer = UITapGestureRecognizer(target: self, action: #selector(favoriteMovie))
        favImage.addGestureRecognizer(tapRecoginizer)
        
        
    }
    
    @objc func favoriteMovie() {
        movie!.toggleFavorite()
        favImage.image = movie!.favorite ? #imageLiteral(resourceName: "favFilled") : #imageLiteral(resourceName: "favEmpty")
        favImage.image = favImage.image?.withRenderingMode(.alwaysTemplate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
