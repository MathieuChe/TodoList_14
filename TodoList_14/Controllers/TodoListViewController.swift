//
//  ViewController.swift
//  TodoList_14
//
//  Created by Mathieu on 19/12/2020.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    
    //MARK:- Properties
    
    // To store the userDefault key
    private var forKeyString: String = "TodoListDictionary"
    
    // Create itemArray an Array instance of type Items
    var itemArray: [Items] = [Items]()
    
    /*
    Path to reach documents of our App
    FileManager is a convenient interface to the contents of the file system and we get a singleton thanks to default property.
    urls return an array of URLs for documentDirectory in user’s home directory—the place to install user’s personal items
    appendingPathComponent' method creates and returns a URL constructed by appending the given path component to self. The new pathComponent gets the name Items.plist
    So it creates a new .plist document and the path to access it
    */
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setUpNavigationDisplay()
        
        // Allow multiple selection of the tableview
        tableView.allowsMultipleSelection = true
        
        // Create a new instance from class Items()
        let newItem = Items(title: "Find Mike", done: false)
        let newItem1 = Items(title: "Find Mat", done: false)
        let newItem2 = Items(title: "Find Swann", done: false)

        // Add a new item to itemArray
        itemArray.append(newItem)
        itemArray.append(newItem1)
        itemArray.append(newItem2)
        
    }
    
    //MARK:- Navigation
    
    func setUpNavigationDisplay() {
        
        // Set the title of the navigation item
        navigationItem.title = "TodoList"
        
        // Set the title Tint Color of the navigationController
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        // Set the bar Tint of the navigationController
        navigationController?.navigationBar.barTintColor = .init(red: 0.8, green: 0.5, blue: 0.5, alpha: 0.6)
        
        /*
        Allow to customize a bar button item that displays on the right. UIBarButtonItem is a specialized button for placement on a toolbar or tab bar, in our example it's an add button
        The target is the item itself and the selector is the add(sender:) from the @objc func add(sender: UIBarButtonItem) {} created
        */
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(sender:)))
        
        // Set the add button to white color
        navigationItem.rightBarButtonItem?.tintColor = .white
        
    }
    
    //MARK:- NSCoder Save
    
    func saveItems(){
        
        // Create an object that encodes instances of data types to a property list
        let encoder: PropertyListEncoder = PropertyListEncoder()
        
        /*
         encoder will encode our itemArray into a propertyList
         .encode' method could throw an error so we use a do try catch
        */
        do {
            
            // Class 'PropertyListEncoder' requires that 'Items' conform to 'Encodable' so we have to type Items to Codable
            let data = try encoder.encode(itemArray)
            
            // Now we have to write (add) data in our dataFilePath and it's also a throw' method
            try data.write(to: dataFilePath!)
            
        } catch {
            
            print("Error encoding item array, \(error)")
        }
        
        // We need to reloadData of the tableview because the view is loaded before done property change, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes
        self.tableView.reloadData()
        
    }
    
    //MARK:- TableView Delegate Methods
    
    // Did Select row at indexpath tells the delegate a row is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselects a given row identified by index path with deselection' animated.
        tableView.deselectRow(at: indexPath, animated: true)
        
        // This single line replace the if condition, it's a toggle checkmark. They can only have two stats true or false then if we set true it becomes false cause the opposite, and if it's set to false it becomes true.
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // Save the item in "Items.plist"
        saveItems()
        
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
        
        // Refactor by assigning itemArray[indexPath.row] to a constant
        let item = itemArray[indexPath.row]
        
        
        // Set the text of contentLabel as the text in the itemArray from TodoListViewCell
//        cell.contentLabel.text = item.title
        
        // TextLabel is the label to use for the main textual content of the table cell.
        cell.textLabel?.text = item.title
        
        /*
        Ternary operator == >
        value = condtion ? valueIsTrue : valueIsFalse
        cell.accessoryType is the value, item.done == true is the condition, then if it's true cell.accessoryType = .checkmark otherwise cell.accessoryType = .none
        */
        cell.accessoryType = item.done ? .checkmark : .none
                
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
            
            /*
             What will happen once the user clicks the Add Item button on the UIAlert
            */
            
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
                
                // We can't use .append method to append a textField.text in a dictionary. So we need to create an instance of Items, set the title with textField.text. We can force it because the textField.text will never be equal to nil
                let newItem: Items = Items(title: textField.text!, done: false)
                
                // Now we can push the newItem instance of Items containing the textField.text in title.
                self.itemArray.append(newItem)
                
                // Save the item in "Items.plist"
                self.saveItems()
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

