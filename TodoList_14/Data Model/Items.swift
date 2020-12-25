//
//  Items.swift
//  TodoList_14
//
//  Created by Mathieu on 24/12/2020.
//

import UIKit

/*
Create a class to parse the title and the boolean done in order to get the checkmark to the property, not the cell and avoid some issues with the tableView
Set the type of Items as Codable because Class 'PropertyListEncoder' requires that 'Items' conform to 'Encodable' and Class 'PropertyListDecoder' requires that 'Items' conform to 'decodable'
 type Codable is a type that can convert itself into and out of an external representation.
 To be encodable and decodable, all properties of the class must have a standard data types: string, bool, array, dict but not if we have a customed class
*/
class Items: Codable {
    
    var title: String = ""
    
    var done: Bool = false
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
    
}
