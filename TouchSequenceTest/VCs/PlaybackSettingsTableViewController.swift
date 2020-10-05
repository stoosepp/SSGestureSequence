//
//  PlaybackSettingsTableViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 4/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

protocol PlaybackSettingsDelegate{
	func updatePencilColor(color:UIColor)
	func updateFingerColor(color:UIColor)
}

struct PlaybackStruct{
	static let kFingerColor = "fingerColor" //tag 1
	static let  kPencilColor = "pencilColor" //tag 2
}

class PlaybackSettingsTableViewController: UITableViewController, UIColorPickerViewControllerDelegate {
	
	//Color Buttons
	@IBOutlet var fingerButton:RoundedButton!
	@IBOutlet var pencilButton:RoundedButton!
	
	@IBOutlet var speedSwitch:UISwitch!
	var delegate:MultiTouchPlayerView?
	var colorUpdating:String?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

		fingerButton.backgroundColor = delegate?.fingerLineColor
		pencilButton.backgroundColor = delegate?.pencilLineColor
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		pencilButton.strokeColor = UIColor.white.cgColor
		fingerButton.strokeColor = UIColor.white.cgColor
    }
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		self.preferredContentSize = tableView.contentSize
	}
	
	
	//MARK: Color Picker Stuff
	@IBAction func colorPressed(_ sender:UIButton){
		if sender.tag == 1{
			//Changing FingerColor
			pickColor(forColor: PlaybackStruct.kFingerColor, withSender: sender)
			
		}
		else if sender.tag == 2{
			//Changing PencilColor
			pickColor(forColor: PlaybackStruct.kPencilColor, withSender: sender)
		}
	}
	
	func pickColor(forColor:String, withSender:UIButton){
		colorUpdating = forColor
		let picker = UIColorPickerViewController()
		picker.modalPresentationStyle = .currentContext
		picker.delegate = self
		picker.selectedColor = withSender.backgroundColor!
		//self.navigationController?.present(picker, animated: true, completion: nil)
		present(picker, animated: true, completion: nil)
	}
	
	func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
			dismiss(animated: true, completion: nil)
	}

	func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
			let color = viewController.selectedColor
		if colorUpdating == PlaybackStruct.kFingerColor{
			fingerButton.backgroundColor = color
			delegate?.fingerLineColor = color
			delegate?.setNeedsDisplay()
		}
		else if colorUpdating == PlaybackStruct.kPencilColor{
			pencilButton.backgroundColor = color
			delegate?.pencilLineColor = color
			delegate?.setNeedsDisplay()
		}

	}
	
	@IBAction func toggleLineSpeed(_ sender: UISwitch) {
		tableView.beginUpdates()
		if sender.isOn{
			tableView.insertRows(at: [IndexPath(row: 5, section: 0)], with: .bottom)
			tableView.insertRows(at: [IndexPath(row: 6, section: 0)], with: .bottom)
			tableView.insertRows(at: [IndexPath(row: 7, section: 0)], with: .bottom)
		}
		else{
			tableView.deleteRows(at: [IndexPath(row: 5, section: 0)], with: .bottom)
			tableView.deleteRows(at: [IndexPath(row: 6, section: 0)], with: .bottom)
			tableView.deleteRows(at: [IndexPath(row: 7, section: 0)], with: .bottom)
		}
		
		tableView.endUpdates()
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		var rowCount = 0
		if speedSwitch.isOn == true{
			rowCount = 8
		}
		else{
			rowCount = 5
		}
        return rowCount
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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


