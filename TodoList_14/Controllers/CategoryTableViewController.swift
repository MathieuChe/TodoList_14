//
//  CategoryTableViewController.swift
//  TodoList_14
//
//  Created by Mathieu on 30/12/2020.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    //MARK:- Properties

    // Create categoriesArray an Array instance of type Category
    var categoriesArray: [Category] = [Category]()
    
    /*
     In order to get the context from Class AppDelegate we can not just use it as a Class like
     AppDelegate.persistenteContainer.viewContext,
     We start by using the UIApplication class.
     The shared of UIApplication will correspond to the current App as an object. It returns the  singleton app instance of application.
     The delegate is one of the App Object which have the data type of UIApplicationDelegate so we have to downcast UIApplicationDelegate as AppDelegate because both inherite same super class UIApplicationDelegate.
     Now we have access to our AppDelegate as an object then get persistentContainer property and its viewContext
     */
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK:- Life Cycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupNavigationBar()
        
        // Load the categories from the persistentStore in the viewDidLoad()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(sender:)))
        
        // Set the add button to white color
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    //MARK:- Add Button
    
    @objc func addButtonPressed(sender: UIBarButtonItem){
        
        // Create a local variable textField inside the @IBAction to the alertTextField in the closure be accessible inside the @IBAction
        var textField: UITextField = UITextField()
        
        // Create an alert
        let alert: UIAlertController = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        // Create an action as cancel button with cancel style
        let cancelAlertAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Create an action as done button. It's the completion code when the Add Item button get pressed
        let doneAction: UIAlertAction = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
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
                
                // Create an action as cancel button with cancel style for the emptyAlert because by using the same cancel alert, we have a conflict
                let cancelEmptyAlertAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                
                // Add this tryAgain button to the alertEmpty
                emptyTextAlertController.addAction(tryAgainAlertAction)
                
                // Add an action button action named Cancel
                emptyTextAlertController.addAction(cancelEmptyAlertAction)
                
                // Show this alertEmpty
                self.present(emptyTextAlertController, animated: true, completion: nil)
                
            } else {
                
                // As we use CoreData in order to save and create category, our Category is no more Category type but NSManagedObject because it comes from the DataModel by using codegen Class Definition
                let newCategory: Category = Category(context: self.context)
                
                // Set the name of newCategory as textField.text but it's an optional String then use gard let
                guard let text = textField.text else {return}
                
                newCategory.name = text
                
                // Now we can push the newCategory instance of Category containing the textField.text in name.
                self.categoriesArray.append(newCategory)
                
                // Save the category name in NSPersistentContainer
                self.saveCategories()
            }
        }
        
        // Add a text field to the alert
        alert.addTextField { (alertTextField) in
            
            // Add a placeholder in the text field
            alertTextField.placeholder = "Create a new category"
            
            // Extending the scope of the alertTextField by storing the reference of alertTexField to the local variable textField
            textField = alertTextField
        }
        
        // Add an action button action named Cancel
        alert.addAction(cancelAlertAction)
        
        // Add an action button named Add Item
        alert.addAction(doneAction)
        
        // The add(sender:) presents the alert with an animation
        self.present(alert, animated: true)
        
    }

    
    //MARK:- UITableView Datasource methods
    
    // Define the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Define the number of Rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    // Define the cell for row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create cell as an instance of CategoryTableViewCell with the identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CategoryController.categoryReuseIdentifierCell, for: indexPath)
        
        // Refactor by assigning categoriesArray[indexPath.row] to a constant
        let category = categoriesArray[indexPath.row]
        
        // TextLabel is the label to use for the main textual content of the table cell.
        cell.textLabel?.text = category.name
        
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
        context.delete(categoriesArray[indexPath.row])
        
        // Removes and returns the element at the specified position
        categoriesArray.remove(at: indexPath.row)
        
        // Must to save the delete from context to delete in Persistent Store
        saveCategories()
    }
    
    //MARK:- UITableView Delegate methods

    // Did Select row at indexpath tells the delegate a row is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselects a given row identified by index path with deselection' animated.
        tableView.deselectRow(at: indexPath, animated: true)
        
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
             After creating our selectedCategory property we assign the value of categoriesArray at the indexPath.row
             We had to didSet{} selectedCategory with loadItems() in TodoListViewController file
            */
            destinationViewController.selectedCategory = categoriesArray[indexPath.row]

        default:
            break
        }
    }
    
    //MARK:- Data Manipulation methods
    
    //MARK:- CoreData Save

    func saveCategories(){
        
        do {
            
            /*
             .save()' method of context allows to save permanently in the persistentContainer.
             This method attempts to commit unsaved changes to registered objects to the context’s parent store.
             It's a throw method so use the do try catch
             */
            try context.save()
            
        } catch {
            
            print("Error saving Category to context, \(error) ")
        }
        
        // We need to reloadData of the tableview because the view is loaded before done property change, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes
        tableView.reloadData()
    }
    
    //MARK:- CoreData Load

    /*
     To read the data from PersistentStore, we have to create request that is NSFetchRequest<Category> data type which allows to fetch the request of the Category.
     Item is the type of result that the request will return because it's between NSFetchRequest's chevron
     Get the class/entity Category and ask a new fetchrequest
     
     let request: NSFetchRequest<Category> = Category.fetchRequest()
     
     We provide a default value to our parameter request:
    */
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        
        do {
            
            /*
             Absolutely need the context to fetch the request from the persistent Store.
             The method .fetch(request) returns an array of objects that meet the criteria specified by a given fetch request.
             So we have to assign try context.fetch(request) to the itemsArray
             */
            categoriesArray = try context.fetch(request)
            
        } catch {
            
            print("Error fetching Category data from context, \(error)")
        }
        
        // We need to reloadData of the tableview because the view is loaded before done property change, so by clicking on the cell we can not see any changes. By reloading the tableview, this delegate method trigger directly and each time we do any changes
        tableView.reloadData()
    }
    
}
