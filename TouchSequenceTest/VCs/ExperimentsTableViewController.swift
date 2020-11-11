//
//  ExpSessionsTableViewController.swift
//  TouchSeguenceTest
//
//  Created by Stoo on 6/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

protocol ExperimentListDelegate {
	func setupExperiment(theExperiment:Experiment)
}

class ExperimentsTableViewController: UITableViewController {
	
	
	
	//CoreDataSet
	var experimentTitles = [String]()
	var experiments:[Experiment]?
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	var captureDelegate:CaptureViewController?

	
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
		
		
    }
	
	func fetchExperiments(){
		do {
			self.experiments = try context.fetch(Experiment.fetchRequest())
			experiments?.forEach({ (experiment) in
				experimentTitles.append(experiment.title!)
			})
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
		if self.experiments?.count != 0{
			let firstIndex = IndexPath(row: 0, section: 0)
			self.tableView.selectRow(at: firstIndex, animated: true, scrollPosition: UITableView.ScrollPosition.top)
		}
		self.performSegue(withIdentifier: "showExpDataSetSegue", sender: self)
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
		//print("Title:\(String(describing: thisExperiment.title))")
        // Configure the cell...
		cell.titleLabel.text = thisExperiment.title
		var totalDuration:Float = 0.0
		thisExperiment.stimuli!.forEach { (stimulus) in
			let thisStimulus = stimulus as! Stimulus
			totalDuration += thisStimulus.duration
		}
		var durationString = ""
		if totalDuration > 60{
			let minutes = Int(totalDuration/60)
			let seconds = Int(totalDuration) - (minutes * 60)
			durationString = ")\(minutes):\(seconds)"
		}
		else{
			durationString = "0:\(Int(totalDuration))"
		}
		
		var orientationString = "Landscape"
		if thisExperiment.isLandscape == false{
			orientationString = "Portrait"
		}
	
		cell.detailsLabel.text = "DataSets: \(thisExperiment.dataSets!.count) | Orientation: \(orientationString)\nDuration:\(durationString)"
		
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
		print("Tapped on \(thisExperiment!.title)")
		self.performSegue(withIdentifier: "addExperimentSegue", sender:thisExperiment )
		
	}
	

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		if segue.identifier == "showExpDataSetSegue"{
			let dataSetVC = segue.destination as! DataSetsCollectionViewController
			dataSetVC.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
			let indexPath = tableView.indexPathForSelectedRow
			if indexPath != nil{
				dataSetVC.experiment = experiments![indexPath!.row]
			}
		}
		else if segue.identifier == "addExperimentSegue"{
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
