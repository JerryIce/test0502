//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by 杨宗维 on 2017/7/16.
//  Copyright © 2017年 Icecooll. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation


class LocationsViewController: UITableViewController {
        var managedObjectContext: NSManagedObjectContext!
    
    lazy var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1,sortDescriptor2]
        fetchRequest.fetchBatchSize = 20
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "Category", cacheName: "Locations")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .white
        navigationItem.rightBarButtonItem = editButtonItem
    }
    func performFetch(){
        do{
            try fetchedResultsController.performFetch()
        }catch {
            fatalCoreDataError(error: error)
        }

    }
    deinit{
        fetchedResultsController.delegate = nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        let location = fetchedResultsController.object(at: indexPath) as! Location
        cell.configureForLocation(location)
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name.uppercased()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath) as! Location
            location.removePhtotFile()
            managedObjectContext.delete(location)
            do{
                try managedObjectContext.save()
            }catch{
                fatalCoreDataError(error: error)
            }
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight + 5, width: 300, height: 14)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(white: 1.0, alpha: 0.4)
        label.backgroundColor = UIColor.clear
        let separatorRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 0.5, width: tableView.bounds.size.width - 15, height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.85)
        view.addSubview(label)
        view.addSubview(separator)
        return view
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation"{
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell){
                let location = fetchedResultsController.object(at: indexPath)
                controller.locationToEdit = location as? Location
            }
        }}
}
extension LocationsViewController:NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller:NSFetchedResultsController<NSFetchRequestResult>){
        print("***controllerWillChangeContent")
        tableView.beginUpdates()
    }
    func controller(_ controller:NSFetchedResultsController<NSFetchRequestResult>,didChange:Any,at indexPath:IndexPath?,for type:NSFetchedResultsChangeType,newIndexPath:IndexPath?){
        switch type {
        case .insert:
            print("****NSFetchResultsChangeInsert(object)")
            tableView.insertRows(at: [newIndexPath!] , with: .fade)
        case .delete:
            print("****NSFetchResultsChangeDelete(object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("****NSFetchResultsChangeUpdate(object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = controller.object(at: indexPath!)as! Location
                cell.configureForLocation(location)
            }
        case .move:
            print("****NSFetchResultsChangeMove(object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [indexPath!], with: .fade)
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("****NSFetchResultsChangeInsert(object)")
            tableView.insertSections(NSIndexSet(index:sectionIndex) as IndexSet, with: .fade)
        case .delete:
            print("****NSFetchResultsChangeDelete(object)")
            tableView.deleteSections(NSIndexSet(index:sectionIndex) as IndexSet, with: .fade)
        case .update:
            print("****NSFetchResultsChangeUpdate(object)")
        case .move:
            print("****NSFetchResultsChangeMove(object)")
        }
    }
    func controllerDidChangeContent(_ controller:NSFetchedResultsController<NSFetchRequestResult>){
        print("****DidChangeContent")
        tableView.endUpdates()
    }
}


