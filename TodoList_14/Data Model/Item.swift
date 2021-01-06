//
//  Item.swift
//  TodoList_14
//
//  Created by Mathieu on 04/01/2021.
//

import Foundation
import RealmSwift

// By subclassing this Object class, we are able to save our data using Realm
class Item: Object {
    
    // We can specify what properties should it have by using @objc dynamic before the variable
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    
    // Set the Date as optional
    @objc dynamic var dateCreated: Date?
    
    /*
                                Inverse Relationship 
     
     LinkingObjects is an auto-updating container type. It represents zero or more objects that are linked to its owning model object through a property relationship.
     It's simply defining the inverse relationship of items.
     For each category has one-to-many relationship with a list of items and each items have an inverse relationship to a category called parentCategory.
     fromType need a type not a class then add .self to get the data. Category.self
     property wait for the name of the relationship in String. It's items from Category file
     */
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
