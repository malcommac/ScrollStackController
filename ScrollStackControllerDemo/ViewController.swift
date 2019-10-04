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
        let otherVC = VC2.create(backColor: .white)
      
        stackController.stackView.setRowHidden(index: 0, isHidden: true, animated: true)
        //  stackController.stackView.replaceRowAtIndex(1, withRow: otherVC, animated: true)
 //       stackController.stackView.moveRowAtIndex(1, to: 2, animated: true)
        //stackController.stackView.axis = (stackController.stackView.axis == .horizontal ? .vertical : .horizontal)
    }
    
}

