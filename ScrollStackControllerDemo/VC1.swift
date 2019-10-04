//
//  VC1.swift
//  ScrollStackControllerDemo
//
//  Created by Daniele Margutti on 04/10/2019.
//  Copyright © 2019 ScrollStackController. All rights reserved.
//

import UIKit

public class VC1: UIViewController, ScrollStackContainableController {
    
    public static func create() -> VC1 {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: "VC1") as! VC1
    }
    
    public func sizeForAxis(_ axis: NSLayoutConstraint.Axis, row: ScrollStackRow, in stackView: ScrollStack) -> CGFloat? {
        return 100
    }
    
}
