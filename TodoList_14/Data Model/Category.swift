//
//  Category.swift
//  TodoList_14
//
//  Created by Mathieu on 04/01/2021.
//

import Foundation
import RealmSwift

// By subclassing this Object class, we are able to save our data using Realm
class Category: Object {
    
    // We can specify what property should it have by using @objc dynamic before the variable
    @objc dynamic var name: String = ""
    
    /*
                                Relationship to-Many
     
     Use List to get a relation between two entities.
     List is the container type in Realm used to define to-many relationships.
     Need to specify the data type that the List will send back.
     Initialize List of Item by using List<Item>()
     Each category can have a number of items 
    */
    let items = List<Item>()
}
