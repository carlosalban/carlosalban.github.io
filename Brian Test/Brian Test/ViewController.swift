//
//  ViewController.swift
//  Brian Test
//
//  Created by Carlos Alban on 12/13/16.
//  Copyright © 2016 ShopStyle. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
	
	struct TextViewData {
		// this would be stored on server
		
		let text: String
		let font: UIFont?
		let center: CGPoint
		let size: CGSize
		// either save the transform or save the constraints
		// this example saves the transform
		let transform: CGAffineTransform
		let constraints: [NSLayoutConstraint]?
	}
	
	var textView: UITextView?
	var tapGesture: UITapGestureRecognizer!
	let fontSize: CGFloat = 20
	let textViewPadding: CGFloat = 4
	
	var button: UIButton!
	var lastView: TextViewData?
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTouchScreen))
		tapGesture.numberOfTapsRequired = 1
		view.addGestureRecognizer(tapGesture)
		
		button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(button)
		button.setTitle("Recreate Last View", for: .normal)
		button.backgroundColor = UIColor.gray
		button.addTarget(self, action: #selector(ViewController.redrawLastView), for: .touchUpInside)
		
		// Button Constraints
		button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		button.topAnchor.constraint(equalTo: view.topAnchor, constant: 30.0).isActive = true
		button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
		button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.2).isActive = true
	}
	
	func didTouchScreen(gesture: UITapGestureRecognizer) {
		let touchPoint = gesture.location(in: view)
		addTextView(at: touchPoint)
	}
	
	func fakeTransform() {
		let transform = CGAffineTransform(scaleX: 1.5, y: 1.5).translatedBy(x: 100, y: 50).rotated(by: CGFloat.pi / 4)
		textView?.transform = transform
	}
	
	func createTextView() {
		textView = UITextView()
		textView?.backgroundColor = UIColor.black.withAlphaComponent(0.1)
		// unwrap stuff, im lazy
		view.addSubview(textView!)
	}
	
	func clearTextView() {
		if textView != nil {
			textView?.removeFromSuperview()
			textView = nil
		}
	}
	
	func addTextView(at point: CGPoint) {
		clearTextView()
		createTextView()
		guard let textView = textView else {
			return
		}
		let textViewWidth = view.bounds.width
		let textViewHeight = fontSize + textViewPadding
		let center = CGPoint(x: point.x, y: point.y)
		debugPrint("starting center is: \(point)")
		
		textView.center = center
		textView.bounds.size = CGSize(width: textViewWidth, height: textViewHeight)
		textView.text = "Carlos loves beer."
		
		weak var weakSelf = self
		UIView.animate(withDuration: 1.0, animations: { () -> Void in
			weakSelf?.fakeTransform()
		}, completion: { (success) -> Void in
			weakSelf?.saveTextView()
		})
	}
	
	func saveTextView() {
		// save this data to the server
		lastView = TextViewData(text: textView?.text ?? "", font: textView?.font, center: (textView?.center)!, size: (textView?.bounds.size)!, transform: textView?.transform ?? CGAffineTransform.identity, constraints: nil)
	}

	func redrawLastView() {
		guard let lastView = lastView else {
			print("first create a view")
			return
		}
		clearTextView()
		createTextView()
		debugPrint("final center is: \(lastView.center)")
		
		weak var weakSelf = self
		UIView.animate(withDuration: 1.0, animations: { () -> Void in
			print("drawing last view")
			weakSelf?.textView?.text = "Recreated: " + lastView.text
			weakSelf?.textView?.frame.size = lastView.size // this must be set before the center
			weakSelf?.textView?.center = lastView.center
			weakSelf?.textView?.transform = lastView.transform
		}, completion: { (success) -> Void in
			print("done recreating!")
		})
	}
}

