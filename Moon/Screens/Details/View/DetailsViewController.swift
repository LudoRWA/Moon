//
//  DetailsViewController.swift
//  Moon
//
//  Created by Ludovic ROULLIER on 07/01/2022.
//

import UIKit
import Nuke
import Gifu
import SwiftMessages

class DetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var assetsCollectionView: UICollectionView!
    @IBOutlet weak var nftNameLabel: UILabel!
    @IBOutlet weak var collectionView: UIView!
    @IBOutlet weak var collectionImageView: GIFImageView!
    @IBOutlet weak var collectionNameLabel: UILabel!
    @IBOutlet weak var collectionDescriptionTextView: UITextView!
    @IBOutlet weak var pagerView: UIView!
    @IBOutlet weak var pagerLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    
    lazy var viewModel = { DetailsViewModel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        setCollectionInformations()
    }
    
    func initView() {
        let popGestureRecognizer = navigationController?.interactivePopGestureRecognizer
        if let targets = popGestureRecognizer?.value(forKey: "targets") as? NSMutableArray {
            let gestureRecognizer = UIPanGestureRecognizer()
            gestureRecognizer.setValue(targets, forKey: "targets")
            view.addGestureRecognizer(gestureRecognizer)
        }
        
        assetsCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    func setCollectionInformations() {
        //asset is passed in the segue
        if let asset = viewModel.asset {
            collectionNameLabel.text = asset.collectionName
            collectionDescriptionTextView.text = asset.collectionDescription
            
            let pipeline = ImagePipeline.shared
            let request = ImageRequest(url: URL(string: asset.collectionImageURL ?? ""))
            
            if let image = pipeline.cache[request] {
                return display(image)
            }
            
            pipeline.loadImage(with: request) { [weak self] result in
                if case let .success(response) = result {
                    self?.display(response.container)
                }
            }
            
            setNFTInformations(currentRow: self.viewModel.currentCollectionViewIndex)
        }
    }
    
    func setNFTInformations(currentRow: Int) {
        
        let cellViewModel = viewModel.getCellViewModel(at: currentRow)
        nftNameLabel.text = cellViewModel.name
        
        if (viewModel.nftCellViewModels.count > 1) {
            pagerLabel.text = cellViewModel.pager
            
            UIView.animate(withDuration: 0.25, animations: {
                
                self.pagerView.alpha = 1
            }, completion: { finished in
                
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hidePager), object: nil)
                self.perform(#selector(self.hidePager), with: nil, afterDelay: 2.0)
            })
        }
    }
    
    private func display(_ container: Nuke.ImageContainer) {
        if let data = container.data {
            collectionImageView.animate(withGIFData: data)
        } else {
            collectionImageView.image = container.image
        }
    }
    
    //MARK: - UICollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.asset?.nfts.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  NFTCell.identifier, for: indexPath) as? NFTCell else { fatalError("xib does not exists") }
        cell.cellViewModel = viewModel.getCellViewModel(at: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGFloat(collectionView.bounds.width)
        return CGSize(width: cellSize, height: cellSize)
    }
    
    //MARK: - Scroll related
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let center = view.convert(assetsCollectionView.center, to: assetsCollectionView)
        if assetsCollectionView.indexPathForItem(at: center) != nil {
            
            let row = assetsCollectionView.indexPathForItem(at: center)?.row ?? 0
            if (row != viewModel.currentCollectionViewIndex) {
                
                viewModel.currentCollectionViewIndex = row
                setNFTInformations(currentRow: row)
            }
        }
    }
    
    @objc func hidePager() {
        UIView.animate(withDuration: 0.25, animations: {
            self.pagerView.alpha = 0
        })
    }
    
    //MARK: - UIButton Action
    @IBAction func copyItemLink(_ sender: Any) {
        
        UIPasteboard.general.string = viewModel.asset?.nfts[viewModel.currentCollectionViewIndex].nftPermalink
        
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.success)
        view.configureDropShadow()
		view.configureContent(title: "", body: "Alert.Success.Link.Copied".localized)
        view.button?.isHidden = true
        SwiftMessages.show(view: view)
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - Style
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backButton.layer.cornerRadius = backButton.frame.height/2
        collectionView.layer.cornerRadius = 12
        collectionImageView.layer.cornerRadius = collectionImageView.frame.height/2
        pagerView.layer.cornerRadius = 12
        copyButton.layer.cornerRadius = 16
    }
}
