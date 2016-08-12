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

class UserTableViewController: CoreDataTableViewController {
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest(entityName: Repositories.user.storage.name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: coreDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        Repositories.user.synchronize()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Table view delegate implementation
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = fetchedResultsController!.objectAtIndexPath(indexPath) as! User
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = "\(user.lastName!), \(user.firstName!) --- \(user.shortID)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if let user = fetchedResultsController?.objectAtIndexPath(indexPath) as? User where editingStyle == .Delete {
            Repositories.user.delete(user)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let user = fetchedResultsController?.objectAtIndexPath(indexPath) as? User {
            user.lastName = "\(user.lastName!) - Edited"
            Repositories.user.update(user)
        }
    }
    
    // MARK: - Actions
    @IBAction func edit(sender: UIBarButtonItem) {
        tableView.editing = !tableView.editing
    }
    
    @IBAction func unwindToUserList(sender: UIStoryboardSegue) {
        if let controller = sender.sourceViewController as? NewUserViewController {
            Repositories.user.create(["firstName": controller.firstName, "lastName": controller.lastName])
        }
    }
    
}