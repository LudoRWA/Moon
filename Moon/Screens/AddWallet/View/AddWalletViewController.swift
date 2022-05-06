//
//  AddWalletViewController.swift
//  Moon
//
//  Created by Ludovic ROULLIER on 11/01/2022.
//

import UIKit
import JGProgressHUD
import SwiftMessages

class AddWalletViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pasteButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var walletAddressTextView: textFieldWithPadding!
    @IBOutlet weak var buttonViewConstraint: NSLayoutConstraint!
    
    lazy var viewModel = { AddWalletViewModel() }()
    
    var JGProgress: JGProgressHUD?
    var welcomeViewController: WelcomeViewController?
    var walletsViewController: WalletsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView() {
        
        isModalInPresentation = true
        
        if (walletsViewController != nil) {
            
            backButton.imageView?.image = UIImage(named: "arrowLeft")
            
            let popGestureRecognizer = navigationController?.interactivePopGestureRecognizer
            if let targets = popGestureRecognizer?.value(forKey: "targets") as? NSMutableArray {
                let gestureRecognizer = UIPanGestureRecognizer()
                gestureRecognizer.setValue(targets, forKey: "targets")
                view.addGestureRecognizer(gestureRecognizer)
            }
        } else {
            
            backButton.imageView?.image = UIImage(named: "arrowBottom")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        walletAddressTextView.becomeFirstResponder()
    }
    
    //MARK: - Keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let height = keyboardSize.height
            let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
            let bottomPadding = window?.safeAreaInsets.bottom
            buttonViewConstraint.constant = height + 12 - (bottomPadding ?? 0.0)
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        buttonViewConstraint.constant = 22
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - UIButton Action
    @IBAction func backAction(_ sender: Any) {
        if (walletsViewController != nil) {
            navigationController?.popToRootViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Actions that leads to addWallet()
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == walletAddressTextView) {
            addWallet()
        }
        return true
    }
    
    @IBAction func pastAction(_ sender: Any) {
        walletAddressTextView.text = UIPasteboard.general.string
        addWallet()
    }
    
    @IBAction func continueAction(_ sender: Any) {
        addWallet()
    }
    
    func addWallet() {
        
        JGProgress = JGProgressHUD(style: .dark)
        JGProgress?.interactionType = .blockNoTouches
        JGProgress?.show(in: view)
        
        viewModel.addWallet(address: self.walletAddressTextView.text) { [weak self] result in
			switch result {
			case .success(let wallet):
				
				DispatchQueue.main.async {
					
					if (self?.walletsViewController != nil) {
							
						self?.walletsViewController?.viewModel.addWallet(wallet: wallet)
						self?.navigationController?.popToRootViewController(animated: true)
					} else {
							
						self?.dismiss(animated: true) {
							self?.welcomeViewController?.viewModel.getWallets(true)
						}
					}
					
					self?.JGProgress?.dismiss(animated: true)
				}
					
			case .failure(let error):
				
				DispatchQueue.main.async {
							
					let view = MessageView.viewFromNib(layout: .cardView)
					view.configureTheme(.error)
					view.configureDropShadow()
					view.configureContent(title: "", body: error.rawValue.localized)
					view.button?.isHidden = true
					SwiftMessages.show(view: view)
						
					self?.JGProgress?.dismiss(animated: true)
				}
			}
        }
    }
    
    //MARK: - Style
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
		backButton.layer.cornerRadius = backButton.frame.height/2
        continueButton.layer.cornerRadius = 16
        walletAddressTextView.layer.cornerRadius = 12
    }
}
