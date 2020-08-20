//
//  FullImageViewController.swift
//  ImageGallery
//
//  Created by Eugene Kurapov on 19.08.2020.
//

import UIKit

class FullImageViewController: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.75
            scrollView.maximumZoomScale = 2.0
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var url: URL? {
        didSet {
            if url != oldValue, view.window != nil {
                fetchImage()
            }
        }
    }
    
    private var imageView = UIImageView()
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set(newImage) {
            imageView.image = newImage
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchImage()
    }
    
    private func fetchImage() {
        image = nil
        if let urlToFetch = self.url {
            activityIndicator.startAnimating()
            URLSession.shared.dataTask(with: urlToFetch) { (data, response, error) in
                DispatchQueue.main.async {
                    if urlToFetch == self.url {
                        if data != nil, let image = UIImage(data: data!) {
                            self.activityIndicator.stopAnimating()
                            self.image = image
                        }
                    }
                }
            }.resume()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
}
