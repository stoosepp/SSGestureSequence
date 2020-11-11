//
//  StimulusTableViewCell.swift
//  TouchSequenceTest
//
//  Created by Stoo on 6/11/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit



class StimulusTableViewCell: UITableViewCell {
	
	static let kBlank:Int = 0
	static let kImage:Int = 1
	static let kVideo:Int = 2
	static let kWebpage:Int = 3
	
	var stimulusType:Int = 0
	
	//Outlets
	@IBOutlet weak var durationLabel:UILabel!
	

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		/*
		let bgLayer = CALayer()
		bgLayer.frame = self.layer.bounds.insetBy(dx: 10.0, dy: 10.0)
		
		
		bgLayer.cornerRadius = 15
		// border
		switch stimulusType {
		case StimulusTableViewCell.kBlank:
			bgLayer.backgroundColor = UIColor.lightGray.cgColor
		case StimulusTableViewCell.kImage:
			bgLayer.backgroundColor = UIColor.blue.cgColor
		case StimulusTableViewCell.kVideo:
			bgLayer.backgroundColor = UIColor.orange.cgColor
		case StimulusTableViewCell.kWebpage:
			bgLayer.backgroundColor = UIColor.green.cgColor
		default:
			bgLayer.backgroundColor = UIColor.lightGray.cgColor
		}
		self.layer.insertSublayer(bgLayer, below: self.layer)
		
*/
	}
		

	
	

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
