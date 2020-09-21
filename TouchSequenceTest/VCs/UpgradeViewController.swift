//
//  UpgradeViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class UpgradeViewController: UIViewController {
	
	@IBAction func upgradeToPro(_ sender:Any){
		
		Core.shared.setDidUpgrade(value: true)
		print("Upgraded to Pro")
	}
	
	
}


