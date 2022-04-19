//
//  NFTCell.swift
//  Moon
//
//  Created by Ludovic ROULLIER on 07/01/2022.
//

import UIKit
import Nuke
import Gifu
import WebKit

class NFTCell: UICollectionViewCell {
    
    @IBOutlet weak var mainContentView: UIView!
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    private var task: ImageTask?
    
    var cellViewModel: NFTCellViewModel? {
        didSet {
            if let image_url = cellViewModel?.image_url {
                setImage(with: image_url)
            }
        }
    }
    
    func setImage(with url: URL) {
        let pipeline = ImagePipeline.shared
        let request = ImageRequest(url: url)
        
        if let image = pipeline.cache[request] {
            return displayImage(image)
        }
        
        ImageDecoderRegistry.shared.register { context in
            let isSVG = context.urlResponse?.url?.absoluteString.hasSuffix(".svg") ?? false
            return isSVG ? ImageDecoders.Empty() : nil
        }
        
        task = pipeline.loadImage(with: request) { [weak self] result in
            if let self = self, case let .success(response) = result {
                if let data = response.container.data, self.isSVG(request: request) {
                    self.displaySVG(data)
                } else {
                    self.displayImage(response.container)
                }
            }
        }
    }
    
    func isSVG(request: ImageRequest) -> Bool {
        return request.urlRequest?.url?.absoluteString.hasSuffix(".svg") ?? false
    }
    
    private func displaySVG(_ data: Data) {
    
        let urlStr = "<html><body style=\"margin: 0;\"><div style=\"width:100%; height:100%; background: url(data:image/svg+xml;base64,\(data.base64EncodedString())) no-repeat center center; -webkit-background-size: contain; -moz-background-size: contain; -o-background-size: contain; background-size: contain;\"></div></body></html>"
        
        var isCreated = false
        for view in mainContentView.subviews {
            if let currentWebView = view as? WKWebView {
                isCreated = true
                currentWebView.loadHTMLString(urlStr, baseURL: nil)
            }
        }
        
        if (!isCreated) {
            let currentWebView = WKWebView(frame: mainContentView.frame)
            currentWebView.isUserInteractionEnabled = false
            currentWebView.isOpaque = false
            currentWebView.backgroundColor = UIColor.clear
            currentWebView.scrollView.backgroundColor = UIColor(named: "colorSecondary")
            mainContentView.addSubview(currentWebView)
            currentWebView.loadHTMLString(urlStr, baseURL: nil)
        }
    }
    
    private func displayImage(_ container: Nuke.ImageContainer) {
        
        var currentImageView: GIFImageView!
        
        var isCreated = false
        for view in mainContentView.subviews {
            if let imageView = view as? GIFImageView {
                isCreated = true
                currentImageView = imageView
            }
        }
        
        if (!isCreated) {
            currentImageView = GIFImageView(frame: mainContentView.frame)
            currentImageView.backgroundColor = UIColor(named: "colorSecondary")
            currentImageView.contentMode = .scaleAspectFit
            mainContentView.addSubview(currentImageView)
        }
        
        if let data = container.data {
            currentImageView.animate(withGIFData: data)
        } else {
            currentImageView.image = container.image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        for view in mainContentView.subviews {
            if let imageView = view as? GIFImageView {
                
                imageView.prepareForReuse()
                imageView.image = nil
            } else if let webView = view as? WKWebView {
                
                webView.loadHTMLString("", baseURL: nil)
            }
        }
    }
    
    deinit {
        mainContentView.subviews.forEach({ $0.removeFromSuperview() })
    }
}
