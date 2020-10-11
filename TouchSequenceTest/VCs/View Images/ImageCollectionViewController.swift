//
//  ImageCollectionViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 19/2/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCell"
// MARK: - Collection View Flow Layout Delegate

class ImageCollectionViewController: UICollectionViewController {
    
	var screenShotURLs = Array<URL>()
	
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
		screenShotURLs = Core.shared.fetchFileURLS()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let imageContainer = segue.destination as! ImageContainerViewController;
        let index = self.collectionView.indexPathsForSelectedItems![0].row;
		imageContainer.currentIndex = index;
    }
	

    // MARK: UICollectionViewDataSetSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
       // return screenShots.count
		return screenShotURLs.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ImageCollectionViewCell 
		let imageFile = self.screenShotURLs[indexPath.item]
		print("Cell at Index \(indexPath.item) has a file at \(imageFile)")
		let imageData = try? Data(contentsOf: imageFile)
		//print("Cell dataSet is \(String(describing: imageData))")
		cell!.cellImage.image = UIImage(data: imageData!)!
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

				let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off, handler: {action in
					
					
					//Delete the file
					do {
						try FileManager.default.removeItem(at: self.screenShotURLs[indexPath.row])
					} catch {
						print("error deleting file:", error)
					}
					
					//Delete the Cell
					self.screenShotURLs.remove(at: indexPath.row)
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
