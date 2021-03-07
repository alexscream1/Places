//
//  MainTableViewController.swift
//  MyPlaces
//
//  Created by Alexey Onoprienko on 03.03.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {

    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<PlaceModel>!
    private var filteredPlaces: Results<PlaceModel>!
    private var ascendingSorting = true
    private var searchBarIsEmpty : Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sortingButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Take places from Realm
        places = realm.objects(PlaceModel.self)
        
        
        // Search controller settings
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
     //MARK: - Navigation
    // Preparing for segue, when pressed on place to edit it
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPlace" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            var place = PlaceModel()
            if isFiltering {
                place = filteredPlaces[indexPath.row]
            } else {
               place = places[indexPath.row]
            }
            
            let newPlaceVC = segue.destination as! NewPlaceTableViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    
    // MARK: - Save place
    // When button "save" pressed in NewPlaceVC
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    // MARK: - Sorting
    
    @IBAction func sortingSegment(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        ascendingSorting.toggle()
        
        if ascendingSorting {
            sortingButton.image = #imageLiteral(resourceName: "down-arrow-2")
        } else {
            sortingButton.image = #imageLiteral(resourceName: "up-arrow-2")
        }
        sorting()
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        let contextItem = UIContextualAction(style: .destructive, title: "Delete", handler: {_,_,_ in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        
        let swipeAction = UISwipeActionsConfiguration(actions: [contextItem])
        
        return swipeAction
    }
    
    
    // MARK: - Table view data source

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = PlaceModel()
        
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        
        
        cell.placeNameLabel.text = place.name
        cell.countryNameLabel.text = place.country
        cell.locationNameLabel.text = place.location
        cell.starsImageView.image = UIImage(named: String(Int(place.rating)))
      
        cell.placeImageView.image = UIImage(data: place.imageData!)
        cell.placeImageView.layer.cornerRadius = cell.placeImageView.frame.size.width / 2
        cell.placeImageView.clipsToBounds = true
        
        
        return cell
    }

}
    // MARK: - Search Result Updating
extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterResultForSearch(searchController.searchBar.text!)
    }
    
    private func filterResultForSearch(_ searchText: String) {
        
        // Create filter to search by names/country/city
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR country CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText, searchText)
        
        tableView.reloadData()
    }
    
}
