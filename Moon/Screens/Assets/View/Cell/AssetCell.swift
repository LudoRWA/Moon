//
//  AssetCell.swift
//  Moon
//
//  Created by Ludovic ROULLIER on 04/01/2022.
//

import UIKit
import Gifu
import Nuke

class AssetCell: UITableViewCell {

    @IBOutlet weak var collectionImageView: GIFImageView!
    @IBOutlet weak var collectionTitleLabel: UILabel!
    
    @IBOutlet weak var numbersInCollectionView: UIView!
    @IBOutlet weak var numbersInCollectionLabel: UILabel!
    @IBOutlet weak var priceCollectionView: UIView!
    @IBOutlet weak var priceCollectionLabel: UILabel!
    @IBOutlet weak var mainContentView: UIView!
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    private var task: ImageTask?
    
    var cellViewModel: AssetCellViewModel? {
        didSet {
            collectionTitleLabel.text = cellViewModel?.collectionName
            priceCollectionLabel.text = cellViewModel?.price
            numbersInCollectionLabel.text = cellViewModel?.count
            
            if let collectionImageURL = cellViewModel?.collectionImageURL {
                setImage(with: collectionImageURL)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mainContentView.layer.cornerRadius = 26
        collectionImageView.layer.cornerRadius = collectionImageView.frame.height/2
        numbersInCollectionView.layer.cornerRadius = 12
        priceCollectionView.layer.cornerRadius = 12
    }
    
    func setImage(with url: URL) {
        let pipeline = ImagePipeline.shared
        let request = ImageRequest(url: url)
        
        if let image = pipeline.cache[request] {
            return display(image)
        }
        
        task = pipeline.loadImage(with: request) { [weak self] result in
            if case let .success(response) = result {
                self?.display(response.container)
            }
        }
    }
    
    private func display(_ container: Nuke.ImageContainer) {
        if let data = container.data {
            collectionImageView.animate(withGIFData: data)
        } else {
            collectionImageView.image = container.image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        collectionImageView.prepareForReuse()
        collectionImageView.image = nil
    }
}
