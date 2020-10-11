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
	func toggleStartEnd(withValue:Bool)
	func toggleLineSpeed(withValue:Bool)
	func updateLinesDrawn(withValue:Int)
}

struct PlaybackStruct{
	static let kFingerColor = "fingerColor" //tag 1
	static let  kPencilColor = "pencilColor" //tag 2
}

class PlaybackSettingsTableViewController: UITableViewController, UIColorPickerViewControllerDelegate {
	
	//Color Buttons
	@IBOutlet var fingerButton:RoundedButton!
	@IBOutlet var pencilButton:RoundedButton!
	@IBOutlet var linesToDrawSegmentedControl:UISegmentedControl!
	@IBOutlet var speedSwitch:UISwitch!
	@IBOutlet var startEndSwitch:UISwitch!
	
	var delegate:MultiTouchPlayerView?
	var colorUpdating:String?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
	
		fingerButton.backgroundColor = delegate?.fingerLineColor
		pencilButton.backgroundColor = delegate?.pencilLineColor
		
		
		
		linesToDrawSegmentedControl.selectedSegmentIndex = delegate!.linesShown
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
		
		fingerButton.strokeColor = UIColor.white.cgColor
		pencilButton.strokeColor = UIColor.white.cgColor
		
    }
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		self.preferredContentSize = tableView.contentSize
	}
	
	
	@IBAction func toggleLinesDisplayed(_ sender: UISegmentedControl) {
		//print("Drawing: \(value)")
		delegate!.updateLinesDrawn(withValue:sender.selectedSegmentIndex)
		delegate?.setNeedsDisplay()
	}
	
	@IBAction func toggleLineSpeed(_ sender: UISwitch) {
		//Update Drawing through Delegate
		delegate?.toggleLineSpeed(withValue: sender.isOn)
		
		//Show Colors for line speed
		tableView.beginUpdates()
		let indexPath = IndexPath(row: 2, section: 0)
		let defaultPenColorCell = tableView.cellForRow(at: indexPath)
		if sender.isOn{
			defaultPenColorCell?.isUserInteractionEnabled = false
			defaultPenColorCell?.alpha = 0.5
			tableView.insertRows(at: [IndexPath(row: 5, section: 0)], with: .fade)
			tableView.insertRows(at: [IndexPath(row: 6, section: 0)], with: .fade)
			tableView.insertRows(at: [IndexPath(row: 7, section: 0)], with: .fade)
		}
		else{
			defaultPenColorCell?.isUserInteractionEnabled = true
			defaultPenColorCell?.alpha = 1
			tableView.deleteRows(at: [IndexPath(row: 5, section: 0)], with: .fade)
			tableView.deleteRows(at: [IndexPath(row: 6, section: 0)], with: .fade)
			tableView.deleteRows(at: [IndexPath(row: 7, section: 0)], with: .fade)
		}
		tableView.endUpdates()
	}
	
	@IBAction func toggleStartEnd(_ sender: UISwitch) {
		
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
		present(picker, animated: true, completion: nil)
	}
	
	func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
			dismiss(animated: true, completion: nil)
	}

	func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
			let color = viewController.selectedColor
		if colorUpdating == PlaybackStruct.kFingerColor{
			fingerButton.backgroundColor = color
			delegate?.updateFingerColor(color: color)
		}
		else if colorUpdating == PlaybackStruct.kPencilColor{
			pencilButton.backgroundColor = color
			delegate?.updatePencilColor(color: color)
		}
	}
	

	
    // MARK: - Table view dataSet source

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
            // Delete the row from the dataSet source
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


