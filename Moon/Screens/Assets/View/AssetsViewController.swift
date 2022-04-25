//
//  AssetsViewController.swift
//  Moon
//
//  Created by Ludovic ROULLIER on 03/01/2022.
//

import UIKit
import SwiftMessages
import WidgetKit

class AssetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var walletButton: UIButton!
    @IBOutlet weak var mainTableView: UITableView!
    
    lazy var viewModel = { AssetsViewModel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initViewModel()
    }
    
    func initView() {
        mainTableView.register(AssetHeaderCell.nib, forHeaderFooterViewReuseIdentifier: AssetHeaderCell.identifier)
        mainTableView.register(AssetCell.nib, forCellReuseIdentifier: AssetCell.identifier)
    }
    
    func initViewModel() {
        viewModel.logout = { [weak self] in
            DispatchQueue.main.async {
                if #available(iOS 14.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                self?.dismiss(animated: true, completion: nil)
            }
        }
        viewModel.updateCellsTableView = { [weak self] movedRows in
            DispatchQueue.main.async {
                if #available(iOS 14.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                if (self?.mainTableView.window != nil) {
                    self?.updateRows(insertedRows: movedRows.0, deletedRows: movedRows.1)
                } else {
                    self?.mainTableView.reloadData()
                }
            }
        }
        viewModel.updateHeaderTableView = { [weak self] assetHeaderViewModel in
            DispatchQueue.main.async {
                if let header = self?.mainTableView.headerView(forSection: 0) as? AssetHeaderCell {
                    header.headerViewModel = assetHeaderViewModel
                }
            }
        }
        viewModel.showErrorMessage = { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    var config = SwiftMessages.defaultConfig
                    config.duration = .seconds(seconds: 6)
                    
                    let view = MessageView.viewFromNib(layout: .cardView)
                    view.configureTheme(.error)
                    view.configureDropShadow()
                    view.configureContent(title: "", body: error)
                    view.button?.isHidden = true
                    SwiftMessages.show(config: config, view: view)
                }
            }
        }
    }
    
    //MARK: - UIButton Action
    @IBAction func openWallet(_ sender: Any) {
        if (!viewModel.isSyncActive) {
            performSegue(withIdentifier: "showWallets", sender: self)
        } else {
            let view = MessageView.viewFromNib(layout: .cardView)
            view.configureTheme(.error)
            view.configureDropShadow()
            view.configureContent(title: "", body: String(format: NSLocalizedString("Alert.Failure.Open.Wallet.Sync", comment:  "You can't access your wallet settings during synchronization."), viewModel.wallets.count))
            view.button?.isHidden = true
            SwiftMessages.show(view: view)
        }
    }
    
    //MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.assetCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AssetCell.identifier, for: indexPath) as? AssetCell else { fatalError("xib does not exists") }
        cell.cellViewModel = viewModel.getCellViewModel(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: AssetHeaderCell.identifier) as? AssetHeaderCell else { fatalError("xib does not exists") }
        header.headerViewModel = viewModel.assetHeaderViewModel
        header.callSyncAction = { [weak self] () -> Void in
            self?.viewModel.startSync()
        }
        header.callSwitchAction = { [weak self] () -> Void in
            self?.viewModel.switchTotalAmount()
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentAsset = viewModel.getCellViewModel(at: indexPath).asset
        performSegue(withIdentifier: "showDetails", sender: currentAsset)
    }
    
    func updateRows(insertedRows: [IndexPath], deletedRows: [IndexPath]) {
        mainTableView.beginUpdates()
        mainTableView.insertRows(at: insertedRows, with: .automatic)
        mainTableView.deleteRows(at: deletedRows, with: .automatic)
        mainTableView.endUpdates()
    }
    
    //MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetails") {
            if let detailsVC = segue.destination as? DetailsViewController, let currentAsset = sender as? Asset {
                detailsVC.viewModel.asset = currentAsset
            }
        }
        
        if (segue.identifier == "showWallets") {
            if let nav = segue.destination as? UINavigationController, let walletsVC = nav.topViewController as? WalletsViewController {
                walletsVC.viewModel.wallets = viewModel.wallets
                walletsVC.AssetsViewController = self
            }
        }
    }
    
    //MARK: - Style
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        walletButton.layer.cornerRadius = walletButton.frame.height/2
    }
}
