//
//  DataSetsCollectionViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 11/11/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "DataCell"

class DataSetsCollectionViewController: UICollectionViewController, ExperimentListDelegate {
	
	var experiment:Experiment?
	var dataSets = [DataSet]()
	var expListDelegate:ExperimentsTableViewController?
	
	@IBOutlet var addButton:UIBarButtonItem!
	
	//MARK: - VIEW LIFECYCLE

    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Register cell classes
		
		// Do any additional setup after loading the view.
		updateDataSetListWith(thisExperiment: nil)

    }
	
	func updateDataSetListWith(thisExperiment:Experiment?) {
		fetchDataSetsFor(experiment: thisExperiment)
		print("Updating DataSet List")
		if thisExperiment == nil{
			collectionView.setEmptyView(image:"doc.on.clipboard", title: "No Experiment Here.", message: "Add an Experiment with some Stimuli before recording data")
			navigationItem.rightBarButtonItem = nil
		}
		else{
			experiment = thisExperiment
			self.title = "\(thisExperiment!.title!): DataSets"
			if thisExperiment!.stimuli!.count == 0{
				collectionView.setEmptyView(image:"doc.on.clipboard", title: "No Stimuli for \(experiment!.title!).", message: "Add Stimuli before recording data")
				navigationItem.rightBarButtonItem = nil
			}
			else if thisExperiment!.dataSets!.count == 0{
				experiment = thisExperiment
				print("No Data Sets found")
				collectionView.setEmptyView(image:"doc.on.clipboard", title: "No Data Sets.", message: "Tap the + button above to start recording data")
				navigationItem.rightBarButtonItem = addButton
			}
			else{
				
				experiment = thisExperiment
				print("Refreshing Data List for \(experiment!.title!)")
				collectionView.restore()
				navigationItem.rightBarButtonItem = addButton
				fetchDataSetsFor(experiment: experiment)
			}
		}
		
	
	}
	

	//MARK: - ACTIONS
	@IBAction func addButtonPressed(_ sender:UIBarButtonItem){
		if experiment!.stimuli?.count == 0{
			let ac = UIAlertController(title: "No Stimuli", message: "This experiment doesn't have any stimuli. Add some stimuli first, then you can collect some data.", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(ac, animated: true)
		}
		else {
			if (experiment!.orientation == "Landscape" && Helpers.shared.deviceOrientationIsLandscape() == true) || (experiment!.orientation == "Portrait" && Helpers.shared.deviceOrientationIsLandscape() == false){
				// Create the alert controller
				let alertController = UIAlertController(title: "New Data Collection", message: "What would you like to do?", preferredStyle: .alert)

				let startDCAction = UIAlertAction(title: "Start Data Collection", style: .default) {
					UIAlertAction in
					NSLog("Start Data")
					self.performSegue(withIdentifier: "showCaptureSegue", sender: CaptureStatus.kCollecting)
				}
				let startPreviewAction = UIAlertAction(title: "Preview Experiment", style: .default) {
					UIAlertAction in
					NSLog("Preview Shit")
					self.performSegue(withIdentifier: "showCaptureSegue", sender: CaptureStatus.kPreview)
				}
			   let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
				   UIAlertAction in
				   NSLog("Cancel Pressed")
			   }
				//Add the actions
				alertController.addAction(startDCAction)
				alertController.addAction(startPreviewAction)
				alertController.addAction(cancelAction)
				
//				if let popoverController = alertController.popoverPresentationController {
//					popoverController.barButtonItem = sender
//				  }

				  self.present(alertController, animated: true, completion: nil)
				
			}
			else{
				var deviceOrientation:String = "Landscape"
				if Helpers.shared.deviceOrientationIsLandscape() == false{
					deviceOrientation = "Portrait"
				}
				let ac = UIAlertController(title: "Wrong Orientation", message: "This experiment has stimuli that is presented in the \( experiment!.orientation!) orientation, but your device is in \(deviceOrientation). Rotate your device then try again.", preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				present(ac, animated: true)
			}
		
		}
		
	}
    
     //MARK: - NAVIGATION

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showCaptureSegue"{
			let captureVC = segue.destination as! CaptureViewController
			captureVC.status = sender as! String
			captureVC.experiment = experiment
		
		}
		else if segue.identifier == "showPlaybackSegue"{
			let nav = segue.destination as! UINavigationController
			let playBackVC = nav.viewControllers.first as! PlaybackViewController
			playBackVC.dataSet = (sender as! DataSet)
		}
    }
    
	
	func fetchDataSetsFor(experiment:Experiment?){
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		do {
			var fetchRequest:NSFetchRequest<DataSet>?
			fetchRequest = DataSet.fetchRequest()
			if experiment != nil{
				fetchRequest!.predicate = NSPredicate(format: "%K == %@",#keyPath(DataSet.experiment), experiment!)
			}
			self.dataSets = try context.fetch(fetchRequest!)
			//print("Found \(dataSets.count) DataSets")
			collectionView.reloadData()
		}
		catch{
			print("There was an error")
		}
	}

    // MARK: - CollectionView Stuff

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
		return dataSets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DataCell", for: indexPath) as! DataSetCollectionViewCell
		// Configure the cell
		let thisDataSet = dataSets[indexPath.item]
		cell.dateTimeLabel.text = thisDataSet.startDate!.formattedString(withFormat: "NA")
		//cell.participantLabel.text = "No Participant Yet"
		cell.participantLabel.text = "Duration: " + thisDataSet.durationString
		let dataSetScreens = thisDataSet.screenShots?.allObjects as! [ScreenShot]
		if let firstScreen = dataSetScreens.first{
			cell.dataImageView.image = UIImage(data: firstScreen.imageData!)
		}
		
        return cell
    }

    // MARK: UICollectionViewDelegate
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		if (experiment!.orientation == "Landscape" && Helpers.shared.deviceOrientationIsLandscape() == true) || (experiment!.orientation == "Portrait" && Helpers.shared.deviceOrientationIsLandscape() == false){
			let thisDataSet = dataSets[indexPath.row]
			performSegue(withIdentifier: "showPlaybackSegue", sender: thisDataSet)
			
		}
		else{
			var deviceOrientation:String = "Landscape"
			if Helpers.shared.deviceOrientationIsLandscape() == false{
				deviceOrientation = "Portrait"
			}
			let ac = UIAlertController(title: "Wrong Orientation", message: "This experiment has stimuli that is presented in the \( experiment!.orientation!) orientation, but your device is in \(deviceOrientation). Rotate your device then try again.", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(ac, animated: true)
		}
		
	}
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
			
			let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ action in

				let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off, handler: { [self]action in
					
					
					//Delete the CoreData Object
					CoreDataHelper.shared.delete(dataSets[indexPath.row])
					
					//Delete the Item from the Array
					self.dataSets.remove(at: indexPath.row)
					
					//Delete the Cell
					self.collectionView.deleteItems(at:[indexPath])
					
					expListDelegate?.updateExperimentList(withExperiment: experiment!, isEditingExp: true)
				})
				
				return UIMenu(title: "Delete", image: nil, identifier: nil, children: [delete])
			}
			
			return configuration
	}

}
