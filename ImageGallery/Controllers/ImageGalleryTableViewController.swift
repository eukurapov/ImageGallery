//
//  ImageGalleryTableViewController.swift
//  ImageGallery
//
//  Created by Eugene Kurapov on 19.08.2020.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {
    
    var galleries: [IGGallery] = [
        IGGallery(name: "Space"),
        IGGallery(name: "Cats"),
        IGGallery(name: "Untitled")
    ]

    @IBAction func newGalley(_ sender: UIBarButtonItem) {
        galleries.append(IGGallery(name: "Untitled".madeUnique(withRespectTo: galleries.map { $0.name })))
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return galleries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = galleries[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            galleries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == gallerySegueIdentifier {
            if let collectionView = segue.destination.contents as? ImageGalleryCollectionViewController {
                if let cell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: cell) {
                    let gallery = galleries[indexPath.row]
                    collectionView.gallery = gallery
                }
            }
        }
    }
    
    // MARK: - Constant Values
    
    private let cellReuseIdentifier = "GalleryCell"
    private let gallerySegueIdentifier = "ShowGallery"

}
