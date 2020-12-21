//
//  StimulusTableViewCell.swift
//  TouchSequenceTest
//
//  Created by Stoo on 6/11/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

struct StimulusType{
	static let kBlank:Int = 0
	static let kText:Int = 1
	static let kImage:Int = 2
	static let kVideo:Int = 3
	static let kWebView:Int = 4
}


class StimulusTableViewCell: UITableViewCell {
	
	
	
	var stimulusType:Int = 0
	
	//Outlets
	@IBOutlet weak var durationLabel:UILabel!
	@IBOutlet weak var stimulusImageView:UIImageView!
	@IBOutlet weak var stimulusTextLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
	}
		
	override func draw(_ rect: CGRect) {
		self.backgroundColor = .clear
		let bgLayer = CALayer()
		bgLayer.frame = self.bounds.insetBy(dx: 5.0, dy: 5.0)
		bgLayer.cornerRadius = 5
		//bgLayer.shadowOpacity = 0.3
		//bgLayer.shadowOffset = CGSize(width: 0, height: 3)
		//bgLayer.shadowRadius = 3.0
		bgLayer.isGeometryFlipped = false
		// border
		switch stimulusType {
		case StimulusType.kBlank:
			bgLayer.backgroundColor = UIColor.lightGray.cgColor
		case StimulusType.kText:
			bgLayer.backgroundColor = UIColor.white.cgColor
		case StimulusType.kImage:
			bgLayer.backgroundColor = UIColor.orange.cgColor
		case StimulusType.kVideo:
			bgLayer.backgroundColor = UIColor.blue.cgColor
		case StimulusType.kWebView:
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
