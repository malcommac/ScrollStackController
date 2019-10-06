//
//  TagsVC.swift
//  ScrollStackControllerDemo
//
//  Created by Daniele Margutti on 04/10/2019.
//  Copyright © 2019 ScrollStackController. All rights reserved.
//

import UIKit

public protocol TagsVCProtocol: class {
    func toggleTags()
}

public class TagsVC: UIViewController, ScrollStackContainableController {
    
    @IBOutlet public var collectionView: UICollectionView!
    @IBOutlet public var toggleTagsButton: UIButton!

    private weak var delegate: TagsVCProtocol?
    
    private var tags: [String] = [
        "swimming pool",
        "kitchen",
        "terrace",
        "bathtub",
        "A/C",
        "parking",
        "pet friendly",
        "relax spa",
        "private bathroom",
        "cafe"
    ]
    
    public var isExpanded = false {
        didSet {
            if isExpanded {
                collectionView.height(constant: collectionView.contentSize.height)
            }
            updateUI()
        }
    }
    
    public static func create(delegate: TagsVCProtocol) -> TagsVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "TagsVC") as! TagsVC
        vc.delegate = delegate
        return vc
    }
    
    public func scrollStackRowSizeForAxis(_ axis: NSLayoutConstraint.Axis, row: ScrollStackRow, in stackView: ScrollStack) -> ScrollStack.ControllerSize? {
        return (isExpanded == false ? .fixed(170) : .fixed(170 + collectionView.contentSize.height + 20))
    }
    
    public func reloadContentFromStackView(stackView: ScrollStack, row: ScrollStackRow, animated: Bool) {

    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
        updateUI()
    }
    
    @IBAction public func toggleTags() {
        delegate?.toggleTags()
    }
    
    private func updateUI() {
        toggleTagsButton.setTitle( (isExpanded ? "Hide Tags" : "Show Tags"), for: .normal)
    }
    
}

extension TagsVC: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagsCell", for: indexPath) as! TagsCell
        cell.labelCell.text = tags[indexPath.item]
        return cell
    }
    
}

public class TagsCell: UICollectionViewCell {
    
    @IBOutlet public var labelCell: UILabel!
    
}
