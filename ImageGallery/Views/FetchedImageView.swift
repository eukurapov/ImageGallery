//
//  FetchedImageView.swift
//  ImageGallery
//
//  Created by Eugene Kurapov on 20.08.2020.
//

import UIKit

class FetchedImageView: UIImageView {
    
    var url: URL? {
        didSet {
            fetchImage()
        }
    }
    var activityIndicator: UIActivityIndicatorView?
    var completionHandler: (() -> Void)?
    
    private func fetchImage() {
        self.image = nil
        if let urlToFetch = self.url {
            activityIndicator?.startAnimating()
            URLSession.shared.dataTask(with: urlToFetch) { (data, response, error) in
                DispatchQueue.main.async {
                    if urlToFetch == self.url {
                        if data != nil, let fetchedImage = UIImage(data: data!) {
                            self.activityIndicator?.stopAnimating()
                            self.image = fetchedImage
                            self.completionHandler?()
                        }
                    }
                }
            }.resume()
        }
    }

}
