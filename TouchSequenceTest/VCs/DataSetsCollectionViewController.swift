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

class DataSetsCollectionViewController: UICollectionViewController {
	
	var experiment:Experiment?
	var dataSets = [DataSet]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(DataSetCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		self.splitViewController?.preferredDisplayMode = .automatic
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
	
	func fetchDataSetsFor(experiment:Experiment?){
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		do {
			var fetchRequest:NSFetchRequest<DataSet>?
			fetchRequest = DataSet.fetchRequest()
			if experiment != nil{
				fetchRequest!.predicate = NSPredicate(format: "%K == %@",#keyPath(DataSet.experiment), experiment!)
			}
			self.dataSets = try context.fetch(fetchRequest!)
			collectionView.reloadData()
		}
		catch{
			print("There was an error")
		}
	}

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
		return dataSets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DataSetCollectionViewCell
		let thisDataSet = dataSets[indexPath.item]
		cell.dateTimeLabel.text = thisDataSet.startDate?.formattedString(withFormat: "NA")
		cell.participantLabel.text = "No Participant Yet"
		
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
