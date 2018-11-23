//
//  ViewController.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit

class ViewController: MovieCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector((favoriteNotificationHandler(notification:))), name: MovieCollectionViewCell.favoriteNotificationName, object: nil)
    }
    
    @objc func favoriteNotificationHandler(notification: Notification) {
        loadMovies()
    }


}

