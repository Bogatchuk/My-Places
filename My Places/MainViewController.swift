//
//  MainViewController.swift
//  My Places
//
//  Created by Roma Bogatchuk on 27.09.2022.
//

import UIKit

class MainViewController: UITableViewController {

    var restaurantNames = ["Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
                           "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
                           "Speak Easy", "Morris Pub", "Вкусные истории",
                           "Классик", "Love&Life", "Шок", "Бочка"
                       ]
    
    var places = Place.getPlaces()
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]
//        var configuranion = cell.defaultContentConfiguration()
//        configuranion.text = restaurantNames[indexPath.row]
//        configuranion.image = UIImage(named: restaurantNames[indexPath.row])
//        configuranion.imageProperties.cornerRadius = cell.frame.size.height / 2
//
//        cell.contentConfiguration = configuranion
     
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        
        if place.image == nil {
            cell.imageOfPlace.image = UIImage(named: place.restaurantImage!)
        } else {
            cell.imageOfPlace.image = place.image
        }
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
 
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue){
        guard let newPlaceVC = sender.source as? NewPlaceViewController else {return}
        newPlaceVC.saveNewPlace()
        places.append(newPlaceVC.newPlace!)
        tableView.reloadData()
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
