//
//  UserTableViewController.swift
//  Example
//
//  Created by Luciano Polit on 18/7/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import UIKit
import CoreData
import PromiseKit

// MARK: - Main
class UserTableViewController: CoreDataTableViewController {
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Repositories.user.storage.name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: coreDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        Repositories.user.synchronize()
            .catch(execute: ErrorParser.parse)
    }
    
    // MARK: - Actions
    @IBAction func edit(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
    }
    
    @IBAction func unwindToUserList(_ sender: UIStoryboardSegue) {
        if let controller = sender.source as? NewUserViewController {
            Repositories.user.create(["firstName": controller.firstName, "lastName": controller.lastName])
                .catch(execute: ErrorParser.parse)
        }
    }
    
}

// MARK: - Table view delegate implementation
extension UserTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = fetchedResultsController!.object(at: indexPath) as! User
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        
        cell.textLabel?.text = "\(user.lastName!), \(user.firstName!) --- \(user.shortID)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let user = fetchedResultsController?.object(at: indexPath) as? User, editingStyle == .delete {
            Repositories.user.delete(user)
                .catch(execute: ErrorParser.parse)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = fetchedResultsController?.object(at: indexPath) as? User {
            user.lastName = "\(user.lastName!) - Edited"
            user.synchronized = false
            Repositories.user.patch(user)
                .catch(execute: ErrorParser.parse)
        }
    }
    
}
