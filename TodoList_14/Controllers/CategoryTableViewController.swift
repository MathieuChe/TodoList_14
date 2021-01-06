//
//  CategoryTableViewController.swift
//  TodoList_14
//
//  Created by Mathieu on 30/12/2020.
//

import UIKit
import RealmSwift

class CategoryTableViewController: UITableViewController {
    
    //MARK:- Properties
    
    /*
     Initialization of new access point to Realm Database
     
     Create realm as a Realm instance (also referred to as “a Realm”) represents a Realm database.
     This initialization can throw an error it's because according to Realm, first time when you create a  Realm new instance, it can fail if our ressources are constraintes.
     It could happen only once an instance is created on a given thread.
     */
    let realm = try! Realm()
    
    /*
     Create categoriesArray as Results<Category> data type because we need this data type in Realm to load our data.
     Results is an auto-updating container type in Realm returned from object queries.
     Results<Category> should be an optional data type allowing us to be safe
     */
    var categoriesArray: Results<Category>?
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupNavigationBar()
        
        // Load the categories from the Realm Database in the viewDidLoad()
        loadCategories()
        
    }
    
    //MARK:- Navigation
    
    func setupNavigationBar(){
        
        // Set the title of the navigation Category
        navigationItem.title = "Category"
        
        // Set the title Tint Color of the navigationController
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        // Set the bar Tint of the navigationController
        navigationController?.navigationBar.barTintColor = Constants.FileManager.itemsColorNavBar
        
        /*
         Allow to customize a bar button item that displays on the right. UIBarButtonItem is a specialized button for placement on a toolbar or tab bar, in our example it's an add button
         The target is the item itself and the selector is the add(sender:) from the @objc func add(sender: UIBarButtonItem) {} created
         */
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategoryButtonPressed(sender:)))
        
        // Set the add button to white color
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    //MARK:- Add Button
    
    @objc func addCategoryButtonPressed(sender: UIBarButtonItem){
        
        // Create a local variable textField inside the @IBAction to the alertTextField in the closure be accessible inside the @IBAction
        var textField: UITextField = UITextField()
        
        // Create an alert
        let alert: UIAlertController = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        // Create an action as done button. It's the completion code when the Add Item button get pressed
        let saveAction: UIAlertAction = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            // As we use Realm in order to save and create category, our newCategory is an instance of Category
            let newCategory: Category = Category()
            
            // Set the name of newCategory as textField.text without whitespaces but it's an optional String then use gard let
            guard let text = textField.text?.trimmingCharacters(in: .whitespaces) else {return}
            
            newCategory.name = text
            
            /* We do not need anymore to append things: self.categoriesArray.append(newCategory), it will simply auto-update and monitor for its changes. */
            
            // Save the category name in Realm
            self.save(category: newCategory)
            
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
    
    
    //MARK:- UITableView Datasource methods
    
    // Define the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     Define the number of Rows in section
     We have to use Nil Coalescing Operator
     As the categoriesArray is an optional data type and if categoriesArray?.count = nil we must return a default value as 1
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray?.count ?? 1
    }
    
    // Define the cell for row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create cell as an instance of CategoryTableViewCell with the identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CategoryController.categoryReuseIdentifierCell, for: indexPath)
        
        /*
         TextLabel is the label to use for the main textual content of the table cell.
         We have to use Nil Coalescing Operator and if nil set the default value as a string message 
         */
        cell.textLabel?.text = categoriesArray?[indexPath.row].name ?? "No category added yet"
        
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
        
        if let currentCategory = categoriesArray?[indexPath.row] {
            
            do {
                
                // realm.write allows to commit the changes in Realm database
                try realm.write{
                    
                    // .delete(_ object: ObjectBase) method deletes an object from the Realm. Once the object is deleted it is considered invalidated.
                    realm.delete(currentCategory)
                }
            } catch {
                print("Error deleting Category from Realm, \(error)")
            }
        }
        
        /*
         ReloadData() call all datasource methods
         
         We need to reloadData of the tableview because the view is loaded before category is deleted, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes
         */
        tableView.reloadData()
    }
    
    //MARK:- UITableView Delegate methods
    
    // Did Select row at indexpath tells the delegate a row is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Method that initiates the segue with "CategoryTableViewController" identifier from the current view controller's storyboard file.
        performSegue(withIdentifier: Constants.CategoryController.categoryToItemsSegue, sender: self)
        
    }
    
    /* Prepare the segue cause we only want to perform the segue from a specific category to its items */
    
    // prepare method notifies the view controller that a segue is about to be performed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {return}
        
        // Switch case is really useful for various identifier
        switch identifier {
        
        case Constants.CategoryController.categoryToItemsSegue:
            
            // Define the destination view controller for the segue
            guard let destinationViewController = segue.destination as? TodoListViewController else {return}
            
            /*
             This property index path identifying the current row and section of the selected row
             The indexPath is optional because there is no selected row at this moment
             */
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            
            /*
             /!\ Really important to send informations from one view to another one
             After creating our selectedCategory property we assign the value of categoriesArray at the indexPath.row
             We had to didSet{} selectedCategory with loadItems() in TodoListViewController file
             We do not need to use a Nil Coalescing Operator because selectedCategory is already an optional Category data type in TodoListViewController file
             selectedCategory get also Category properties as name and items
             */
            destinationViewController.selectedCategory = categoriesArray?[indexPath.row]
            
        default:
            break
        }
    }
    
    //MARK:- Data Manipulation methods
    
    //MARK:- Realm Save
    
    /* Here we gona SAVE data from Realm */
    
    // Add category parameter as Category data type in the saveCategories function
    func save(category: Category){
        
        do {
            
            /*
             realm.write allows to commit the changes in Realm database
             write property performs actions contained within the given block inside a write transaction.
             .add()' method adds an unmanaged object to this Realm.
             It's a throw method so use the do try catch
             */
            try realm.write{
                
                realm.add(category)
            }
            
        } catch {
            
            print("Error saving Category to context, \(error) ")
        }
        
        /*
         ReloadData() call all datasource methods
         
         We need to reloadData of the tableview because the view is loaded before category is added to Realm, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes
         */
        tableView.reloadData()
    }
    
    //MARK:- Realm Load
    
    /* Here we gona LOAD data from Realm */
    
    func loadCategories(){
        
        /*
         To read the data from Realm database, we have to assign realm.objects(Category.self) to categoriesArray.
         realm.objects(_ type: Element.Type) returns all objects of the given type stored in the Realm.
         For the type of the class we still need to add .self after the class.
         This will pull out all of the items inside our realm that are a category object.
         As realm.objects(_ type: Element.Type) should returns a Results<Element> data type we have to define categoriesArray as Results<Category> data type
         */
        categoriesArray = realm.objects(Category.self)
        
        
        /*
         ReloadData() call all datasource methods
         
         We need to reloadData of the tableview to load the view after using .objects() method, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes
         */
        tableView.reloadData()
    }
    
}
