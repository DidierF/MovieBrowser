//
//  MovieTabBarController.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit

class MovieTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = (Bundle.main.infoDictionary!["CFBundleName"] as! String)
        
        setupTabs()
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

}
