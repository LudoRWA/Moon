//
//  WelcomeViewController.swift
//  Moon
//
//  Created by Ludovic ROULLIER on 11/01/2022.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    
    lazy var viewModel = { WelcomeViewModel() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViewModel()
    }
    
    func initViewModel() {
        viewModel.login = { [weak self] animated, wallets in

            if let assetsViewController = self?.storyboard?.instantiateViewController(withIdentifier: "Assets") as? AssetsViewController {
                
                assetsViewController.viewModel.setWallets(wallets)
                
                let navController = UINavigationController(rootViewController: assetsViewController)
                navController.modalPresentationStyle = .fullScreen
                navController.navigationBar.isHidden = true
                
                self?.present(navController, animated: animated, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.getWallets()
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addWallet") {
            if let addWalletVC = segue.destination as? AddWalletViewController {
				addWalletVC.welcomeViewController = self
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addButton.layer.cornerRadius = 22
    }
}
