//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Alexey Onoprienko on 05.03.2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: PlaceModel) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: PlaceModel) {
        try! realm.write {
            realm.delete(place)
        }
    }
    
}
