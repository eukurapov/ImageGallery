//
//  IGImage.swift
//  ImageGallery
//
//  Created by Eugene Kurapov on 18.08.2020.
//

import Foundation

struct IGImage: Codable {
    
    var url: URL
    var aspectRatio: Double
    
    init?(url: URL, aspectRatio: Double) {
        if url.absoluteString.contains("http://") {
            if let safeUrl = URL(string: url.absoluteString.replacingOccurrences(of: "http://", with: "https://")) {
                print(url.absoluteString)
                self.url = safeUrl
            } else {
                return nil
            }
        } else {
            self.url = url
        }
        self.aspectRatio = aspectRatio
    }
    
}
