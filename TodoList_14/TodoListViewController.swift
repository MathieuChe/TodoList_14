//
//  ViewController.swift
//  TodoList_14
//
//  Created by Mathieu on 19/12/2020.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    
    //MARK:- Properties

    // If we need to append some string in the itemArray, we have to use var
    private var itemArray: [String] = ["find Mike", "find Mathieu", "find Swann", "find Raymonde"]
    
    // To store the userDefault key
    private var forKeyString: String = "TodoListArray"
    
    // Persistence data base: Create an interface to the user’s defaults database, where you store key-value pairs persistently across launches of your app.
    let userDefault: NSObject = UserDefaults.standard
    
    //MARK:- Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the itemArray to userDefault value for the property identified by a given key "TodoListArray as an array of string. But we need to prevent the case our itemArray is not empty cause if it is, the app will crash by using guard let else {return}
        guard let items = userDefault.value(forKey: forKeyString) as? [String] else {return}
        
        // Then set the value of items to itemArray
        itemArray = items
        
        setUpNavigationDisplay()
        
        // Allow multiple selection of the tableview
        tableView.allowsMultipleSelection = true
        
        view.insetsLayoutMarginsFromSafeArea = false
//        view.translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    
    //MARK:- Navigation

    func setUpNavigationDisplay() {
                
        // Set the title of the navigation item
        navigationItem.title = "TodoList"
        
        // Set the title Tint Color of the navigationController
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        // Set the bar Tint of the navigationController
        navigationController?.navigationBar.barTintColor = .init(red: 0.8, green: 0.5, blue: 0.5, alpha: 0.6)
    
        // Allow to customize a bar button item that displays on the right. UIBarButtonItem is a specialized button for placement on a toolbar or tab bar, in our example it's an add button
        // The target is the item itself and the selector is the add(sender:) from the @objc func add(sender: UIBarButtonItem) {} created
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(sender:)))
        
        // Set the add button to white color
        navigationItem.rightBarButtonItem?.tintColor = .white
        
    }

    //MARK:- TableView Delegate Methods
    
    // Did Select row at indexpath tells the delegate a row is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselects a given row identified by index path with deselection' animated.
        tableView.deselectRow(at: indexPath, animated: true)
        
        // cellForRow returns the table cell at the specified index path.
        if let cell = tableView.cellForRow(at: indexPath) {
            
            // If accessoryType is set to checkmark then
            if cell.accessoryType == .checkmark {
                
                // Remove the checkmark by setting the accessory type of cell to none
                cell.accessoryType = .none
                    
            } else {
                
                // Add a checkmark by setting the accessory type of cell to checkmark
                cell.accessoryType = .checkmark
            }
        }
    }
    
    
    //MARK:- TableView Datasource Methods
    
    // Define the number of Rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // The number of items in itemArray to set the number of rows
        return itemArray.count
    }
    
    // Define the cell for raw
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create cell as an instance of TodoListViewCell with the identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoListViewCell.reuseIdentifier, for: indexPath) as! TodoListViewCell
        
        // Set the text of contentLabel as the text in the itemArray from TodoListViewCell
//        cell.contentLabel.text = itemArray[indexPath.row]
        
        // TextLabel is the label to use for the main textual content of the table cell.
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    //MARK:- Add new items
    
    // Create a function similar to a @IBAction linked to the add UIBarButtonItem
    
    @objc func addButtonPressed(sender: UIBarButtonItem) {
        
        // Create a local variable textField inside the @IBAction to the alertTextField in the closure be accessible inside the @IBAction
        var textField: UITextField = UITextField()
        
        // Create an alert
        let alert: UIAlertController = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        // Create an action as done button. It's the completion code when the Add Item button get pressed
        let doneAction: UIAlertAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // What will happen once the user clicks the Add Item button on the UIAlert
            
            // Conditions allow to avoid a textField equal nil or empty
            if (textField.text == nil || textField.text == "") {
                
                print("You should add something")
                
                // If it's empty, create an alert explain the issue
                let alertEmpty: UIAlertController = UIAlertController(title: "Error", message: "You should write something or cancel", preferredStyle: .alert)
                
                // Create a try Again button
                let tryAgainAction: UIAlertAction = UIAlertAction(title: "Try again", style: .default) { (action) in
                    
                    // When tryAgain button is clicked, present the first alert showing the textField
                    self.present(alert, animated: true, completion: nil)
                }
                
                // Add this tryAgain button to the alertEmpty
                alertEmpty.addAction(tryAgainAction)
                
                // Show this alertEmpty
                self.present(alertEmpty, animated: true, completion: nil)
                
            } else {
            
            // Can push the text from the alertTexfield by using the local variable textField in the itemArray. We can force it because the textField.text will never be equal to nil
                self.itemArray.append(textField.text!)
                
                // Sets the property of the receiver specified by a given key forKeyString as "TodoListArray" to a given value "itemArray"
                self.userDefault.setValue(self.itemArray, forKey: self.forKeyString)
            
            // Reload the rows and sections of the table view to show immediately the new item
            self.tableView.reloadData()
                
            }
        }
        
        // Create an action as cancel button with cancel style
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add a text field to the alert
        alert.addTextField { (alertTextField) in
            
            // Add a placeholder in the text field
            alertTextField.placeholder = "Create a new item"
            
            // Extending the scope of the alertTextField by storing the reference of alertTexField to the local variable textField
            textField = alertTextField
        }
        
        // Add an action button named Add Item
        alert.addAction(doneAction)
        
        // Add an action button action named Cancel
        alert.addAction(cancelAction)
        
        // The add(sender:) presents the alert with an animation
        self.present(alert, animated: true)
    }

}

