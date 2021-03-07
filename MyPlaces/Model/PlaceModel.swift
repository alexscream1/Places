//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Alexey Onoprienko on 04.03.2021.
//

import RealmSwift


class PlaceModel: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var country: String?
    @objc dynamic var location: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating: Double = 0

    
    
    convenience init(name: String, country: String?, city: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.country = country
        self.location = city
        self.imageData = imageData
        self.rating = rating
    }
}
