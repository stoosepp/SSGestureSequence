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
	@IBOutlet weak var stimulusImageView:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
	}
		
	override func draw(_ rect: CGRect) {
		self.backgroundColor = .clear
		let bgLayer = CALayer()
		bgLayer.frame = self.bounds.insetBy(dx: 5.0, dy: 5.0)
		
		bgLayer.cornerRadius = 5
		bgLayer.shadowOpacity = 0.3
		bgLayer.shadowOffset = CGSize(width: 0, height: 3)
		bgLayer.shadowRadius = 3.0
		bgLayer.isGeometryFlipped = false
		// border
		switch stimulusType {
		case StimulusTableViewCell.kBlank:
			bgLayer.backgroundColor = UIColor.lightGray.cgColor
		case StimulusTableViewCell.kImage:
			bgLayer.backgroundColor = UIColor.orange.cgColor
		case StimulusTableViewCell.kVideo:
			bgLayer.backgroundColor = UIColor.blue.cgColor
		case StimulusTableViewCell.kWebpage:
			bgLayer.backgroundColor = UIColor.green.cgColor
		default:
			bgLayer.backgroundColor = UIColor.lightGray.cgColor
		}
		//self.layer.addSublayer(bgLayer)
		self.layer.insertSublayer(bgLayer, below: contentView.layer)
	
	}
	
	

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
