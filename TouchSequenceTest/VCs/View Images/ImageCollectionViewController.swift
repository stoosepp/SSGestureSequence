//
//  ImageCollectionViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 19/2/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "ImageCell"

class ImageCollectionViewController: UICollectionViewController {
    
	//var screenShotURLs = Array<URL>()
	var dataSet:DataSet?
	var screenShotArray = [ScreenShot]()
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.navigationBar.isHidden = false
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
		fetchScreenShots(forDataSet: dataSet, showingAll: false)
		let startDate = dataSet?.startDate?.formattedString(withFormat: "EU")
		self.title = "DataSet: \(startDate)"
		
    }
	
	func fetchScreenShots(forDataSet:DataSet?, showingAll:Bool){
		print("This DataSet has \(String(describing: dataSet?.screenShots!.count)) screenshots.")
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		do {
			var fetchRequest:NSFetchRequest<ScreenShot>?
			fetchRequest = ScreenShot.fetchRequest()
			if showingAll == false{
				if forDataSet != nil{
					fetchRequest!.predicate = NSPredicate(format: "%K == %@",#keyPath(ScreenShot.dataSet), forDataSet!)
				}
				screenShotArray = try context.fetch(fetchRequest!)
			}
			else{
				var tempArray = [ScreenShot]()
				if let allDataSets = forDataSet?.experiment?.dataSets{
					//allDataSets.forEach { (singleSet) in
					for singleSet in allDataSets{
						let thisDataSet = singleSet as! DataSet
						fetchRequest!.predicate = NSPredicate(format: "%K == %@",#keyPath(ScreenShot.dataSet), thisDataSet)
						let thisSetsScreens = try context.fetch(fetchRequest!)
						tempArray.append(contentsOf: thisSetsScreens)
					}
					screenShotArray = tempArray
				}
			}
		}
		catch{
			
		}
	}
	
	@IBAction func toggleAllScreenshots(_ sender:UIBarButtonItem){
		if sender.title == "All Screenshots"{
			fetchScreenShots(forDataSet:dataSet, showingAll: true)
			sender.title = "This DataSet's Screenshots"
			self.title = "All DataSets"
		}
		else if sender.title == "This DataSet's Screenshots"{
			fetchScreenShots(forDataSet:dataSet, showingAll: false)
			sender.title = "All Screenshots"
			let startDate = dataSet?.startDate?.formattedString(withFormat: "NA")
			self.title = "DataSet: \(startDate)"
		}
		
		self.collectionView.reloadData()
	}

    
    // MARK: - NAVIGATION

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let imageContainer = segue.destination as! ImageContainerViewController;
        let index = self.collectionView.indexPathsForSelectedItems![0].row;
		imageContainer.screenShotArray = screenShotArray
		imageContainer.currentIndex = index;
    }
	
	@IBAction func exportImages(_ sender:UIBarButtonItem){
		// Create the alert controller
		let ac = UIAlertController(title: "Export to...", message: nil, preferredStyle: .actionSheet)
		   ac.addAction(UIAlertAction(title: "Email", style: .default, handler: nil))
		   ac.addAction(UIAlertAction(title: "Files", style: .default, handler: nil))
		   ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		   ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
		   present(ac, animated: true)
	}
	

	

    // MARK: UICollectionViewDataSetSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
		print("ScreenShot count:\(screenShotArray.count)")
		return screenShotArray.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ImageCollectionViewCell
		let screenAtIndex = screenShotArray[indexPath.row]
		//let image = UIImage(data: screenAtIndex.imageData!)
		
//		print("Cell at Index \(indexPath.item) has a file at \(imageFile)")
//		let imageData = try? Data(contentsOf: imageFile)
//		//print("Cell dataSet is \(String(describing: imageData))")
		cell!.cellImage.image = UIImage(data: screenAtIndex.imageData!)
		return cell!
	
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
//
//        // Configure the cell
//        cell.backgroundColor = .clear
////		let file = screenShotURLs[indexPath.row]
////		let imageDataSet = try? DataSet(contentsOf: file) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
////		cell.cellImage.image = UIImage(dataSet: imageDataSet!)!
//		cell.imageURL = screenShotURLs[indexPath.row]
//        return cell
		
	}
	
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
			
			let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ action in

				let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off, handler: { [self]action in
					
					
					//Delete the CoreData Object
					CoreDataHelper.shared.delete(screenShotArray[indexPath.row])
					
					//Delete the Item from the Array
					self.screenShotArray.remove(at: indexPath.row)
					
					//Delete the Cell
					self.collectionView.deleteItems(at:[indexPath])
					
				})
				
				return UIMenu(title: "Delete", image: nil, identifier: nil, children: [delete])
			}
			
			return configuration
	}

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

   
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
   

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
