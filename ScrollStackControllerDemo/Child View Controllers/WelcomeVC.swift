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
    
    public func scrollStackRowSizeForAxis(_ axis: NSLayoutConstraint.Axis, row: ScrollStackRow, in stackView: ScrollStack) -> CGFloat? {
        let size = CGSize(width: stackView.bounds.size.width, height: 9000)
        let best = self.view.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        return best.height
    }
    
    public func reloadContentFromStackViewRow() {
        
    }
    
}
