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
     It's an optional data type because it's going to be nil until it will be set thank to categoriesArray[indexPath.row] in CategoryTableViewController file.
    */
    var selectedCategory: Category?
    
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
     
     let dataFilePath: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(Constants.FileManager.itemsFilePath)
     */
    
    
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        // Allow multiple selection of the tableview
        tableView.allowsMultipleSelection = true
        
        // Load the items from the persistentStore in the viewDidLoad()
        loadItems()
        
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
    
    //MARK:- CoreData Save
    
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
    
    //MARK:- CoreData Load
    
    /*
     To read the data from PersistentStore, we have to create request that is NSFetchRequest<Item> data type which allows to fetch the request of the Item.
     Item is the type of result that the request will return because it's between NSFetchRequest's chevron
     Get the class/entity Item and ask a new fetchrequest
     let request: NSFetchRequest<Item> = Item.fetchRequest()
     We provide a default value to our parameter request: Item.fetchRequest()
     Add predicate parameter to avoid conflict with differents predicates and set it to nil like that, we do not have to provide any parameter when we call loadItems(). But to set it to nil we have to give an optional NSPredicate? because Nil default argument value cannot be converted to type 'NSPredicate'.
    */
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        
        /*
         We don't want anymore all items from the persistent Store but items from a specific category
         In order to query the NSPersistentStore, have to use NSPredicate(format: ,)
         In the format by using "parentCategory.name MATCHES %@" we are looking for the attribut name from parentCategory and checking that it matchs with a value
         The value is the arguments that we are looking for and will replace %@ to have "parentCategory.name MATCHS selectedCategory
        */
        
        // Using guard let to avoid force unwrapping selectedCategory.name
        guard let argSelectedCategory = selectedCategory, let argSelectedCategoryName = argSelectedCategory.name else {return}

        let categoryPredicate: NSPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", argSelectedCategoryName)
        
        
        /*
         We need to use this specialized predicate, NSCompoundPredicate, to evaluate logical combinations of other predicates.
         andPredicateWithSubpredicates returns a new predicate formed by categoryPredicates and predicate, the predicates in a given array
         We just have to make sure that we create a compoundPredicate using as many predicates we need as well the one we passed through the argument
        */
        
        /*
         Using if let to avoid force unwrapping predicate cause we set NSPredicate? as optional in the parameter
         Never use guard let when the optional data type is in function parameter because if we do it, this condition will never be called
        */
        if let safePredicate = predicate {

            // Assign predicate property of request as the predicate
            request.predicate = safePredicate
            
            let compoundPredicate: NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, safePredicate])

            // Assign predicate property of request as the compoundPredicate
            request.predicate = compoundPredicate

        }

        
        do {
            /*
             Absolutely need the context to fetch the request from the persistent Store.
             The method .fetch(request) returns an array of objects that meet the criteria specified by a given fetch request.
             So we have to assign try context.fetch(request) to the itemsArray
             */
            itemsArray = try context.fetch(request)
            
        } catch {
            
            print("Error fetching data from context \(error)")
            
        }
        
        // We need to reloadData of the tableview because the view is loaded before done property change, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes
        tableView.reloadData()

    }
    
    
    //MARK:- TableView Delegate Methods
    
    // Did Select row at indexpath tells the delegate a row is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // This single line replace the if condition, it's a toggle checkmark. They can only have two stats true or false then if we set true it becomes false cause the opposite, and if it's set to false it becomes true.
        itemsArray[indexPath.row].done = !itemsArray[indexPath.row].done
        
        // Save the item done property in NSPersistentContainer
        saveItems()
        
    }
    
    //MARK:- TableView Datasource Methods
    
    // Define the number of Rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // The number of item in itemsArray to set the number of rows
        return itemsArray.count
    }
    
    // Define the cell for row
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
    
    // Datasource method asking the data source to verify that the given row is editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Datasource method asking the data source to commit the insertion or deletion of a specified row in the receiver.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        // Specifies an object that should be removed from its persistent store when changes are committed
        context.delete(itemsArray[indexPath.row])
        
        // Removes and returns the element at the specified position
        itemsArray.remove(at: indexPath.row)
        
        // Must to save the delete from context to delete in Persistent Store
        saveItems()
    }
    
    //MARK:- Add new item
    
    // Create a function similar to a @IBAction linked to the add UIBarButtonItem
    
    @objc func addButtonPressed(sender: UIBarButtonItem) {
        
        // Create a local variable textField inside the @IBAction to the alertTextField in the closure be accessible inside the @IBAction
        var textField: UITextField = UITextField()
        
        // Create an alert
        let alert: UIAlertController = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        // Create an action as cancel button with cancel style
        let cancelAlertAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
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
            if (textField.text?.isEmpty ?? true || textField.text == " ") {
                                
                // If it's empty, create an alert explain the issue
                let emptyTextAlertController: UIAlertController = UIAlertController(title: "Error Empty Field", message: "You should write something or cancel", preferredStyle: .alert)
                
                // Create a try Again button
                let tryAgainAlertAction: UIAlertAction = UIAlertAction(title: "Try again", style: .default) { (action) in
                    
                    // When tryAgain button is clicked, present the first alert showing the textField
                    self.present(alert, animated: true, completion: nil)
                }
                
                // Add this tryAgain button to the alertEmpty
                emptyTextAlertController.addAction(tryAgainAlertAction)
                
                // Add an action button action named Cancel
                emptyTextAlertController.addAction(cancelAlertAction)
                
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
                
                // Set the parentCategory, which is the relationship between Item and Category, to the selectedCategory created/didset in TodoListViewController file and set in CategoryTableViewController file
//                newItem.parentCategory = self.selectedCategory
                
                // Etablir une relation
                self.selectedCategory?.addToItems(newItem)
                
                // Now we can push the newItem instance of Item containing the textField.text in title.
                self.itemsArray.append(newItem)
                
                // Save the item title in NSPersistentContainer
                self.saveItems()
            }
        }
        
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

//MARK:- Search Bar Delegate Methods

// Add UISearchBarDelegate protocol to use search bar functions
extension TodoListViewController: UISearchBarDelegate {
        
    // SearchBarDelegate method telling the delegate that the search button was tapped by click on enter
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // To read the data from PersistentStore, we have to create request that is NSFetchRequest<Item> data type which allows to fetch the request of the Item.
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        /*
         In order to query the NSPersistentStore, have to use NSPredicate(format: ,)
         In the format by using "title CONTAINS %@" we are looking for the attribut title of each item and checking that it contains a value
         [cd] string comparaisons are set as case and diacritic insensitive.
         The value is the arguments that we are looking for and will replace %@ to have "title CONTAINS searchBarText
         Using guard let to avoid force unwrapping text
         Assign predicate property of request as the predicate defined above
        */
        guard let searchBarText = searchBar.text else {return}

        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBarText)
        
        request.predicate = predicate
        
        /*
         Sort the data when it get back from the database and sort using the key as the "title" which is a property common to all the objects.
         Assign sortDescriptors (actually plurial because it expects an array) property of request as an array of sortDescriptor defined above
         */
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        /*
         Now we need to fetch the request
         Absolutely need the context to fetch the request from the persistent Store.
         The method .fetch(request) returns an array of objects that respect predicate and sortDescriptors
         We need to reloadData of the tableview because the view is loaded before done property change, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes
         Everything is done inside func loadItems()
       */
        
        loadItems(with: request)

    }
    
    // SearchBarDelegate method telling the delegate that the user change the search text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchBarText = searchBar.text else {return}
        
        // Check if searchBar is empty equal to if we click on the cross button to delete the text in the searchBar
        if (searchBarText.count == 0) {
            loadItems()
            
            /*
             It manages the execution of tasks serially or concurrently on our app's main thread or on a background thread.
             It's associated with the main thread of the current process.
             We ask the DispatchQueue to get the main key then run this method on the foreground.
             */
            DispatchQueue.main.async {
                /*
                 Notifies the searchBar is not anymore the first Responder.
                 By using DispatchQueue and resignFirstResponder we get the keyboard pops away and cursor disappear, all because of searchBar.resignFirstResponder() is being run in the foreground
                */
                searchBar.resignFirstResponder()
            }
            
        }
            
    }

}
