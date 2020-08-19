//
//  EditableTableViewCell.swift
//  ImageGallery
//
//  Created by Eugene Kurapov on 19.08.2020.
//

import UIKit

class EditableTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var editHandler: (() -> Void)?
    
    @IBOutlet weak var galleryName: UITextField! {
        didSet {
            let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapCell(recognizer:)))
            doubleTapGesture.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTapGesture)
            
            galleryName.delegate = self
        }
    }
    
    @objc private func doubleTapCell(recognizer: UITapGestureRecognizer) {
        galleryName.isEnabled = true
        galleryName.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        galleryName.isEnabled = false
        galleryName.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editHandler?()
    }
    
}
