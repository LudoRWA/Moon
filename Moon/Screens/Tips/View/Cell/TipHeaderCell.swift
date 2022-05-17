//
//  TipHeaderCell.swift
//  Moon
//
//  Created by Ludovic Roullier on 13/05/2022.
//

import UIKit

class TipHeaderCell: UICollectionReusableView {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	
	class var identifier: String { return String(describing: self) }
	class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let titleString = "Label.Tip.Hello".localized
		let nameTitleString = "Ludo"
		let moonTitleString = "Moon"
		
		let nameRange = (titleString as NSString).range(of: nameTitleString)
		let moonRange = (titleString as NSString).range(of: moonTitleString)
		
		let attributedText = NSMutableAttributedString.init(string: titleString)
		attributedText.addAttribute(.foregroundColor, value: UIColor(named: "colorAccent")!, range: nameRange)
		attributedText.addAttribute(.foregroundColor, value: UIColor(named: "colorAccent")!, range: moonRange)
		
		titleLabel.attributedText = attributedText
	}
}
