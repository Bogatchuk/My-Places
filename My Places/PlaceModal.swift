//
//  PlaceModal.swift
//  My Places
//
//  Created by Roma Bogatchuk on 27.09.2022.
//

import Foundation

struct Place {
    var name: String
    var location: String
    var type: String
    var image: String
    
    static var restaurantNames = ["Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
                           "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
                           "Speak Easy", "Morris Pub", "Вкусные истории",
                           "Классик", "Love&Life", "Шок", "Бочка"
                       ]
    
   static func getPlaces() -> [Place] {
        var places = [Place]()
        for place in restaurantNames {
            places.append(Place(name: place, location: "Киев", type: "Ресторан", image: place))
        }
       return places
    }
}