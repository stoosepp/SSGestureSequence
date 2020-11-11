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
	
	
	
	func setConstraintPins(view:UIView, parentview:UIView, asLeading:CGFloat,trailing:CGFloat,top:CGFloat,bottom:CGFloat){
		view.translatesAutoresizingMaskIntoConstraints = false
		let margins = parentview.layoutMarginsGuide

		view.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: asLeading).isActive = true
		view.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -trailing).isActive = true
		view.topAnchor.constraint(equalTo: margins.topAnchor, constant: top).isActive = true
		view.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -bottom).isActive = true
	}
	
	func fetchFileURLS() -> [URL]{
		var URLs = [URL]()
		let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

			   do {
				   // Get the directory contents urls (including subfolders urls)
				let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: [.contentModificationDateKey])
				
			
				   // if you want to filter the directory contents you can do like this:
				   let jpgFiles = directoryContents.filter{ $0.pathExtension == "jpg" }
				
				//Sort the Files
				let sortedURLS = jpgFiles.map { url in
							(url, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
						}
						.sorted(by: { $0.1 > $1.1 })
				
				  for file in sortedURLS{
					print("URL is \(file.0)")
					let URLofFile = file.0
					URLs.append(URLofFile)
				  }
			   } catch {
				   print(error)
			   }
			 return URLs
	}
}

struct AppUtility {

	static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
	
		if let delegate = UIApplication.shared.delegate as? AppDelegate {
			delegate.orientationLock = orientation
		}
	}

	/// OPTIONAL Added method to adjust lock and rotate to the desired orientation
	static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
   
		self.lockOrientation(orientation)
	
		UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
		UINavigationController.attemptRotationToDeviceOrientation()
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
