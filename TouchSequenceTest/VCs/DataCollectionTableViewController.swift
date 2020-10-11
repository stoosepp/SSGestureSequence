//
//  DataSetCollectionTableViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 6/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit
import CoreData

class DataSetCollectionTableViewController: UITableViewController {
	
	//CoreDataSet
	var experiment:Experiment?
	var dataSet:[DataSet]?
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
	
		fetchDCInstancesFor(expSession: experiment)//Fetch All
    }
	
	func fetchDCInstancesFor(expSession:Experiment?){
		do {
			var fetchRequest:NSFetchRequest<DataSet>?
			fetchRequest = DataSet.fetchRequest()
			if experiment != nil{
				fetchRequest!.predicate = NSPredicate(format: "%K == %@",#keyPath(DataSet.experiment), experiment!)
			}
			self.dataSet = try context.fetch(fetchRequest!)
			print("DCVC: \(self.dataSet!.count) DCs")
			DispatchQueue.main.async {
			self.tableView.reloadData()
		}
			
	}
		catch{
			
		}
	}

    // MARK: - Table view dataSet source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return dataSet!.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataSetCollectionCell", for: indexPath)
		let thisDataSet = dataSet![indexPath.row]
        // Configure the cell...
		let startDate = Helpers.shared.formatDate(forDate: thisDataSet.startDate!, format: "NA")
		cell.textLabel!.text = startDate
		if thisDataSet.touches!.count != 0 {
			cell.detailTextLabel!.text = "Touches: \(thisDataSet.touches!.count)"
		}
		else{
			cell.detailTextLabel!.text = "No touches Here"
			
		}
		
		print("Start Date:\(startDate)")
        return cell
    }
    
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let nav = splitViewController?.viewController(for: .secondary)
		let captureVC = nav?.children[0] as! CaptureViewController
		captureVC.captureView.dataSet = dataSet![indexPath.row]
		captureVC.performSegue(withIdentifier: "showPlaybackSegue", sender: nil)
		//dismiss
		UIView.animate(withDuration: 0.5) {
			self.splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.secondaryOnly
		}
		
	}

   
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
   

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the dataSet source
			let thisDataSet = dataSet![indexPath.row]
			experiment!.removeFromDataSets(thisDataSet)
			CoreDataHelper.shared.save(experiment!)
			dataSet?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
