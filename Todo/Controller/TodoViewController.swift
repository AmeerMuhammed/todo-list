//
//  ViewController.swift
//  Todo
//
//  Created by AmeerMuhammed on 9/13/20.
//  Copyright © 2020 AmeerMuhammed. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoViewController: SwipeTableViewController {
    
    @IBOutlet weak var todoSearchBar: UISearchBar!
    
    var todos = [TodoItem]()
    
    var selectedCategory : ItemCategory? {
        
        didSet {
            
            loadItems()
            
        }
        
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let backGroundColor = UIColor(hexString: selectedCategory?.color ?? "ffffff")!
        
        //Navbar UI
        if let navigationBar = navigationController?.navigationBar {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(backGroundColor, returnFlat: true)]
            navigationBar.tintColor = ContrastColorOf(backGroundColor, returnFlat: true)
            navBarAppearance.backgroundColor = backGroundColor
            navigationItem.title = selectedCategory?.name
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
        //Searchbar UI
        let textFieldInsideSearchBar = todoSearchBar.value(forKey: "searchField") as? UITextField
        todoSearchBar.barTintColor = backGroundColor
        textFieldInsideSearchBar?.textColor = ContrastColorOf(backGroundColor, returnFlat: true)
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = ContrastColorOf(backGroundColor, returnFlat: true)
        let clearButton = textFieldInsideSearchBar?.value(forKey: "_clearButton") as! UIButton
        clearButton.layer.cornerRadius = 5
        clearButton.backgroundColor = ContrastColorOf(backGroundColor, returnFlat: true)
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = todos[indexPath.row]
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = item.todoNote
        cell.accessoryType = item.check ? .checkmark : .none
        
        cell.backgroundColor = UIColor(hexString: selectedCategory?.color ?? "ffffff")?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todos.count))
        
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        todos[indexPath.row].check = !todos[indexPath.row].check
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    @IBAction func addTodo(_ sender: UIBarButtonItem) {
        var todoText = UITextField()
        
        let alert = UIAlertController(title: "Add new Todo", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let textAdded = todoText.text!
            if textAdded != "" {
                let item = TodoItem(context: self.context)
                item.todoNote = textAdded
                item.check = false
                item.parentCategory = self.selectedCategory
                self.todos.append(item)
                self.saveItems()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter todo"
            todoText = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        do {
            try context.save()
        }
        catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func loadItems(with request : NSFetchRequest<TodoItem> = TodoItem.fetchRequest(),predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
        }
        else {
            request.predicate = categoryPredicate
        }
        do {
            todos = try context.fetch(request)
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    override func deleteItem(at indexpath: IndexPath) {
        context.delete(todos[indexpath.row])
        todos.remove(at: indexpath.row)
        do {
            try context.save()
        }
        catch { print(error)}
    }
}

extension TodoViewController : UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text {
            let request : NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
            let searchPredicate = NSPredicate(format: "todoNote CONTAINS[cd] %@", searchText)
            request.sortDescriptors = [ NSSortDescriptor(key: "todoNote", ascending: true) ]
            loadItems(with: request,predicate: searchPredicate)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0)
        {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
