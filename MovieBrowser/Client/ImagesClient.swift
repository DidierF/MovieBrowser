//
//  ImagesClient.swift
//  MovieBrowser
//
//  Created by Didier Fuentes on 11/22/18.
//  Copyright © 2018 Didier Fuentes. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ImagesClient: NSObject {

    func fetchImage(withName imageName: String, andCompletion completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global(qos: .background).async {
            Alamofire.request("https://image.tmdb.org/t/p/w300/\(imageName)?api_key=3e1ebc5c2fbd4ca68824378351d25f3e").responseImage(completionHandler: { response in
                DispatchQueue.main.async {
                    completion(UIImage(data:(response.result.value?.pngData())!)!)
                }
            })
        }
    }
}
