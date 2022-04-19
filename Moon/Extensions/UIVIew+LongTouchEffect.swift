//
//  UIVIew+LongTouchEffect.swift
//  Moon
//
//  Created by Ludovic Roullier on 16/04/2022.
//

import Foundation
import UIKit

class longTouchEffectView: UIView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.allowUserInteraction, .curveEaseOut], animations: {
            touches.first?.view?.transform = CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95)
        }, completion: nil)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.allowUserInteraction, .curveEaseOut], animations: {
            touches.first?.view?.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
        }, completion: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [UIView.AnimationOptions.allowUserInteraction, .curveEaseOut], animations: {
            touches.first?.view?.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
        }, completion: nil)
    }
}
