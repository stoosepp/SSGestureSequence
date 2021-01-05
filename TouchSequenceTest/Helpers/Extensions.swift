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
		if let foundView = self.viewWithTag(99) {
			foundView.removeFromSuperview()
		}
		
	}
	
	
	 
 }

extension Date {
	func isBetween(_ date1: Date, and date2: Date) -> Bool {
		return (min(date1, date2) ... max(date1, date2)) ~= self
	}
	
	func formattedString(withFormat:String) -> String{
		let dateFormatterEurope = DateFormatter()
		dateFormatterEurope.dateFormat = "dd/MM/yyyy h:mm:a"

		let dateFormatterNorthAmerica = DateFormatter()
		dateFormatterNorthAmerica.dateFormat = "MM/dd/yyyy h:mm:a"

		var dateString = String()
		if withFormat == "EU"{
			dateString = dateFormatterEurope.string(from: self)
		}
		else if withFormat == "NA"{
			dateString = dateFormatterNorthAmerica.string(from: self)
		}
		return dateString
	}
}

extension TimeInterval{

	func stringFromTimeInterval(withFrameRate:CGFloat) -> String {
		var tempString = ""
	
		let time = NSInteger(self)

		let ms = Int((self.truncatingRemainder(dividingBy: Double(withFrameRate))) * 1000)
		let seconds = time % 60
		let minutes = (time / 60) % 60
			//let hours = (time / 3600)
		if withFrameRate >= 1.0{
			tempString = String(format: "%0.2d:%0.2d",minutes,seconds)
		}
		else{
			tempString = String(format: "%0.2d:%0.2d.%0.3d",minutes,seconds,ms)
		}
		return tempString
	}
	
	
	
	func isBetween(time1:Double, time2:Double) -> Bool{
		return time1...time2 ~= self
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

extension CGFloat {
	func between(a: CGFloat, b: CGFloat) -> Bool {
		return self >= Swift.min(a, b) && self <= Swift.max(a, b)
	}
}

extension DispatchQueue {

	static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
		DispatchQueue.global(qos: .background).async {
			background?()
			if let completion = completion {
				DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
					completion()
				})
			}
		}
	}

}

//MARK: - COREDATA EXTENSIONS
extension Experiment{
	var durationString:String{
		var tempString = ""
		
		let totalDuration:Double = self.totalDuration
		if totalDuration > 60{
			let minutes = Int(totalDuration/60)
			let seconds = Int(totalDuration) - (minutes * 60)
			tempString = ")\(minutes):\(seconds)"
		}
		else{
			tempString = "0:\(Int(totalDuration))"
		}
		return tempString
	}
	
	var totalDuration:Double{
		var tempDuration:Double = 0.0
		self.stimuli!.forEach { (stimulus) in
			let thisStimulus = stimulus as! Stimulus
			tempDuration += Double(thisStimulus.duration)
		}
		return tempDuration
	}
}

extension DataSet{
	var duration:Double{
		return endDate!.timeIntervalSince(startDate!)
	}
	var durationString:String{
		return TimeInterval(duration).stringFromTimeInterval(withFrameRate: 1.0)
	}
}

extension Touch {
	var point:CGPoint{
		return CGPoint(x:CGFloat(xLocation) , y: CGFloat(yLocation))
	}
	var majorRadiusTolerance: CGFloat{
		return 0.0
	}
}

@IBDesignable
class CentreButton:UIButton {
	@IBInspectable var centerText: Bool = false{
	   didSet {
		guard
			let imageViewSize = self.imageView?.frame.size,
			let titleLabelSize = self.titleLabel?.frame.size else {
			return
		}
		
		let totalHeight = imageViewSize.height + titleLabelSize.height + 3
		
		self.imageEdgeInsets = UIEdgeInsets(
			top: -(totalHeight - imageViewSize.height),
			left: 0.0,
			bottom: 0.0,
			right: -titleLabelSize.width
		)
		
		self.titleEdgeInsets = UIEdgeInsets(
			top: 0.0,
			left: -imageViewSize.width,
			bottom: -(totalHeight - titleLabelSize.height),
			right: 0.0
		)
		
		self.contentEdgeInsets = UIEdgeInsets(
			top: 0.0,
			left: 0.0,
			bottom: titleLabelSize.height,
			right: 0.0
		)
	   }
	}
	
	
	
}

extension UIColor {
	func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
		let percentage = max(min(percentage, 100), 0) / 100
		switch percentage {
		case 0: return self
		case 1: return color
		default:
			var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
			var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
			guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
			guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }

			return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
						   green: CGFloat(g1 + (g2 - g1) * percentage),
						   blue: CGFloat(b1 + (b2 - b1) * percentage),
						   alpha: CGFloat(a1 + (a2 - a1) * percentage))
		}
	}
}

extension Array where Element: UIColor {
	func intermediate(percentage: CGFloat) -> UIColor {
		let percentage = Swift.max(Swift.min(percentage, 100), 0) / 100
		switch percentage {
		case 0: return first ?? .clear
		case 1: return last ?? .clear
		default:
			let approxIndex = percentage / (1 / CGFloat(count - 1))
			let firstIndex = Int(approxIndex.rounded(.down))
			let secondIndex = Int(approxIndex.rounded(.up))
			let fallbackIndex = Int(approxIndex.rounded())

			let firstColor = self[firstIndex]
			let secondColor = self[secondIndex]
			let fallbackColor = self[fallbackIndex]

			var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
			var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
			guard firstColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return fallbackColor }
			guard secondColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return fallbackColor }

			let intermediatePercentage = approxIndex - CGFloat(firstIndex)
			return UIColor(red: CGFloat(r1 + (r2 - r1) * intermediatePercentage),
						   green: CGFloat(g1 + (g2 - g1) * intermediatePercentage),
						   blue: CGFloat(b1 + (b2 - b1) * intermediatePercentage),
						   alpha: CGFloat(a1 + (a2 - a1) * intermediatePercentage))
		}
	}
}
