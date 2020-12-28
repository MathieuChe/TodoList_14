//
//  ViewController.swift
//  TodoList_14
//
//  Created by Mathieu on 19/12/2020.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    //MARK:- Properties
        
    // Create itemsArray an Array instance of type Item
    var itemsArray: [Item] = [Item]()
    
    /*
     In order to get the context from Class AppDelegate we can not just use it as a Class like
     AppDelegate.persistenteContainer.viewContext,
     We start by using the UIApplication class.
     The shared of UIApplication will correspond to the current App as an object. It returns the  singleton app instance of application.
     The delegate is one of the App Object which have the data type of UIApplicationDelegate so we have to downcast UIApplicationDelegate as AppDelegate because both inherite same super class UIApplicationDelegate.
     Now we have access to our AppDelegate as an object then get persistentContainer property and its viewContext
    */
    let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    /*
    Path to reach documents of our App
    FileManager is a convenient interface to the contents of the file system and we get a singleton thanks to default property.
    urls return an array of URLs for documentDirectory in user’s home directory—the place to install user’s personal item
    appendingPathComponent' method creates and returns a URL constructed by appending the given path component to self. The new pathComponent gets the name Item.plist
    So it creates a new .plist document and the path to access it
    */
    let dataFilePath: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(Constants.FileManager.itemsFilePath)
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupNavigationBar()
        
        // Allow multiple selection of the tableview
        tableView.allowsMultipleSelection = true
        
        // Load the item from Item.plist in the viewDidLoad()
//        loadItems()
        
        // Cast as Any to silence the warning about expression implicitly coerced from 'URL?' to 'Any'
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    //MARK:- Navigation
    
    func setupNavigationBar() {
        
        // Set the title of the navigation item
        navigationItem.title = "TodoList"
        
        // Set the title Tint Color of the navigationController
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        // Set the bar Tint of the navigationController
        navigationController?.navigationBar.barTintColor = Constants.FileManager.itemsColorNavBar
        
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
        
        
        do {
            
            /*
             .save()' method of context allows to save permanently in the persistentContainer.
             This method attempts to commit unsaved changes to registered objects to the context’s parent store.
             It's a throw method so use the do try catch
            */
            try context.save()
            
        } catch {
            
            print("Error saving context, \(error)")
        }
        
        // We need to reloadData of the tableview because the view is loaded before done property change, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes
        self.tableView.reloadData()
        
    }
    
    //MARK:- NSCoder Load
    
//    func loadItems(){
//
//        // Use guard let to avoid forcing unwrapping
//        guard let dataFilePathGuard = dataFilePath else {return}
//
//        /*
//         Data(contentsOf:) could throw an error so we use if condtion
//         Initializer for conditional binding must have Optional type, not 'Data' then try is optional
//         Initialize a Data with the contents of an URL
//         */
//
//        if let data = try? Data(contentsOf: dataFilePathGuard){
//
//            // Create an object that decodes instances of data types FROM a property list
//            let decoder: PropertyListDecoder = PropertyListDecoder()
//
//            do {
//                /*
//                 Set itemsArray as .decode() 'method that's going to decode data from dataFilePath.
//                 Must specify the data type of Item which will be decoded because Swift is not able to do it fairly. The data type is an array of item. And because we are not specifying an object in order to refer to the data type, we have also to write self.
//                 The data is the one we create above
//                */
//
//                itemsArray = try decoder.decode([Item].self, from: data)
//
//            } catch {
//
//                print("Error decoding item array, \(error)")
//            }
//        }
//    }
    
    //MARK:- TableView Delegate Methods
    
    // Did Select row at indexpath tells the delegate a row is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // This single line replace the if condition, it's a toggle checkmark. They can only have two stats true or false then if we set true it becomes false cause the opposite, and if it's set to false it becomes true.
        itemsArray[indexPath.row].done = !itemsArray[indexPath.row].done
        
        // Save the item done property in NSPersistentContainer
        saveItems()
        
        // Deselects a given row identified by index path with deselection' animated.
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    
    //MARK:- TableView Datasource Methods
    
    // Define the number of Rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // The number of item in itemsArray to set the number of rows
        return itemsArray.count
    }
    
    // Define the cell for raw
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create cell as an instance of TodoListViewCell with the identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoListViewCell.reuseIdentifier, for: indexPath) as! TodoListViewCell
        
        // Refactor by assigning itemsArray[indexPath.row] to a constant
        let item = itemsArray[indexPath.row]
        
        // Set the text of contentLabel as the text in the itemsArray from TodoListViewCell
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
    
    // Datasource method asking the delegate for the height to use for a row in a specified location.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    //MARK:- Add new item
    
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
            
            /*
             Conditions allow to avoid a textField equal nil or empty
             Check for the empty Field
             textField.text == nil || textField.text == ""
            */
            if (textField.text?.isEmpty ?? true) {
                
                print("You should add something")
                
                // If it's empty, create an alert explain the issue
                let emptyTextAlertController: UIAlertController = UIAlertController(title: "Error Empty Field", message: "You should write something or cancel", preferredStyle: .alert)
                
                // Create a try Again button
                let tryAgainAlertAction: UIAlertAction = UIAlertAction(title: "Try again", style: .default) { (action) in
                    
                    // When tryAgain button is clicked, present the first alert showing the textField
                    self.present(alert, animated: true, completion: nil)
                }
                
                // Add this tryAgain button to the alertEmpty
                emptyTextAlertController.addAction(tryAgainAlertAction)
                
                // Show this alertEmpty
                self.present(emptyTextAlertController, animated: true, completion: nil)
                
            } else {
                
                // As we use CoreData in order to save and create item, our Item is no more Item type but NSManagedObject because it comes from the DataModel by using codegen Class Definition
                let newItem: Item = Item(context: self.context)
                
                // Set the title of newItem as textField.text but it's an optional String then use gard let
                guard let text = textField.text else {return}
                newItem.title = text
                // Set the done value to false by default because it's a required attribut
                newItem.done = false
                
                // Now we can push the newItem instance of Item containing the textField.text in title.
                self.itemsArray.append(newItem)
                
                // Save the item title in NSPersistentContainer
                self.saveItems()
            }
        }
        
        // Create an action as cancel button with cancel style
        let cancelAlertAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
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
        alert.addAction(cancelAlertAction)
        
        // The add(sender:) presents the alert with an animation
        self.present(alert, animated: true)
    }
    
}

