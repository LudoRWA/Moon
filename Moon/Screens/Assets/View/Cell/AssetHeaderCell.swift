//
//  AssetHeaderCell.swift
//  Moon
//
//  Created by Ludovic ROULLIER on 04/01/2022.
//

import UIKit
import NVActivityIndicatorView

class AssetHeaderCell: UITableViewHeaderFooterView {
    
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var childContentView: UIView!
    @IBOutlet weak var totalFloorOrAverageLabel: UILabel!
    @IBOutlet weak var totalEthAmountLabel: UILabel!
    @IBOutlet weak var totalFiatAmountLabel: UILabel!
    @IBOutlet weak var syncButtonView: UIView!
    @IBOutlet weak var syncIconImageView: UIImageView!
    @IBOutlet weak var syncIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var syncProgressView: UIProgressView!
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    var callSyncAction : (() -> Void)?
    var callSwitchAction : (() -> Void)?
    
    var headerViewModel: AssetHeaderViewModel? {
        didSet {
            totalFloorOrAverageLabel.text = headerViewModel?.totalAmountText
            totalEthAmountLabel.text = headerViewModel?.totalAmountEth
            totalFiatAmountLabel.text = headerViewModel?.totalAmountFiat
            progress = headerViewModel?.progress
        }
    }
    
    var progress: Float? = 0.0 {
        didSet {
            if let progress = progress, oldValue != progress {
                syncProgressView.progress = progress
                if (progress > 0.0) {
                    if (oldValue == 0.0) {
                        syncIndicatorView.startAnimating()
                        syncIndicatorView.alpha = 1.0
                        UIView.animate(withDuration: 0.5) {
                            self.syncIconImageView.alpha = 0.0
                            self.syncProgressView.alpha = 1.0
                        }
                    }
                } else {
                    UIView.animate(withDuration: 0.5) {
                        self.syncIconImageView.alpha = 1.0
                        self.syncIndicatorView.alpha = 0.0
                        self.syncProgressView.alpha = 0.0
                    } completion: { Bool in
                        self.syncIndicatorView.stopAnimating()
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let startSync = UITapGestureRecognizer(target: self, action: #selector(startSync))
        syncButtonView.addGestureRecognizer(startSync)
        
        let switchAmount = UITapGestureRecognizer(target: self, action: #selector(switchTotalAmount))
        childContentView.addGestureRecognizer(switchAmount)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mainContentView.layer.cornerRadius = 26
        syncButtonView.layer.cornerRadius = syncButtonView.frame.height/2
    }
    
    @objc func startSync() {
        callSyncAction?()
    }
    
    @objc func switchTotalAmount() {
        callSwitchAction?()
    }
}
