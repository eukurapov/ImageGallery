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
            imageView.activityIndicator = activityIndicator
            imageView.completionHandler = { [weak self] in
                self?.imageView.sizeToFit()
                self?.scrollView?.contentSize = self!.imageView.frame.size
            }
        }
    }
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var url: URL? {
        get {
            return imageView.url
        }
        set {
            imageView.url = newValue
        }
    }
    
    private var imageView = FetchedImageView()
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
}
