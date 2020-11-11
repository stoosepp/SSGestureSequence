//
//  ExpDetailsTableViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 13/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit
import CoreData


class ExpDetailsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ExperimentDetailsDelegate, TimerSelectDelegate {
	
	@IBOutlet weak var stimuliTableView:UITableView!
	@IBOutlet weak var expTitleTextField:UITextField!
	@IBOutlet weak var expDescriptionTextField:UITextField!
	@IBOutlet weak var showLinesSwitch:UISwitch!
	
	var experiment:Experiment?//Can be set if we're editing an experiment
	var experimentTitles:[String]?
	var stimuli = [Stimulus]()//Use to populate Table
	
	var expListDelegate:ExperimentsTableViewController?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		stimuliTableView.delegate = self
		stimuliTableView.dataSource = self
		
		expTitleTextField.delegate = self
		expDescriptionTextField.delegate = self
		expTitleTextField.becomeFirstResponder()
		expTitleTextField.returnKeyType = .next
		expDescriptionTextField.returnKeyType = .done
		self.isModalInPresentation = true
		
		//Editing an Experiment?
		if experiment != nil{
			print("Editing\(String(describing: experiment!.title))")
			expTitleTextField.text = experiment!.title
			expDescriptionTextField.text = experiment!.details
			//Show Touches
			//Record Audio
			//Show Timer
			//3s Countdown
			fetchStimuliFor(experiment: experiment!)
			
		}
		else{
			//Create new Experiment
			createTempExperiment()
		}
		stimuliTableView.setEditing(true, animated: true)
    }
	
	//MARK: - SETUP
	
	func createTempExperiment(){
		let newExperiment = Experiment(context: CoreDataHelper.shared.context)
		experiment = newExperiment
		
	}
	func fetchStimuliFor(experiment:Experiment?){
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		do {
			var fetchRequest:NSFetchRequest<Stimulus>?
			fetchRequest = Stimulus.fetchRequest()
			if experiment != nil{
				fetchRequest!.predicate = NSPredicate(format: "%K == %@",#keyPath(Stimulus.experiment), experiment!)
			}
			self.stimuli = try context.fetch(fetchRequest!)
			stimuli.sort {
				$0.order < $1.order
			}
			stimuliTableView.reloadData()
		}
		catch{
			print("There was an error")
		}
	}
	
	//MARK: - ACTIONS
	
	@IBAction func doneButtonPressed(){
		if expTitleTextField.text == ""{
			let ac = UIAlertController(title: "No title", message: "Experiment must have a title before it is saved", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(ac, animated: true)
		}
		else if experimentTitles?.contains(expTitleTextField.text!) == true{
			if isEditing == false{
				let ac = UIAlertController(title: "Duplicate", message: "An Experiment Already exists with that name. Please change the name.", preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				present(ac, animated: true)
			}
			else if isEditing && expTitleTextField.text == experiment!.title{//This is the same one.
				saveExperiment(existing: true)
			}
		}
		else if isEditing == true && experimentTitles?.contains(expTitleTextField.text!) == false{
			saveExperiment(existing: true)
		}
		else{
			saveExperiment(existing: false)
		}
		
	}
	
	func saveExperiment(existing:Bool){
		experiment!.title = expTitleTextField.text
		experiment!.details = expDescriptionTextField.text
		experiment!.showTouches = showLinesSwitch.isOn
		CoreDataHelper.shared.saveContext()
		if expListDelegate != nil{
			expListDelegate!.updateExperimentList(withExperiment: experiment!, isEditingExp:existing)
		}
		CoreDataHelper.shared.saveContext()
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func cancelButtonPressed(){
		self.dismiss(animated: true, completion: nil)
	}
	
	
	
	//MARK:- TEXTFIELD DELEGATE
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		//textField.resignFirstResponder()
		if textField == expTitleTextField { // Switch focus to other text field
			expDescriptionTextField.becomeFirstResponder()
		}
		else if textField == expDescriptionTextField{
			expDescriptionTextField.resignFirstResponder()
		}
		return true
	}
	
	
	//MARK: - NAVIGATION
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "addStimuliSegue"{
			let captureVC = segue.destination as! CaptureViewController
			captureVC.experiment = experiment
			captureVC.isEditing = true
			captureVC.expDetailsDelegate = self
		}
		else if segue.identifier == "showBlankTimeSegue"{
			let timerVC = segue.destination as! TimerSelectViewController
			timerVC.delegate = self
		}
	}
	
    // MARK: - TABLE VIEW STUFF

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		if stimuli.count == 0 {
			stimuliTableView.setEmptyView(image:"eye", title: "No Stimuli added yet.", message: "Tap the Add Stimulus button above.")
		}
		else {
			stimuliTableView.restore()
		}
		return stimuli.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "stimulusCell", for: indexPath) as! StimulusTableViewCell
        // Configure the cell...
		let thisStimulus = stimuli[indexPath.row]
		if thisStimulus.type == 0{
			cell.backgroundColor = .lightGray
		}
		else{
			cell.backgroundColor = .orange
		}
		cell.durationLabel.text = "Duration: \(thisStimulus.duration)  |  Order: \(thisStimulus.order)"

        return cell
    }
    
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let thisStimulus = stimuli[indexPath.row]
		var rowHeight:CGFloat = 50
		if thisStimulus.type != 0{
			rowHeight = 150
		}
		return rowHeight
	}
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			// Delete the row from the dataSet source
			let thisStimulus = stimuli[indexPath.row]
			stimuli.remove(at: indexPath.row)
			stimuliTableView.deleteRows(at: [indexPath], with: .fade)
			CoreDataHelper.shared.delete(thisStimulus)
		}
		else if editingStyle == .insert{
			//Nothing happens
		}
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let movedStimuli = self.stimuli[sourceIndexPath.row]
		
		stimuli.remove(at: sourceIndexPath.row)
		stimuli.insert(movedStimuli, at: destinationIndexPath.row)
		movedStimuli.order = Int16(destinationIndexPath.row)
		
		stimuli.forEach { (stimulus) in
			if stimulus != movedStimuli{
				if sourceIndexPath.row < destinationIndexPath.row{//Moved Down
					if Int(stimulus.order) <= Int(movedStimuli.order){
						stimulus.order -= 1
					}
				}
				else{//Moved Up
					if Int(stimulus.order) >= destinationIndexPath.row{
						stimulus.order += 1
					}
				}
			}
			
		}
		CoreDataHelper.shared.saveContext()
		stimuliTableView.reloadData()
	}
	//MARK: - DELEGATE STUFF
	func updateStimuliTable(){
		fetchStimuliFor(experiment: experiment!)
	}
	
	func updateDuration(withMins: Int, seconds: Int) {
		print("Duration updated to \(withMins) mins: \(seconds) secs")
		//Add Stimuli but with Duration
		let totalDuration = (withMins * 60) + seconds
		CoreDataHelper.shared.addBlankStimulus(toExperiment: experiment!, withDuration: Float(totalDuration))
		fetchStimuliFor(experiment: experiment!)
		
	}
	
	public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
			return false
	}
    
}
