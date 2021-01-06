//
//  ViewController.swift
//  TodoList_14
//
//  Created by Mathieu on 19/12/2020.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    //MARK:- Properties
    
    /*
     Create a result container as Results<Item> data type because we need this data type in Realm to load our data.
     Results is an auto-updating container type in Realm returned from object queries.
     Results<Item> should be an optional data type
     
     */
    var todoItems: Results<Item>? 
    
    /*
     It's an optional data type because it's going to be nil until it will be set thank to categoriesArray[indexPath.row] in CategoryTableViewController file.
     */
    var selectedCategory: Category?
    
    /*
     Create realm as a Realm instance (also referred to as “a Realm”) represents a Realm database.
     This initialization can throw an error it's because according to Realm, first time when you create a  Realm new instance, it can fail if our ressources are constraintes.
     It could happen only once an instance is created on a given thread
     */
    let realm = try! Realm()
    
    
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        // Allow multiple selection of the tableview
        tableView.allowsMultipleSelection = true
        
        // We absolutely need to load the items from the Realm Database in the viewDidLoad()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemButtonPressed(sender:)))
        
        // Set the add button to white color
        navigationItem.rightBarButtonItem?.tintColor = .white
        
    }
    
    
    //MARK:- Realm Load
    
    /*
     To read the data from PersistentStore, we have to create request that is NSFetchRequest<Item> data type which allows to fetch the request of the Item.
     Item is the type of result that the request will return because it's between NSFetchRequest's chevron
     Get the class/entity Item and ask a new fetchrequest
     let request: NSFetchRequest<Item> = Item.fetchRequest()
     We provide a default value to our parameter request: Item.fetchRequest()
     Add predicate parameter to avoid conflict with differents predicates and set it to nil like that, we do not have to provide any parameter when we call loadItems(). But to set it to nil we have to give an optional NSPredicate? because Nil default argument value cannot be converted to type 'NSPredicate'.
     */
    func loadItems(){
        
        /*
         All the items that belong to selectedCategory are sorted by keypath title and are ascending
         */
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        /*
         ReloadData() call all datasource methods
         
         We need to reloadData of the tableview because the view is loaded before items are sorted, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes
         */
        tableView.reloadData()
        
    }
    
    
    //MARK:- TableView Delegate Methods
    
    // Did Select row at indexpath tells the delegate a row is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /* Here we gona UPDATE data from Realm */
        
        /*
         todoItems is a container of items fetched from Realm. So item its the todoItems grab in the current selected row then check if it's not nil like that we are able to access to this item object
         todoItems is optional cause selectedCategory is optional too.
         */
        if let item = todoItems?[indexPath.row] {
            do {
                
                // Commit the item done property in Realm database with realm.write
                try realm.write{
                    
                    // This single line replace the if condition, it's a toggle checkmark. They can only have two stats true or false then if we set true it becomes false cause the opposite, and if it's set to false it becomes true.
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
            
        }
        
        /*
         ReloadData() call all datasource methods
         
         We need to reloadData of the tableview because the view is loaded before done property change, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes.
         This method call CellForRowAt indexPath method to update our cells based on this done property.
         */
        tableView.reloadData()
        
    }
    
    //MARK:- TableView Datasource Methods
    
    // Define the number of Rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        /*
         Define the number of Rows in section
         We have to use Nil Coalescing Operator
         As the todoItems is an optional data type and if todoItems?.count = nil we must return a default value as 1
         */
        return todoItems?.count ?? 1
    }
    
    // Define the cell for row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create cell as an instance of TodoListViewCell with the identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TodoListController.todoListReuseIdentifierCell, for: indexPath)
        
        /*
         todoItems is a container of items fetched from Realm. So item its the todoItems grab in the current selected row then check if it's not nil like that we are able to access to this item object
         todoItems is optional cause selectedCategory is optional too.
         */
        if let item = todoItems?[indexPath.row] {
            
            // Set the text of contentLabel as the text in the todoItems from TodoListViewCell
            //        cell.contentLabel.text = item.title
            
            // TextLabel is the label to use for the main textual content of the table cell.
            cell.textLabel?.text = item.title
            
            /*
             Ternary operator == >
             value = condtion ? valueIsTrue : valueIsFalse
             cell.accessoryType is the value, item.done == true is the condition, then if it's true cell.accessoryType = .checkmark otherwise cell.accessoryType = .none
             */
            cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            cell.textLabel?.text = "No item added yet"
        }
        
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
        
        /* Here we gona DELETE data from Realm */
        
        /*
         todoItems is a container of items fetched from Realm. So item its the todoItems grab in the current selected row then check if it's not nil like that we are able to access to this item object
         todoItems is optional cause selectedCategory is optional too.
         */
        if let item = todoItems?[indexPath.row] {
            
            do {
                
                // realm.write allows to commit the changes in Realm database 
                try realm.write{
                    
                    // .delete(_ object: ObjectBase) method deletes an object from the Realm. Once the object is deleted it is considered invalidated.
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item from Realm, \(error)")
            }
        }
        
        /*
         ReloadData() call all datasource methods
         
         We need to reloadData of the tableview because the view is loaded before items are deleted, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes.
         This method call CellForRowAt indexPath method to update our cells based on this done property.
         */
        tableView.reloadData()
        
    }
    
    //MARK:- Add new item
    
    // Create a function similar to a @IBAction linked to the add UIBarButtonItem
    
    @objc func addItemButtonPressed(sender: UIBarButtonItem) {
        
        // Create a local variable textField inside the @IBAction to the alertTextField in the closure be accessible inside the @IBAction
        var textField: UITextField = UITextField()
        
        // Create an alert
        let alert: UIAlertController = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        // Create an action as done button. It's the completion code when the Add Item button get pressed
        let saveAction: UIAlertAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //MARK:- Realm Save

            /* Here we gona CREATE and SAVE data to Realm */
            
            // To save items in the selectedCategory we are checking if selectedCategory is nil or not
            guard let currentCategory = self.selectedCategory else {return}
            
            do {
                
                /*
                 realm.write allows to commit the changes in Realm database.
                 write property performs actions contained within the given block inside a write transaction.
                 .add()' method adds an unmanaged object to this Realm.
                 It's a throw method so use the do try catch
                 */
                try self.realm.write{
                    // As we use Realm in order to save and create item
                    let newItem = Item()
                    
                    // Set the name of newCategory as textField.text without whitespaces but it's an optional String then use gard let
                    guard let text = textField.text?.trimmingCharacters(in: .whitespaces) else {return}
                    
                    newItem.title = text
                    
                    // Every instance we create get stamp with the current date and time
                    newItem.dateCreated = Date()
                    
                    /*
                     items are the List<Item>
                     .append(object:) method appends the given object to the end of the list.
                     */
                    currentCategory.items.append(newItem)
                }
                
            } catch {
                
                print("Error saving Category to context, \(error) ")
            }
            
            /*
             ReloadData() call all datasource methods
             
             We need to reloadData of the tableview because the view is loaded before items are added to Realm, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes
             */
            self.tableView.reloadData()
            
        }
        
        // The user can not click on saveAction button because it's desabled
        saveAction.isEnabled = false
        
        // Create an action as cancel button with cancel style
        let cancelAlertAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add a text field to the alert
        alert.addTextField { (alertTextField) in
            
            // Add a placeholder in the text field
            alertTextField.placeholder = "Create a new category"
            
            // Extending the scope of the alertTextField by storing the reference of alertTexField to the local variable textField
            textField = alertTextField
        }
        
        // Adding the notification observer here to udpate any text changes and allow to click or not on the button
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alert.textFields?[0], queue: OperationQueue.main) { (notification) in
            
            // Use guard let to avoid to force unwrapp the UITextfield data type
            guard let textFieldCategory = alert.textFields?[0] else {return}
            
            /*
             Conditions allow to avoid a textField equal nil or empty
             Check for the empty Field and avoid the trim as last character
             If it's empty, the user can not click on the button cause it should be disabled
             */
            saveAction.isEnabled = !((textFieldCategory.text?.isEmpty ?? true) || textFieldCategory.text?.last == " ")
            
        }
        
        // Add an action button action named Cancel
        alert.addAction(cancelAlertAction)
        
        // Add an action button named Add Item
        alert.addAction(saveAction)
        
        // The add(sender:) presents the alert with an animation
        self.present(alert, animated: true)
        
    }
    
}

//MARK:- Search Bar Delegate Methods

/* Here we gona QUERY data from Realm */


// Add UISearchBarDelegate protocol to use search bar functions
extension TodoListViewController: UISearchBarDelegate {
    
    // SearchBarDelegate method telling the delegate that the search button was tapped by click on enter
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        /*
         In order to query the Realm Database, have to use NSPredicate(format: ,)
         In the format by using "title CONTAINS %@" we are looking for the attribut title of each item and checking that it contains a value
         [cd] string comparaisons are set as case and diacritic insensitive.
         The value is the arguments that we are looking for and will replace %@ to have "title CONTAINS searchBarText
         Using guard let to avoid force unwrapping text
         Add predicate argument to .filter() method which looking for NSPredicate
         */
        guard let searchBarText = searchBar.text else {return}
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBarText)
        
        /*
         Set todoItems to its previous value todoItems.filter() and sort it by .sorted() method
         As we want on top the most recent item, set the ascending as true
         */
        todoItems = todoItems?.filter(predicate).sorted(byKeyPath: "dateCreated", ascending: true)
        
        /*
         ReloadData() call all datasource methods
         
         We need to reloadData of the tableview because the view is loaded before using predicate and .sorted(), so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes.
         */
        tableView.reloadData()
        
        /*
         We do not need to use loadItems() because we've already loaded todoItems from selectedCategory in func loadItems().
         Here we simply filter this items
         */
        
        
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
            
        } else {
            
            // Each time we modify the text in the searchBar, the items are updated
            
            guard let searchBarText = searchBar.text else {return}
            
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBarText)
            
            todoItems = todoItems?.filter(predicate).sorted(byKeyPath: "dateCreated", ascending: true)
            
            tableView.reloadData()
        }
        
    }
    
}
