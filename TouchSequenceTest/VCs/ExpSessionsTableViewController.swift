//
//  ExpSessionsTableViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 6/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

protocol ExpSessionsListDelegate {
	func setupExperiment(experiment:Experiment)
}

class ExpSessionsTableViewController: UITableViewController {
	
	//CoreDataSet
	var experiments:[Experiment]?
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	var captureDelegate:CaptureViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		fetchSessions()
    }
	func fetchSessions(){
		do {
			self.experiments = try context.fetch(Experiment.fetchRequest())
			print("SessionsVC: \(self.experiments!.count) Sessions")
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
		return experiments!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expSessionCell", for: indexPath)
		let thisExperiment = experiments![indexPath.row]
		print("Title:\(String(describing: thisExperiment.title))")
        // Configure the cell...
		cell.textLabel!.text = thisExperiment.title
        return cell
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
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let thisExperiment = experiments![indexPath.row]
		if captureDelegate != nil {
			if thisExperiment.stimuli!.count != 0 {
				captureDelegate!.setupExperiment(experiment: experiments![indexPath.row])
				self.dismiss(animated: true, completion: nil)
			}
			else{
				let alert = UIAlertController(title: "No stimuluss", message: "This Experimental Session has no artifacts (e.g., images or videos) associated with it. Add on on the capture screen to start capturing.", preferredStyle: .alert)
				//alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (this) in
					self.dismiss(animated: true, completion: nil)
				}))
				self.present(alert, animated: true, completion: nil)
				
			}
		}
		else{
			print("Not in popover")
			//performSegue(withIdentifier: "showDetail", sender: nil)
		}
			
		
	}

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		if segue.identifier == "showSessionsDataSetSegue"{
			let dataSetVC = segue.destination as! DataSetCollectionTableViewController
			let indexPath = tableView.indexPathForSelectedRow
			dataSetVC.experiment = experiments![indexPath!.row]
		}

		
    }
   
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		var shouldPush = true
		if captureDelegate != nil{
			shouldPush = false
		}
		return shouldPush
	}
}
