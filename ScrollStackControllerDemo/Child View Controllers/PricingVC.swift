//
//  PricingVC.swift
//  ScrollStackControllerDemo
//
//  Created by Daniele Margutti on 05/10/2019.
//  Copyright © 2019 ScrollStackController. All rights reserved.
//

import UIKit

public protocol PricingVCProtocol: class {
    func addFee()
}

public class PricingVC: UIViewController, ScrollStackContainableController {
    
    public weak var delegate: PricingVCProtocol?
    
    @IBOutlet public var pricingTable: UITableView!
    @IBOutlet public var pricingTableHeightConstraint: NSLayoutConstraint!
        
    public var pricingTags: [PricingTag] = [
        PricingTag(title: "Night fee", subtitle: "$750 x 3 nights", price: "$2,250.00"),
        PricingTag(title: "Hospitality fees", subtitle: "This fee covers services that come with the room", price: "$10.00"),
        PricingTag(title: "Property use taxes", subtitle: "Taxes the cost pays to rent their room", price: "$200.00")
    ]
    
    public static func create(delegate: PricingVCProtocol) -> PricingVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "PricingVC") as! PricingVC
        vc.delegate = delegate
        return vc
    }
    
    public func scrollStackRowSizeForAxis(_ axis: NSLayoutConstraint.Axis, row: ScrollStackRow, in stackView: ScrollStack) -> ScrollStack.ControllerSize? {
        return .fitLayoutForAxis
//        let size = CGSize(width: stackView.bounds.size.width, height: 9000)
//        let best = self.view.systemLayoutSizeFitting(size, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
//        // NOTE:
//        // it's important to set both the height constraint and bottom safe constraints to safe area for tableview,
//        // otherwise growing does not work.
//        return best.height
    }
    
    override public func updateViewConstraints() {
        pricingTableHeightConstraint.constant = pricingTable.contentSize.height // the size of the table as the size of its content
        view.height(constant: nil) // cancel any height constraint already in place in the view
        super.updateViewConstraints()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        pricingTable.rowHeight = UITableView.automaticDimension
        pricingTable.estimatedRowHeight = 60
        
        pricingTable.reloadData()
        pricingTable.sizeToFit()
    }
    
    public func addFee(_ otherFee: PricingTag) {
        pricingTags.append(otherFee)
        pricingTable.reloadData()
        updateViewConstraints()
        viewDidLayoutSubviews()
    }
    
    public func reloadContentFromStackView(stackView: ScrollStack, row: ScrollStackRow, animated: Bool) {

    }
    
    @IBAction public func addFee() {
        delegate?.addFee()
    }
    
}

extension PricingVC: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pricingTags.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PricingCell", for: indexPath) as! PricingCell
        cell.priceTag = pricingTags[indexPath.row]
        return cell
    }
    
}

public struct PricingTag {
    public let title: String
    public let subtitle: String
    public let price: String
    
    public init(title: String, subtitle: String, price: String) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
    }
    
}

public class PricingCell: UITableViewCell {
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var subtitleLabel: UILabel!
    @IBOutlet public var priceLabel: UILabel!
    
    public var priceTag: PricingTag? {
        didSet {
            titleLabel.text = priceTag?.title ?? ""
            subtitleLabel.text = priceTag?.subtitle ?? ""
            priceLabel.text = priceTag?.price ?? ""
        }
    }
    
}
