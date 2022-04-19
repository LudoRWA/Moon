//
//  AddWalletViewController.swift
//  Moon
//
//  Created by Ludovic ROULLIER on 11/01/2022.
//

import UIKit
import Alamofire
import JGProgressHUD
import SwiftMessages
import FirebaseCrashlytics

class AddWalletViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pasteButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var walletAddressTextView: textFieldWithPadding!
    @IBOutlet weak var buttonViewConstraint: NSLayoutConstraint!
    
    lazy var viewModel = { AddWalletViewModel() }()
    
    var JGProgress: JGProgressHUD?
    var WelcomeViewController:WelcomeViewController?
    var WalletsViewController:WalletsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView() {
        
        self.isModalInPresentation = true
        
        if (WalletsViewController != nil) {
            
            self.backButton.imageView?.image = UIImage(named: "arrowLeft")
            
            let popGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer
            if let targets = popGestureRecognizer?.value(forKey: "targets") as? NSMutableArray {
                let gestureRecognizer = UIPanGestureRecognizer()
                gestureRecognizer.setValue(targets, forKey: "targets")
                self.view.addGestureRecognizer(gestureRecognizer)
            }
        } else {
            
            self.backButton.imageView?.image = UIImage(named: "arrowBottom")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.walletAddressTextView.becomeFirstResponder()
    }
    
    //MARK: - Keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let height = keyboardSize.height
            let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
            let bottomPadding = window?.safeAreaInsets.bottom
            self.buttonViewConstraint.constant = height + 12 - (bottomPadding ?? 0.0)
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.buttonViewConstraint.constant = 22
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - UIButton Action
    @IBAction func backAction(_ sender: Any) {
        if (WalletsViewController != nil) {
            navigationController?.popToRootViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Actions that leads to addWallet()
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.walletAddressTextView) {
            self.addWallet()
        }
        return true
    }
    
    @IBAction func pastAction(_ sender: Any) {
        self.walletAddressTextView.text = UIPasteboard.general.string
        self.addWallet()
    }
    
    @IBAction func continueAction(_ sender: Any) {
        self.addWallet()
    }
    
    func addWallet() {
        
        self.JGProgress = JGProgressHUD(style: .dark)
        self.JGProgress?.interactionType = .blockNoTouches
        self.JGProgress?.show(in: self.view)
        
        viewModel.addWallet(address: self.walletAddressTextView.text) { success, newWallet, error in
            
            DispatchQueue.main.async {
                
                if let wallet = newWallet, success {
                    if (self.WalletsViewController != nil) {
                        
                        self.WalletsViewController?.viewModel.addWallet(wallet: wallet)
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        
                        self.dismiss(animated: true) {
                            self.WelcomeViewController?.viewModel.getWallets(true)
                        }
                    }
                } else if let error = error {
                    
                    let view = MessageView.viewFromNib(layout: .cardView)
                    view.configureTheme(.error)
                    view.configureDropShadow()
                    view.configureContent(title: "", body: error)
                    view.button?.isHidden = true
                    SwiftMessages.show(view: view)
                }
                
                self.JGProgress?.dismiss(animated: true)
            }
        }
    }
    
    //MARK: - Style
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.backButton.layer.cornerRadius = self.backButton.frame.height/2
        self.continueButton.layer.cornerRadius = 16
        self.walletAddressTextView.layer.cornerRadius = 12
    }
}
