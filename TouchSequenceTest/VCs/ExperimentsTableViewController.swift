//
//  ExpSessionsTableViewController.swift
//  TouchSeguenceTest
//
//  Created by Stoo on 6/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

protocol ExperimentListDelegate{
	func updateDataSetListWith(thisExperiment:Experiment?)
}

class ExperimentsTableViewController: UITableViewController {
	
	
	
	//CoreDataSet
	var experimentTitles = [String]()
	var experiments:[Experiment]?
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	var captureDelegate:CaptureViewController?
	
	var dataSetsDelegate:DataSetsCollectionViewController?

	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		fetchExperiments()
	}
    override func viewDidLoad() {
		super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		//Set HeaderView
		dataSetsDelegate = (splitViewController?.viewControllers.last?.children.first as! DataSetsCollectionViewController)
		
    }
	func updateExperimentList() {
		fetchExperiments()
	}
	
	func fetchExperiments(){
		do {
			self.experiments = try context.fetch(Experiment.fetchRequest())
			experiments?.forEach({ (experiment) in
				experimentTitles.append(experiment.title!)
			})
			print("Found \(experiments!.count) experiments")
			DispatchQueue.main.async {
				self.tableView.reloadData()
				//Select First Row when loaded
				self.tryToSelectFirst()
			}
	}
		catch{
			
		}
	}
	
	func tryToSelectFirst(){
		if experiments?.count != 0{
			let firstIndex = IndexPath(row: 0, section: 0)
			self.tableView.selectRow(at: firstIndex, animated: true, scrollPosition: UITableView.ScrollPosition.top)
			//Delegate
			dataSetsDelegate?.updateDataSetListWith(thisExperiment: experiments![0])
		}
		else{
			dataSetsDelegate?.updateDataSetListWith(thisExperiment: nil)
		}
		
	}

	// MARK: - Table view dataSet source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		if experiments!.count == 0 {
			tableView.setEmptyView(image:"note.text", title: "You don't have any Experiments yet.", message: "Your experiments will be in here.")
		}
		else {
			tableView.restore()
		}
		return experiments!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "experimentCell", for: indexPath) as! ExperimentTableViewCell
		let thisExperiment = experiments![indexPath.row]
        // Configure the cell...
		cell.titleLabel.text = thisExperiment.title
		
		var dataSetCount  = 0
		for _ in thisExperiment.stimuli?.allObjects as! [Stimulus]{
			dataSetCount += thisExperiment.dataSets!.count
		}
		cell.detailsLabel.text = "DataSets: \(dataSetCount) | Orientation: \(thisExperiment.orientation!)\nDuration:\(thisExperiment.durationString)"
		
		if let expImage = thisExperiment.imageData{
			cell.expImageView!.image = UIImage(data: expImage)
		}
		else{
			cell.expImageView?.isHidden = true
		}
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
			let thisExperiment = experiments![indexPath.row]
			experiments?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
			CoreDataHelper.shared.delete(thisExperiment)
			tryToSelectFirst()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let thisExperiment = experiments![indexPath.row]
		dataSetsDelegate?.expListDelegate = self
		dataSetsDelegate?.updateDataSetListWith(thisExperiment: thisExperiment)
	}
	
	//MARK: - DELEGATE METHODS
  
	func updateExperimentList(withExperiment: Experiment, isEditingExp:Bool) {
		if !isEditingExp{
			experiments?.append(withExperiment)
		}
		tableView.reloadData()
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
    
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	}
	*/
    
    // MARK: - Navigation
	
	@IBAction func editExperiment(sender: UIButton) {
		let cell = sender.superview?.superview?.superview as! ExperimentTableViewCell
		let indexPath = tableView.indexPath(for: cell)
		let thisExperiment = experiments?[indexPath!.row]
		print("Tapped on \(String(describing: thisExperiment!.title))")
		self.performSegue(withIdentifier: "addExperimentSegue", sender:thisExperiment )
		
	}
	

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		if segue.identifier == "addExperimentSegue"{
			let newExpVC = segue.destination as! ExpDetailsTableViewController
			newExpVC.experimentTitles = experimentTitles
			newExpVC.expListDelegate = self
			if sender is Experiment{
				let expToEdit = sender as! Experiment
				newExpVC.isEditing = true
				newExpVC.experiment = expToEdit
			}
		}
		else if segue.identifier == "editExperimentSegue"{
			let newExpVC = segue.destination as! ExpDetailsTableViewController
			newExpVC.experimentTitles = experimentTitles
			newExpVC.experiment = (sender as! Experiment)
			let indexPath = tableView.indexPathForSelectedRow
			if indexPath != nil{
				newExpVC.experiment = experiments![indexPath!.row]
			}
		}
    }

}
