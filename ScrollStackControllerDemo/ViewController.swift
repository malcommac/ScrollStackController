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
    
    @IBAction public func addNewRow() {
        let galleryVC = GalleryVC.create()
        stackView.addRow(controller: galleryVC, at: .bottom, animated: true)
    }
    
    @IBAction public func hideOrShowRandomRow() {
        let randomRow = Int.random(in: 0..<stackView.rows.count)
        let newRowStatus = !stackView.rows[randomRow].isHidden
        stackView.setRowHidden(index: randomRow, isHidden: newRowStatus, animated: true)
    }
    
    @IBAction public func moveRowToRandom() {
        let randomSrc = Int.random(in: 0..<stackView.rows.count)
        let randomDst = Int.random(in: 0..<stackView.rows.count)
        stackView.moveRow(index: randomSrc, to: randomDst, animated: true, completion: nil)
    }
    
    @IBAction public func removeRow() {
        let randomRow = Int.random(in: 0..<stackView.rows.count)
        stackView.removeRow(index: randomRow, animated: true)
    }
    
    @IBAction public func toggleAxis() {
        stackView.toggleAxis(animated: true)
    }
    
    @IBAction public func scrollToRandom() {
        let randomRow = Int.random(in: 0..<stackView.rows.count)
        stackView.scrollToRow(index: randomRow, at: .middle, animated: true)
    }
}

extension ViewController: TagsVCProtocol {
    
    func toggleTags() {
        tagsVC.isExpanded = !tagsVC.isExpanded
        stackView.reloadRow(index: 0, animated: true)
    }
    
}
