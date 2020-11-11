//
//  ExperimentTableViewCell.swift
//  TouchSequenceTest
//
//  Created by Stoo on 18/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class ExperimentTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var detailsLabel:UILabel!
	@IBOutlet weak var expImageView:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
