//
//  MainViewController.swift
//  My Places
//
//  Created by Roma Bogatchuk on 27.09.2022.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self)
       
        //Setup the search controller
        searchController.searchResultsUpdater = self // пулачетелем информации из поисковой строкие являеться наш класс
        searchController.obscuresBackgroundDuringPresentation = false//позволяет взаимедействовать с контентом как с основным
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController //строка поиска интегрирована в навигейшен бар
        definesPresentationContext = true // опускает строку поиска при переходе на другой экран

    }

    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
         if isFiltering {
             return filteredPlaces.count
         }
        return places.isEmpty ? 0 : places.count
    }


     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

         
        var place = Place()
        if isFiltering{
            place = filteredPlaces[indexPath.row]
        }else{
            place = places[indexPath.row]
        }

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        

        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
 

    //MARK: TableView delegate
     func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]
        let contetnItem = UIContextualAction(style: .destructive, title: "Delet") { _,_,_ in
            StorageManager.deleteObject(place)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [contetnItem])
        return swipeAction
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place: Place
            if isFiltering{
                place = filteredPlaces[indexPath.row]
            }else{
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    

    @IBAction func unwindSegue(_ sender: UIStoryboardSegue){
        
        guard let newPlaceVC = sender.source as? NewPlaceViewController else {return}
        newPlaceVC.savePlace()
        tableView.reloadData()
        
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
        
    }
    
    @IBAction func reverswdSorting(_ sender: UIBarButtonItem) {
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reversedSortingButton.image = UIImage(named: "AZ")
        } else {
            reversedSortingButton.image = UIImage(named: "ZA")
        }
        sorting()
    }
    
    private func sorting(){
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        }else{
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
        
    }
}


extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String){
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}
