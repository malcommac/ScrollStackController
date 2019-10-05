//
//  ViewController.swift
//  ScrollStackControllerDemo
//
//  Created by Daniele Margutti on 04/10/2019.
//  Copyright © 2019 ScrollStackController. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet public var contentView: UIView!

    private var stackController = ScrollStackViewController()
    
    private var listVCs = [
        VC1.create(backColor: .red),
        VC1.create(backColor: .orange),
        VC1.create(backColor: .yellow),
        VC1.create(backColor: .purple)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        stackController.view.frame = contentView.bounds
        contentView.addSubview(stackController.view)
        
        listVCs.forEach {
            stackController.stackView.addRow(controller: $0)
        }
        
    }

    @IBAction public func toggleAxis() {
        let stackView = stackController.stackView
        
//        let randomVC = VC2.create(backColor: UIColor.random())
//        let position = Int.random(in: 0..<stackView.rows.count)
//        stackView.addRow(controller: randomVC, at: .atIndex(position), animated: true)
        
        (stackView.rows[0].controller as! VC1).bestSize = 50
        (stackView.rows[1].controller as! VC1).bestSize = 30
        stackController.stackView.reloadRows(indexes: [0,1], animated: true)
        
        
//        stackController.stackView.setRowHidden(index: 0, isHidden: true, animated: true)
        //  stackController.stackView.replaceRowAtIndex(1, withRow: otherVC, animated: true)
 //       stackController.stackView.moveRowAtIndex(1, to: 2, animated: true)
        //stackController.stackView.axis = (stackController.stackView.axis == .horizontal ? .vertical : .horizontal)
    }
    
}

