//
//  Extensions.swift
//  ImageSelectTest
//
//  Created by Stoo on 17/9/20.
//  Copyright © 2020 Stoo. All rights reserved.
//

import UIKit



extension UIApplication {
	static var statusBarHeight: CGFloat {
		var statusBarHeight: CGFloat = 0
		if #available(iOS 13.0, *) {
			let window = shared.windows.filter { $0.isKeyWindow }.first
			statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
		} else {
			statusBarHeight = shared.statusBarFrame.height
		}
		return statusBarHeight
	}
}

extension UIViewController: UIContextMenuInteractionDelegate {
	public func contextMenuInteraction(
	_ interaction: UIContextMenuInteraction,
	configurationForMenuAtLocation location: CGPoint)
	  -> UIContextMenuConfiguration? {
	return UIContextMenuConfiguration(
	  identifier: nil,
	  previewProvider: nil,
	  actionProvider: { _ in
		let children: [UIMenuElement] = []
		return UIMenu(title: "", children: children)
	})
  }
}

extension UICollectionView {
	func setEmptyView(image:String, title: String, message: String) {
		let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
		let titleImageView = UIImageView()
		let titleLabel = UILabel()
		let messageLabel = UILabel()
		
		titleImageView.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let halfWidth = emptyView.frame.width/2
		let homeSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 100, weight: .light)
		let homeImage = UIImage(systemName: image, withConfiguration: homeSymbolConfiguration)
		titleImageView.bounds.size = CGSize(width: halfWidth, height: halfWidth)
		titleImageView.tintColor = .label
		titleImageView.contentMode = .scaleAspectFit
		titleImageView.image = homeImage
		
		titleLabel.textColor = UIColor.label
		titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
		
		messageLabel.textColor = UIColor.secondaryLabel
		messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
		
		emptyView.addSubview(titleImageView)
		emptyView.addSubview(titleLabel)
		emptyView.addSubview(messageLabel)
		
		titleImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20).isActive = true
		titleImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
		titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
		messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
		messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
		messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
		titleLabel.text = title
		messageLabel.text = message
		messageLabel.numberOfLines = 0
		messageLabel.textAlignment = .center
		// The only tricky part is here:
		self.backgroundView = emptyView
	}
	
	func restore() {
		self.backgroundView = nil
	}
}
extension UITableView {
	func setEmptyView(image:String, title: String, message: String) {
		let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
		let titleImageView = UIImageView()
		let titleLabel = UILabel()
		let messageLabel = UILabel()
		
		titleImageView.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let halfWidth = emptyView.frame.width/2
		let homeSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 100, weight: .light)
		let homeImage = UIImage(systemName: image, withConfiguration: homeSymbolConfiguration)
		titleImageView.bounds.size = CGSize(width: halfWidth, height: halfWidth)
		titleImageView.tintColor = .label
		titleImageView.contentMode = .scaleAspectFit
		titleImageView.image = homeImage
		
		titleLabel.textColor = UIColor.label
		titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
		
		messageLabel.textColor = UIColor.secondaryLabel
		messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
		
		emptyView.addSubview(titleImageView)
		emptyView.addSubview(titleLabel)
		emptyView.addSubview(messageLabel)
		
		titleImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20).isActive = true
		titleImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
		titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
		messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
		messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
		messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
		titleLabel.text = title
		messageLabel.text = message
		messageLabel.numberOfLines = 0
		messageLabel.textAlignment = .center
		// The only tricky part is here:
		self.backgroundView = emptyView
		self.separatorStyle = .none
	}
	
	func restore() {
		self.backgroundView = nil
		self.separatorStyle = .singleLine
	}
}

extension UIView {
    public func removeAllConstraints() {
        var _superview = self.superview
        
        while let superview = _superview {
            for constraint in superview.constraints {
                
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }
                
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }
            
            _superview = superview.superview
        }
		self.translatesAutoresizingMaskIntoConstraints = true
        self.removeConstraints(self.constraints)
        
    }
	 func takeScreenshot() -> UIImage {
		 
		 //begin
		 UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
		 
		 // draw view in that context.
		 drawHierarchy(in: self.bounds, afterScreenUpdates: true)
		 
		 // get iamge
		 let image = UIGraphicsGetImageFromCurrentImageContext()
		 UIGraphicsEndImageContext()
		 
		 if image != nil {
			 return image!
		 }
		 
		 return UIImage()
		 
	 }
	func showBlankView(image:String, title: String, message: String) {
		let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
		let titleImageView = UIImageView()
		let titleLabel = UILabel()
		let messageLabel = UILabel()
		
		titleImageView.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let halfWidth = emptyView.frame.width/2
		let homeSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 100, weight: .light)
		let homeImage = UIImage(systemName: image, withConfiguration: homeSymbolConfiguration)
		titleImageView.bounds.size = CGSize(width: halfWidth, height: halfWidth)
		titleImageView.tintColor = .label
		titleImageView.contentMode = .scaleAspectFit
		titleImageView.image = homeImage
		
		titleLabel.textColor = UIColor.label
		titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
		
		messageLabel.textColor = UIColor.secondaryLabel
		messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
		
		emptyView.addSubview(titleImageView)
		emptyView.addSubview(titleLabel)
		emptyView.addSubview(messageLabel)
		
		titleImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20).isActive = true
		titleImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
		titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
		messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
		messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
		messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
		titleLabel.text = title
		messageLabel.text = message
		messageLabel.numberOfLines = 0
		messageLabel.textAlignment = .center
		// The only tricky part is here:
		emptyView.tag = 99
		
		self.addSubview(emptyView)
		self.sendSubviewToBack(emptyView)
		Core.shared.setConstraintPins(view: emptyView, parentview: self, asLeading: 0, trailing: 0, top: 0, bottom: 0)
	}
	
	func removeBlankView() {
		//remove subviews
		if self.subviews.contains(viewWithTag(99)!){
			viewWithTag(99)?.removeFromSuperview()
		}
	}
	
	
	 
 }

extension Date {
	func isBetween(_ date1: Date, and date2: Date) -> Bool {
		return (min(date1, date2) ... max(date1, date2)) ~= self
	}
}

extension CGAffineTransform{
	var scale: CGFloat{
		return sqrt(CGFloat(a * a + c * c))
	}
	
}

enum ShakeDirection {
	case Horizontal, Vertical
}

extension UIView {
	func shake(times: Int, direction: ShakeDirection) {
		shake(times: times, iteration: 0, direction: 1, shakeDirection: direction, delta: 10, speed: 0.08)
	}
	private func shake(times: Int, iteration: Int, direction: CGFloat, shakeDirection: ShakeDirection, delta: CGFloat, speed: TimeInterval) {
		UIView.animate(withDuration: speed, animations: { () -> Void in
			self.layer.setAffineTransform((shakeDirection == ShakeDirection.Horizontal) ? CGAffineTransform(translationX: delta * direction, y: 0) : CGAffineTransform(translationX: 0, y: delta * direction))
			}) { (finished: Bool) -> Void in
				if iteration >= times {
					UIView.animate(withDuration: speed, animations: { () -> Void in
						self.layer.setAffineTransform(CGAffineTransform.identity)
					})
					return
				}
			self.shake(times: (times - 1), iteration: (iteration + 1), direction: (direction * -1), shakeDirection: shakeDirection, delta: delta, speed: speed)
		}
	}
}

