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
    
    var activeGalleries:[IGGallery] {
        galleries.filter { $0.isActive }
    }
    
    var removedGalleries:[IGGallery] {
        galleries.filter { !$0.isActive }
    }

    @IBAction func newGalley(_ sender: UIBarButtonItem) {
        galleries.append(IGGallery(name: "Untitled".madeUnique(withRespectTo: galleries.map { $0.name })))
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let jsonGalleries = loadFromUserDefaults() {
            galleries = jsonGalleries
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tableView.indexPathForSelectedRow == nil && !activeGalleries.isEmpty {
            selectRow(at: IndexPath(row: 0, section: 0))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveGalleriesToUserDefaults()
    }
    
    private var selectRowTimer: Timer?
    private func selectRow(at indexPath: IndexPath, withInterval interval: TimeInterval = 0) {
        selectRowTimer?.invalidate()
        selectRowTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] timer in
            self?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            self?.performSegue(withIdentifier: self!.gallerySegueIdentifier, sender: self?.tableView.cellForRow(at: indexPath))
        }
    }
    
    // MARK: - UserDefaults
    
    private func loadFromUserDefaults() -> [IGGallery]? {
        if let dataArray = UserDefaults.standard.array(forKey: galleriesUserDefaultsKey) as? [Data] {
            return dataArray.compactMap { IGGallery.fromJSON($0) }
        }
        return nil
    }
    
    private func saveGalleriesToUserDefaults() {
        UserDefaults.standard.set(galleries.compactMap { $0.json }, forKey: galleriesUserDefaultsKey)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return removedGalleries.isEmpty ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Active Galleries"
        case 1: return "Recently Removed"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return activeGalleries.count
        case 1: return removedGalleries.count
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        if let cell = cell as? EditableTableViewCell {
            switch indexPath.section {
            case 0:
                let gallery = activeGalleries[indexPath.row]
                cell.galleryName?.text = gallery.name
                cell.editHandler = { [weak self, unowned gallery] in
                    if let newName = cell.galleryName.text {
                        gallery.name = newName
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        self?.selectRow(at: indexPath, withInterval: 0.6)
                    }
                }
            case 1:
                cell.galleryName?.text = removedGalleries[indexPath.row].name
            default: break
            }
        }
        return cell
    }

    private var selectedRowIndexPath: IndexPath?
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                let gallery = activeGalleries[indexPath.row]
                gallery.remove()
                if removedGalleries.count == 1 {
                    tableView.reloadData()
                } else {
                    let destinationIndexPath = IndexPath(row: removedGalleries.firstIndex { $0 === gallery } ?? 0, section: 1)
                    tableView.moveRow(at: indexPath, to: destinationIndexPath)
                }
                if selectedRowIndexPath == indexPath && indexPath.row > 0 {
                    selectRow(at: IndexPath(row: indexPath.row - 1, section: indexPath.section), withInterval: 1)
                }
            case 1:
                let gallery = removedGalleries[indexPath.row]
                galleries.removeAll { $0 === gallery }
                if self.removedGalleries.isEmpty {
                    tableView.reloadData()
                } else {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            default: return
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            return UISwipeActionsConfiguration(actions: [
                UIContextualAction(style: .normal, title: "Restore", handler: { _,_,completion in
                    let gallery = self.removedGalleries[indexPath.row]
                    gallery.restore()
                    let destinationIndexPath = IndexPath(row: self.activeGalleries.firstIndex { $0 === gallery } ?? 0, section: 0)
                    if self.removedGalleries.isEmpty {
                        tableView.reloadData()
                    } else {
                        tableView.moveRow(at: indexPath, to: destinationIndexPath)
                    }
                    self.selectRow(at: destinationIndexPath, withInterval: 1)
                    completion(true)
                })
            ])
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowIndexPath = indexPath
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == gallerySegueIdentifier {
            if let collectionView = segue.destination.contents as? ImageGalleryCollectionViewController {
                if let cell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: cell) {
                    let gallery = activeGalleries[indexPath.row]
                    collectionView.gallery = gallery
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            return indexPath.section == 0
        }
        return true
    }
    
    // MARK: - Constant Values
    
    private let cellReuseIdentifier = "GalleryCell"
    private let gallerySegueIdentifier = "ShowGallery"
    private let galleriesUserDefaultsKey = "ImageGalleries"

}
