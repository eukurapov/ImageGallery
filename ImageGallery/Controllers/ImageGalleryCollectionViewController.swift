//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by Evgeniy Kurapov on 14.08.2020.
//

import UIKit

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout, UIDropInteractionDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchCollection(recognizer:)))
        collectionView.addGestureRecognizer(pinchGestureRecognizer)
        
        let trashImage = UIImage(systemName: "trash")
        let trashView = UIImageView(image: trashImage)
        let dropInteraction = UIDropInteraction(delegate: self)
        trashView.addInteraction(dropInteraction)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: trashView)
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    // MARK: - Gesture
    
    @objc private func pinchCollection(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            fixedWidth *= Double(recognizer.scale)
            recognizer.scale = 1.0
        default:
            return
        }
    }
    
    // MARK: - Model
    
    var gallery = IGGallery(name: "Unnamed") {
        didSet {
            title = gallery.name
            collectionView.reloadData()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowImage" {
            if let fullImageView = segue.destination as? FullImageViewController,
                let cell = sender as? ImageCollectionViewCell {
                fullImageView.url = cell.url
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            let image = gallery.images[indexPath.item]
            imageCell.url = image.url
        }
        return cell
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    private var fixedWidth: Double = 200 {
        didSet {
            flowLayout?.invalidateLayout()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let aspectRatio = gallery.images[indexPath.item].aspectRatio
        return CGSize(width: fixedWidth, height: fixedWidth / aspectRatio)
    }
    
    // MARK: - UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        if let image = (collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.imageView.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = (image: gallery.images[indexPath.item], indexPath: indexPath)
            return [dragItem]
        }
        return []
    }
    
    // MARK: - UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        if isSelf {
            return session.canLoadObjects(ofClass: UIImage.self)
        } else {
            return session.canLoadObjects(ofClass: UIImage.self) && session.canLoadObjects(ofClass: URL.self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let image = (item.dragItem.localObject as? (IGImage, IndexPath))?.0 {
                    collectionView.performBatchUpdates({
                        gallery.images.remove(at: sourceIndexPath.item)
                        gallery.images.insert(image, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                var dragImageRatio: Double?
                
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    if let image = provider as? UIImage {
                        dragImageRatio = Double(image.size.width) / Double(image.size.height)
                    }
                }
                
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    if let url = provider as? URL, let dragImageRatio = dragImageRatio {
                        DispatchQueue.main.async {
                            let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: self.placeholderReuseIdentifier))
                            placeholderContext.commitInsertion { indexPath in
                                self.gallery.images.insert(IGImage(url: url.imageURL, aspectRatio: dragImageRatio), at: indexPath.item)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UIDropInteractionDelegate
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.localDragSession != nil
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return session.localDragSession != nil ? UIDropProposal(operation: .copy) : UIDropProposal(operation: .forbidden)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        if let imageView = interaction.view as? UIImageView {
            imageView.tintColor = .systemBlue
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        if let imageView = interaction.view as? UIImageView {
            imageView.tintColor = .systemBlue
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        if let imageView = interaction.view as? UIImageView {
            imageView.tintColor = .red
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        var itemsToRemove: [IndexPath] = []
        for item in session.items {
            if let indexPath = (item.localObject as? (IGImage, IndexPath))?.1 {
                itemsToRemove.append(indexPath)
            }
        }
        if !itemsToRemove.isEmpty {
            collectionView.performBatchUpdates({
                for indexPath in itemsToRemove {
                    gallery.images.remove(at: indexPath.item)
                }
                collectionView.deleteItems(at: itemsToRemove)
            })
        }
    }
    
    // MARK: - Constant values
    
    private let reuseIdentifier = "ImageCell"
    private let placeholderReuseIdentifier = "PlaceholderCell"
    
}

