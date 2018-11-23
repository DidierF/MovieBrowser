//
//  Movie.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit
import CoreData

class Movie: NSManagedObject {
    static let favoriteNotificationName = Notification.Name("favoriteNotification")
    
    public static let imageWidth: CGFloat = 130
    
    public func toggleFavorite() {
        favorite = !favorite
        do {
            try self.managedObjectContext?.save()
        } catch let err {
            print("Error saving movie:\n\(err)")
        }
        NotificationCenter.default.post(Notification.init(name: Movie.favoriteNotificationName))
    }
}
