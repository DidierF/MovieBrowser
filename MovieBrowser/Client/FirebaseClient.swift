//
//  FirebaseClient.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/24/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class FirebaseClient: NSObject {

    fileprivate let dbName: String = "moviebrowser-77e67"
    fileprivate let apiKey: String = "TMDB_API_KEY"
    let cache = NSCache<AnyObject, AnyObject>()
    
    func getTmdbApiKey(withCompletion completion: @escaping (String) -> Void) {
        if let key = cache.object(forKey: apiKey as AnyObject) {
            completion(key as! String)
            return
        }
        
        let ref: DatabaseReference! = Database.database().reference(fromURL: "https://\(dbName).firebaseio.com/").child("\(apiKey)")
        ref!.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            self.cache.setObject(snapshot.value as AnyObject, forKey: self.apiKey as AnyObject)
            completion(snapshot.value as! String)
        }
    }
    
    
}
