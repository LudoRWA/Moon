//
//  WalletCell.swift
//  Moon
//
//  Created by Ludovic ROULLIER on 12/01/2022.
//

import UIKit

class WalletCell: UITableViewCell {

    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var trashView: UIView!
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    var cellViewModel: WalletRaw? {
        didSet {
            addressLabel.text = cellViewModel?.address
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mainContentView.layer.cornerRadius = 26
        trashView.layer.cornerRadius = trashView.frame.height/2
    }
}
