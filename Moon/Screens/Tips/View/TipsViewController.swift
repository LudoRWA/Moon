//
//  TipsViewController.swift
//  Moon
//
//  Created by Ludovic Roullier on 12/05/2022.
//

import UIKit
import SwiftMessages
import JGProgressHUD

class TipsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var mainCollectionView: UICollectionView!
	
	lazy var viewModel = { TipsViewModel() }()
	var JGProgress: JGProgressHUD?
	
	override func viewDidLoad() {
        super.viewDidLoad()

		initView()
		initViewModel()
    }
	
	func initView() {
		
		JGProgress = JGProgressHUD(style: .dark)
		JGProgress?.interactionType = .blockNoTouches
		
		mainCollectionView.collectionViewLayout = createRowLayout()
		mainCollectionView.register(TipCell.nib, forCellWithReuseIdentifier: TipCell.identifier)
		mainCollectionView.register(TipHeaderCell.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TipHeaderCell.identifier)
		mainCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
	}
	
	func initViewModel() {
		
		viewModel.fetchAvailableProducts()
		viewModel.updateCellsCollectionView = { [weak self] in
			DispatchQueue.main.async {
				self?.mainCollectionView.reloadData()
			}
		}
		viewModel.transaction = { [weak self] result in
			DispatchQueue.main.async {
				
				switch result {
				case .success(_):
					
					var config = SwiftMessages.defaultConfig
					config.duration = .seconds(seconds: 4)
					
					let view = MessageView.viewFromNib(layout: .cardView)
					view.configureTheme(.success)
					view.configureDropShadow()
					view.configureContent(title: "", body: "Alert.Success.Transaction".localized)
					view.button?.isHidden = true
					SwiftMessages.show(config: config, view: view)
					
					let generator = UIImpactFeedbackGenerator(style: .heavy)
					generator.impactOccurred()
					
					SPConfetti.startAnimating(.centerWidthToDown, particles: [.circle, .arc, .heart], duration: 4)
					
				case .failure(let error):
					
					if error != .cancel {
						var config = SwiftMessages.defaultConfig
						config.duration = .seconds(seconds: 6)
					
						let view = MessageView.viewFromNib(layout: .cardView)
						view.configureTheme(.error)
						view.configureDropShadow()
						view.configureContent(title: "", body: error.rawValue.localized)
						view.button?.isHidden = true
						SwiftMessages.show(config: config, view: view)
					}
				}
				
				self?.JGProgress?.dismiss(animated: true)
			}
		}
	}
	
	//MARK: - UICollectionView
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if viewModel.tipCellViewModels.isEmpty {
			return 2
		} else {
			return viewModel.tipCellViewModels.count
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TipCell.identifier, for: indexPath) as? TipCell else { fatalError("xib does not exists") }
		
		if let currentIAP = viewModel.getCellViewModel(at: indexPath) {
			
			cell.cellViewModel = currentIAP
		}

		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let currentIAP = viewModel.getCellViewModel(at: indexPath) {
			JGProgress?.show(in: view)
			viewModel.purchaseProduct(currentIAP.IAPProduct)
		}
	}
	
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TipHeaderCell.identifier, for: indexPath) as? TipHeaderCell else { fatalError("xib does not exists") }
		return header
	}
	
	func createRowLayout() -> UICollectionViewLayout {

		let spacing = CGFloat(12)
		
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
		group.interItemSpacing = .fixed(spacing)
		
		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
		section.interGroupSpacing = spacing
		
		let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(145))
		let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
		section.boundarySupplementaryItems = [headerElement]
		
		let layout = UICollectionViewCompositionalLayout(section: section)
		return layout
	}
	
	//MARK: - UIButton Action
	@IBAction func backAction(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	//MARK: - Style
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		backButton.layer.cornerRadius = backButton.frame.height/2
	}
}
