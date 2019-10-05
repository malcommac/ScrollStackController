//
//  VC1.swift
//  ScrollStackControllerDemo
//
//  Created by Daniele Margutti on 04/10/2019.
//  Copyright © 2019 ScrollStackController. All rights reserved.
//

import UIKit

public class VC1: UIViewController, ScrollStackContainableController {
    
    private var bestSize = CGFloat.random(in: 100..<500)
    
    public static func create(backColor: UIColor) -> VC1 {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "VC1") as! VC1
        vc.view.backgroundColor = backColor
        return vc
    }
    
    public func sizeForAxis(_ axis: NSLayoutConstraint.Axis, row: ScrollStackRow, in stackView: ScrollStack) -> CGFloat? {
        return bestSize
    }
    
}
