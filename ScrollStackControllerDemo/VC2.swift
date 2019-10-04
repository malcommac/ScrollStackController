//
//  VC2.swift
//  ScrollStackControllerDemo
//
//  Created by Daniele Margutti on 04/10/2019.
//  Copyright © 2019 ScrollStackController. All rights reserved.
//

import UIKit

public class VC2: UIViewController, ScrollStackContainableController {
    
    public static func create(backColor: UIColor) -> VC2 {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "VC2") as! VC2
        vc.view.backgroundColor = backColor
        return vc
    }
    
    public func sizeForAxis(_ axis: NSLayoutConstraint.Axis, row: ScrollStackRow, in stackView: ScrollStack) -> CGFloat? {
        return 140
    }
    
}
