//
//  UpgradeViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

protocol UpgradeViewDelegate{
	func setupApp(didUpgrade:Bool)
}

class UpgradeViewController: UIViewController {
	
	var upgradeDelegate: CaptureViewController!
	
	@IBAction func upgradeToPro(_ sender:Any){
		
		Core.shared.setDidUpgrade(value: true)
		upgradeDelegate.setupApp(didUpgrade: true)
		dismiss(animated: true, completion: nil)
		print("Upgraded to Pro")
	}
	
	
}


