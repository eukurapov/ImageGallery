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
    
    private var isRemoved = false
    var isActive: Bool { !isRemoved }
    
    init(name: String) {
        self.name = name
    }
    
    func remove() {
        isRemoved = true
    }
    
    func restore() {
        isRemoved = false
    }
    
}
