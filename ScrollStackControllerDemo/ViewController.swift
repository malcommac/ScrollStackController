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
    
    public var stackView: ScrollStack {
        return stackController.stackView
    }
    
    
    private var tagsVC: TagsVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        stackController.view.frame = contentView.bounds
        contentView.addSubview(stackController.view)
        
        // Prepare content
        
        tagsVC = TagsVC.create(delegate: self)
        stackView.addRow(controller: tagsVC, at: .top, animated: false)
    }

    @IBAction public func toggleAxis() {
        
//        (stackView.rows[0].controller as! VC1).bestSize = 50
//        (stackView.rows[1].controller as! VC1).bestSize = 30
//        stackController.stackView.reloadRows(indexes: [0,1], animated: true)
        
        
//        stackController.stackView.setRowHidden(index: 0, isHidden: true, animated: true)
        //  stackController.stackView.replaceRowAtIndex(1, withRow: otherVC, animated: true)
 //       stackController.stackView.moveRowAtIndex(1, to: 2, animated: true)
        //stackController.stackView.axis = (stackController.stackView.axis == .horizontal ? .vertical : .horizontal)
    }
    
}

extension ViewController: TagsVCProtocol {
    
    func toggleTags() {
        tagsVC.isExpanded = !tagsVC.isExpanded
        stackView.reloadRow(index: 0, animated: true)
    }
    
}
