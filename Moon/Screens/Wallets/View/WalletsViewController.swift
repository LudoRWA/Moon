//
//  WalletsViewController.swift
//  Moon
//
//  Created by Ludovic ROULLIER on 12/01/2022.
//

import UIKit

class WalletsViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var mainTableView: UITableView!
    
    lazy var viewModel = { WalletsViewModel() }()
    
    var assetsViewController: AssetsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initViewModel()
    }
    
    func initView() {
        
        isModalInPresentation = true
        mainTableView.register(WalletCell.nib, forCellReuseIdentifier: WalletCell.identifier)
		mainTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        titleLabel.text = String(format: NSLocalizedString("Label.Title.My.Wallet.Plural", comment:  "My Wallet"), viewModel.wallets.count)
    }
    
    func initViewModel() {
        
        viewModel.updateCellsTableView = { [weak self] movedRows, isEmpty in
            DispatchQueue.main.async {
                if (isEmpty) {
                    
                    self?.dismissAction()
                } else {
                    
                    self?.titleLabel.text = String(format: NSLocalizedString("Label.Title.My.Wallet.Plural", comment:  "My Wallet"), self?.viewModel.wallets.count ?? 0)
                    
                    if (self?.mainTableView.window != nil) {
                        self?.updateRows(insertedRows: movedRows.0, deletedRows: movedRows.1)
                    } else {
                        self?.mainTableView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addWallet") {
            if let addWalletVC = segue.destination as? AddWalletViewController {
                addWalletVC.walletsViewController = self
                addWalletVC.viewModel.wallets = viewModel.wallets
            }
        }
    }
    
    //MARK: - Style
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backButton.layer.cornerRadius = backButton.frame.height/2
        addButton.layer.cornerRadius = 16
        logoutButton.layer.cornerRadius = 16
    }
    
    //MARK: - UIButton Action
    @IBAction func backAction(_ sender: Any) {
        dismissAction()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "", message: String(format: NSLocalizedString("Alert.Question.Delete.Wallet.Plural", comment:  "Are you sure you want to delete all your wallets?"), viewModel.wallets.count), preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "Button.Cancel".localized, style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Button.Delete".localized, style: .destructive) { UIAlertAction in
            
            self.viewModel.removeAll()
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    func dismissAction() {
        dismiss(animated: true) {
            if (self.viewModel.shouldUpdateViewController) {
                self.assetsViewController?.viewModel.setWallets(self.viewModel.wallets, forceSync: true)
            }
        }
    }
    
    //MARK: - UITableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WalletCell.identifier, for: indexPath) as? WalletCell else { fatalError("xib does not exists") }
        cell.cellViewModel = viewModel.getCellViewModel(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let alert = UIAlertController(title: "", message: "Alert.Question.Delete.Wallet".localized, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "Button.Cancel".localized, style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Button.Delete".localized, style: .destructive) { UIAlertAction in
            
            let currentWallet = self.viewModel.getCellViewModel(at: indexPath)
            self.viewModel.remove(wallet: currentWallet)
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.wallets.count
    }
    
    func updateRows(insertedRows: [IndexPath], deletedRows: [IndexPath]) {
        mainTableView.beginUpdates()
        mainTableView.insertRows(at: insertedRows, with: .automatic)
        mainTableView.deleteRows(at: deletedRows, with: .automatic)
        mainTableView.endUpdates()
    }
}
