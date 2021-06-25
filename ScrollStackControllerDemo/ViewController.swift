//
//  ViewController.swift
//  ScrollStackControllerDemo
//
//  Created by Daniele Margutti on 04/10/2019.
//  Copyright © 2019 ScrollStackController. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ScrollStackControllerDelegate {


    @IBOutlet public var contentView: UIView!

    private var stackController = ScrollStackViewController()
    
    public var stackView: ScrollStack {
        return stackController.scrollStack
    }
    
    
    private var tagsVC: TagsVC!
    private var welcomeVC: WelcomeVC!
    private var galleryVC: GalleryVC!
    private var pricingVC: PricingVC!
    private var notesVC: NotesVC!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func scrollStackRowDidUpdateLayout(_ stackView: ScrollStack) {
        debugPrint("New content insets \(stackView.contentSize.height)")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        stackController.view.frame = contentView.bounds
        contentView.addSubview(stackController.view)
        
        
        stackView.stackDelegate = self
        // Prepare content
        
        welcomeVC = WelcomeVC.create()
        tagsVC = TagsVC.create(delegate: self)
        galleryVC = GalleryVC.create()
        pricingVC = PricingVC.create(delegate: self)
        notesVC = NotesVC.create(delegate: self)
        
        /*stackView.isSeparatorHidden = false
        stackView.separatorColor = .red
        stackView.separatorThickness = 3
        stackView.autoHideLastRowSeparator = true
        */
        
        /*
         Plain UIView example
         let plainView = UIView(frame: .zero)
         plainView.backgroundColor = .green
         plainView.heightAnchor.constraint(equalToConstant: 300).isActive = true
         stackView.addRow(view: plainView)
        */
        stackView.addRows(controllers: [welcomeVC, notesVC, tagsVC, galleryVC, pricingVC], animated: false)
    }
    
    @IBAction public func addNewRow() {
        let galleryVC = GalleryVC.create()
        stackView.scrollToTop()
        stackView.addRow(controller: galleryVC, at: .top, animated: true)
    }
    
    @IBAction public func hideOrShowRandomRow() {
        //let randomRow = Int.random(in: 0..<stackView.rows.count)
        let newRowStatus = !stackView.rows[0].isHidden
        stackView.setRowHidden(index: 0, isHidden: newRowStatus, animated: true)
    }
    
    @IBAction public func moveRowToRandom() {
       // let randomSrc = Int.random(in: 0..<stackView.rows.count)
        let randomDst = Int.random(in: 1..<stackView.rows.count)
        stackView.moveRow(index: 0, to: randomDst, animated: true, completion: nil)
    }
    
    @IBAction public func removeRow() {
      //  let randomRow = Int.random(in: 0..<stackView.rows.count)
        stackView.removeRow(index: 0, animated: true)
    }
    
    @IBAction public func toggleAxis() {
        stackView.toggleAxis(animated: false)
    }
    
    @IBAction public func scrollToRandom() {
        let randomRow = Int.random(in: 0..<stackView.rows.count)
        stackView.scrollToRow(index: randomRow, at: .middle, animated: true)
    }
    
    
    func scrollStackDidScroll(_ stackView: ScrollStack, offset: CGPoint) {
        
    }
    
    func scrollStackRowDidBecomeVisible(_ stackView: ScrollStack, row: ScrollStackRow, index: Int, state: ScrollStack.RowVisibility) {
        
    }
    
    func scrollStackRowDidBecomeHidden(_ stackView: ScrollStack, row: ScrollStackRow, index: Int, state: ScrollStack.RowVisibility) {
        
    }
    
    func scrollStackDidUpdateLayout(_ stackView: ScrollStack) {
        
    }
    
    func scrollStackContentSizeDidChange(_ stackView: ScrollStack, from oldValue: CGSize, to newValue: CGSize) {
        // debugPrint("Content size did change from \(oldValue) to \(newValue)")
    }
    
}

extension ViewController: TagsVCProtocol {
    
    func toggleTags() {
        let index = stackView.rowForController(tagsVC)!.index
        tagsVC.isExpanded = !tagsVC.isExpanded
        stackView.reloadRow(index: index, animated: true)
    }
    
}

extension ViewController: PricingVCProtocol {
    
    func addFee() {
        let otherFee = PricingTag(title: "Another fee", subtitle: "Some spare taxes", price: "$50.00")
        pricingVC.addFee(otherFee)
        let index = stackView.rowForController(pricingVC)!.index
        stackView.reloadRow(index: index, animated: true)
    }
    
}

extension ViewController: NotesVCProtocol {
    
}
