//
//  IGGallery.swift
//  ImageGallery
//
//  Created by Eugene Kurapov on 18.08.2020.
//

import Foundation

class IGGallery {
    
    var name: String
    var images = [IGImage]()
    
    init(name: String) {
        self.name = name
    }
    
}
