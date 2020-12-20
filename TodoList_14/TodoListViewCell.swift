//
//  TodoListViewCell.swift
//  TodoList_14
//
//  Created by Mathieu on 19/12/2020.
//

import UIKit

class TodoListViewCell: UITableViewCell {
    
    //MARK:- Properties
    
    // Define the reuseIdentifier of the tableviewcell
    static let reuseIdentifier: String = "TodoListViewCell"
    
    @IBOutlet weak var contentLabel: UILabel!
    
    //MARK:- Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set the number of lines to 0 like that the size of the label will change with the size of the label
        contentLabel.numberOfLines = 0
        
        // Set the text of the contentLabel to empty string
        contentLabel.text = " "
    }
}
