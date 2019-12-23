//
//  WelcomeVC.swift
//  ScrollStackController
//
//  Created by Daniele Margutti on 05/10/2019.
//  Copyright © 2019 ScrollStackController. All rights reserved.
//

import UIKit

public class WelcomeVC: UIViewController, ScrollStackContainableController {

    public static func create() -> WelcomeVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "WelcomeVC") as! WelcomeVC
        return vc
    }
    
    public func scrollStackRowSizeForAxis(_ axis: NSLayoutConstraint.Axis, row: ScrollStackRow, in stackView: ScrollStack) -> ScrollStack.ControllerSize? {
       // let size = CGSize(width: stackView.bounds.size.width, height: 9000)
       // let best = self.view.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
       // return best.height
        return .fitLayoutForAxis
    }
    
    public func reloadContentFromStackView(stackView: ScrollStack, row: ScrollStackRow, animated: Bool) {
        
    }
    
}

extension WelcomeVC: ScrollStackRowAnimatable {
    
    public var animationInfo: ScrollStackAnimationInfo {
        return ScrollStackAnimationInfo(duration: 1, delay: 0, springDamping: 0.8)
    }

    public func animateTransition(toHide: Bool) {
        switch toHide {
            case true:
                self.view.transform = CGAffineTransform(translationX: -100, y: 0)
                self.view.alpha = 0
            
            case false:
                self.view.transform = .identity
                self.view.alpha = 1
        }
    }
    
    public func willBeginAnimationTransition(toHide: Bool) {
        if toHide == false {
            self.view.transform = CGAffineTransform(translationX: -100, y: 0)
            self.view.alpha = 0
        }
    }
    
}
