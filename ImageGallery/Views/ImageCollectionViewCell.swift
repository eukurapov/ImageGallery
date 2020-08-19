//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Evgeniy Kurapov on 14.08.2020.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    var url: URL? {
        didSet {
            if url != oldValue {
                fetchImage()
            }
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private func fetchImage() {
        self.imageView.image = nil
        if let urlToFetch = self.url {
            activityIndicator.startAnimating()
            URLSession.shared.dataTask(with: urlToFetch) { (data, response, error) in
                DispatchQueue.main.async {
                    if urlToFetch == self.url {
                        if data != nil, let image = UIImage(data: data!) {
                            self.activityIndicator.stopAnimating()
                            self.imageView.image = image
                        }
                    }
                }
            }.resume()
        }
    }
    
}
