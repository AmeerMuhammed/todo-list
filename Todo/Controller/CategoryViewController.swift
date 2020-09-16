//
//  CategoryViewController.swift
//  Todo
//
//  Created by AmeerMuhammed on 9/13/20.
//  Copyright © 2020 AmeerMuhammed. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    var categories = [ItemCategory]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navigationBar = navigationController?.navigationBar {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor.flatSkyBlue()
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(hexString: categories[indexPath.row].color ?? "#ffffff")
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tableViewController = segue.destination as! TodoViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            tableViewController.selectedCategory = categories[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    //MARK: - Add Category
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        var categoryText = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let textAdded = categoryText.text!
            if textAdded != "" {
                let itemCategory = ItemCategory(context: self.context)
                itemCategory.name = textAdded
                itemCategory.color = UIColor.randomFlat().hexValue()
                self.categories.append(itemCategory)
                self.saveItems()
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter todo"
            categoryText = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - CoreData MEthods
    
    func loadItems(request: NSFetchRequest<ItemCategory> = ItemCategory.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        }
        catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func saveItems() {
        do {
            try context.save()	
        }
        catch {
            print(error)
        }
    }
    
    override func deleteItem(at indexPath: IndexPath) {
        self.context.delete(self.categories[indexPath.row])
        self.categories.remove(at: indexPath.row)
        self.saveItems()
    }
}
