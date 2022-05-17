//
//  TipCell.swift
//  Moon
//
//  Created by Ludovic Roullier on 13/05/2022.
//

import UIKit
import Pastel
import SkeletonView

class TipCell: UICollectionViewCell {

	@IBOutlet weak var mainContentView: UIView!
	@IBOutlet weak var priceLabel: UILabel!
	
	class var identifier: String { return String(describing: self) }
	class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
	
	var cellViewModel: TipCellViewModel? {
		didSet {
			priceLabel.text = cellViewModel?.price
			mainContentView.hideSkeleton(transition: .none)
		}
	}
	
	var pastelView = PastelView()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		pastelView.startPastelPoint = .bottomLeft
		pastelView.endPastelPoint = .topRight
		pastelView.animationDuration = 3.0
		pastelView.setColors([UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
							  UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
							  UIColor(red: 111/255, green: 0/255, blue: 249/255, alpha: 1.0)])
		
		pastelView.startAnimation()
		pastelView.isUserInteractionEnabled = false
		mainContentView.insertSubview(pastelView, at: 0)
		
		mainContentView.showAnimatedSkeleton(transition: .none)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		pastelView.frame = mainContentView.bounds
		mainContentView.layer.cornerRadius = 26
	}
}
