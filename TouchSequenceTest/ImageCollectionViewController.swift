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

private let itemsPerRow: CGFloat = 3
private let sectionInsets = UIEdgeInsets(top: 50.0,
left: 20.0,
bottom: 50.0,
right: 20.0)
extension UICollectionViewController : UICollectionViewDelegateFlowLayout {
  //1
    public func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    //2
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  //3
    public func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  // 4
    public func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}
class ImageCollectionViewController: UICollectionViewController {
    
    var screenShots = Array<UIImage>()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

               do {
                   // Get the directory contents urls (including subfolders urls)
                   let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
                   print(directoryContents)

                   // if you want to filter the directory contents you can do like this:
                   let jpgFiles = directoryContents.filter{ $0.pathExtension == "jpg" }
                   print("jpg urls:",jpgFiles)
                let jpgFileNames = jpgFiles.map{ $0.deletingPathExtension().lastPathComponent } .sorted(by: { $0.compare($1) == .orderedDescending })
            
                   print("jpg list:", jpgFileNames)
                  for file in jpgFiles{
                      let data = try? Data(contentsOf: file) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                      screenShots.append(UIImage(data: data!)!)
                  }

               } catch {
                   print(error)
               }
              print("There are \(screenShots.count) files in the directory.")
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        let imageViewer = segue.destination as! ImageViewController;
        let index = self.collectionView.indexPathsForSelectedItems![0].row;
        NSLog("Selected Image at Index\(index)");
        imageViewer.selectedImage = screenShots[index];
        imageViewer.screenShotsCount = screenShots.count;
        imageViewer.currentIndex = index + 1;
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return screenShots.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
    
        // Configure the cell
        cell.backgroundColor = .clear
        let screenshot = screenShots[indexPath.row]
            let widthInPixels = screenshot.size.width * screenshot.scale
            let heightInPixels = screenshot.size.height * screenshot.scale
        //print("This image is \(widthInPixels) x \(heightInPixels)")
        cell.cellImage.image = screenshot
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
