//
//  Notes.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

public class Core {
	
	static let shared = Core()
	
	func isNewUser() -> Bool{
		return !UserDefaults.standard.bool(forKey: "isNewUSer")
	}
	
	func setIsNotNewUser(){
		UserDefaults.standard.setValue(false, forKey: "isNewUser")
		
	}
	
	func didUpgrade() -> Bool{
		return UserDefaults.standard.bool(forKey: "didUpgrade")
	}
	
	func setDidUpgrade(value:Bool){
		UserDefaults.standard.setValue(value, forKey: "didUpgrade")
	}
}


/*
DEFAULTS STUFF

Store

UserDefaults.standard.set(true, forKey: "Key") //Bool
UserDefaults.standard.set(1, forKey: "Key")  //Integer
UserDefaults.standard.set("TEST", forKey: "Key") //setObject

Retrieve

 UserDefaults.standard.bool(forKey: "Key")
 UserDefaults.standard.integer(forKey: "Key")
 UserDefaults.standard.string(forKey: "Key")

Remove

 UserDefaults.standard.removeObject(forKey: "Key")
Remove all Keys

 if let appDomain = Bundle.main.bundleIdentifier {
UserDefaults.standard.removePersistentDomain(forName: appDomain)
 }


*/
