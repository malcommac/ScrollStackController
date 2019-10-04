/*
    * ScrollStackController
    * Create complex scrollable layout using UIViewController and simplify your code
    *
    * Created by:     Daniele Margutti
    * Email:          hello@danielemargutti.com
    * Web:            http://www.danielemargutti.com
    * Twitter:        @danielemargutti
    *
    * Copyright © 2019 Daniele Margutti
    *
    *
    * Permission is hereby granted, free of charge, to any person obtaining a copy
    * of this software and associated documentation files (the "Software"), to deal
    * in the Software without restriction, including without limitation the rights
    * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    * copies of the Software, and to permit persons to whom the Software is
    * furnished to do so, subject to the following conditions:
    *
    * The above copyright notice and this permission notice shall be included in
    * all copies or substantial portions of the Software.
    *
    * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    * THE SOFTWARE.
    *
*/

import UIKit

open class ScrollStack: UIScrollView {
    
    // MARK: Default Properties
    
    private static let defaultRowInsets = UIEdgeInsets(
        top: 12,
        left: UITableView().separatorInset.left,
        bottom: 12,
        right: UITableView().separatorInset.left
    )
    
    public static let defaultSeparatorInset: UIEdgeInsets = UITableView().separatorInset
    public static let defaultSeparatorColor = UIColor.red//(UITableView().separatorColor ?? .clear)
    public static let defaultRowColor = UIColor.clear
    public static let defaultRowHighlightColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)

    // MARK: Public Properties
    
    /// The direction that rows are laid out in the stack view and scrolling works.
    /// By default direction is set to `.vertical`.
    open var axis: NSLayoutConstraint.Axis {
        get {
            return stackView.axis
        }
        set {
            stackView.axis = newValue
            didChangeAxis(newValue)
        }
    }
    
    // MARK: Public Properties (Rows)
    
    /// Rows currently active into the
    public var rows: [ScrollStackRow] {
        // swiftlint:disable force_cast
        return stackView.arrangedSubviews.filter {
            $0 is ScrollStackRow
        } as! [ScrollStackRow]
    }
    
    /// Get the first row of the stack, if any.
    open var firstRow: ScrollStackRow? {
        return rows.first
    }
    
    /// Get the last row of the stack, if any.
    open var lastRow: ScrollStackRow? {
        return rows.last
    }
    
    // MARK: Public Properties (Appearance)
    
    /// Set whether the layout margins of the superview should be included.
    /// iPad and iPhone have different layout margins and it allows to take care of it without
    /// having to set them directly.
     open override var preservesSuperviewLayoutMargins: Bool {
       didSet {
           stackView.preservesSuperviewLayoutMargins = preservesSuperviewLayoutMargins
           stackView.isLayoutMarginsRelativeArrangement = preservesSuperviewLayoutMargins
       }
     }
    
    /// Insets for rows.
    open var rowInsets: UIEdgeInsets = ScrollStack.defaultRowInsets {
        didSet {
            rows.forEach { row in
                row.rowInsets = rowInsets
            }
        }
    }
    
    /// The color of separators in the stack view.
    /// You can set property for a single separator by setting new value inside the row's `separatoView`.
    open var separatorColor = ScrollStack.defaultSeparatorColor {
        didSet {
            rows.forEach { row in
                row.separatorView.color = separatorColor
            }
        }
    }
    
    /// The thickness of the separator, by default is `1`.
    /// You can set property for a single separator by setting new value inside the row's `separatoView`.
    open var separatorThickness: CGFloat = 1.0 {
      didSet {
        rows.forEach { row in
            row.separatorView.thickness = separatorThickness
        }
      }
    }
    
    /// The insets of the separators.
    /// Default value is the `ScrollStack.defaultSeparatorInsets`.
    /// You can set property for a single separator by setting new value inside the row's `separatoView`.
    open var separatorInsets: UIEdgeInsets = ScrollStack.defaultSeparatorInset {
      didSet {
        rows.forEach { row in
            row.separatorInsets = separatorInsets
        }
      }
    }
    
    /// Hides or show separators.
    /// You can set property for a single separator by setting new value inside the row's `separatoView`.
    open var isSeparatorHidden: Bool = false {
        didSet {
          rows.forEach { row in
              row.isSeparatorHidden = isSeparatorHidden
          }
        }
    }
    
    /// Hide automatically the last separator.
    open var autoHideLastRowSeparator = false {
        didSet {
            updateRowSeparatorVisibility(lastRow)
        }
    }
    
    /// Hide all separators.
    /// This not necessary reflect the current status of separator (you can also change this property individually per row).
    /// Once you set a new value it will be applied to any new added row and current rows.
    open var hideSeparators = false {
        didSet {
            rows.forEach { row in
                row.isSeparatorHidden = hideSeparators
            }
        }
    }
    
    /// The background color of rows in the stack view.
    /// By default is set to `clear`.
    open var rowBackgroundColor = ScrollStack.defaultRowColor
    
    /// The highlight background color of rows in the stack view.
    /// By default is set to (rgb:0.85,0.85,0.85).
    open var rowHighlightColor = ScrollStack.defaultRowHighlightColor
    
    // MARK: Private Properties
    
    /// Event to monitor row changes
    internal var onChangeRow: ((_ row: ScrollStackRow, _ isRemoved: Bool) -> Void)?
       
    /// Innert stack view.
    private let stackView = UIStackView()
    
    /// Constraints to manage the main axis set.
    private var axisConstraint: NSLayoutConstraint?
        
    // MARK: Initialization
    
    public init() {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Initialization from IB not supported yet!")
    }
    
    // MARK: - Insert Rows
    
    /// Insert a new row to manage passed controller instance.
    ///
    /// - Parameter controller: controller to manage; it's `view` will be added as contentView of the row.
    /// - Parameter location: location inside the stack of the new row.
    /// - Parameter animated: `true` to animate operation, by default is `false`.
    @discardableResult
    open func addRow(controller: UIViewController, at location: InsertLocation = .bottom, animated: Bool = false) -> ScrollStackRow? {
        switch location {
        case .top:
            return createRowForController(controller, insertAt: 0, animated: animated)
            
        case .bottom:
            return createRowForController(controller, insertAt: rows.count, animated: animated)
            
        case .atIndex(let index):
            return createRowForController(controller, insertAt: index, animated: animated)
            
        case .after(let afterController):
            guard let index = rowForController(afterController)?.index else {
                return nil
            }
            
            return createRowForController(controller, insertAt: ((index + 1) >= rows.count ? rows.count : (index + 1)), animated: animated)
            
        case .before(let beforeController):
            guard let index = rowForController(beforeController)?.index else {
                return nil
            }
            
            return createRowForController(controller, insertAt: index, animated: animated)
            
        }
    }
    
    /// Add new rows for each passaed controllers.
    ///
    /// - Parameter controllers: controllers to add as rows.
    /// - Parameter location: location inside the stack of the new row.
    /// - Parameter animated: `true` to animate operatio, by default is `false`.
    @discardableResult
    open func addRows(controllers: [UIViewController], at location: InsertLocation = .bottom, animated: Bool = false) -> [ScrollStackRow] {
        switch location {
        case .top:
            return controllers.reversed().compactMap( {
                addRow(controller: $0, at: .top, animated: animated )
            }).reversed() // double reversed() is to avoid strange behaviour when additing rows on tops.
            
        default:
            return controllers.compactMap {
                addRow(controller: $0, at: location, animated: animated)
            }
            
        }
    }

    // MARK: - Remove Rows
    
    /// Remove all rows currently in place into the stack.
    ///
    /// - Parameter animated: `true` to perform animated removeal, by default is `false`.
    open func removeAllRows(animated: Bool = false) {
        rows.forEach {
            removeRow($0, animated: animated)
        }
    }
    
    /// Remove row at given index and return removed managed controller (if any).
    ///
    /// - Parameter index: index of the row to remove.
    /// - Parameter animated: `true` to perform animation to remove item, by default is `false`.
    @discardableResult
    open func removeRowAtIndex(_ index: Int, animated: Bool = false) -> UIViewController? {
        guard index >= 0, index < rows.count else {
            return nil
        }
        return removeRow(rows[index])
    }
    
    /// Remove specified row.
    ///
    /// - Parameter row: row instance to remove.
    /// - Parameter animated: `true` to perform animation to remove item, by default is `false`.
    @discardableResult
    open func removeRow(_ row: ScrollStackRow, animated: Bool = false) -> UIViewController? {
        return removeRowFromStackView(row, animated: animated)
    }
    
    /// Remove passed rows.
    ///
    /// - Parameter rows: rows to remove.
    /// - Parameter animated: `true` to animate the removeal, by default is `false`.
    @discardableResult
    open func removeRows(_ rows: [ScrollStackRow], animated: Bool = false) -> [UIViewController]? {
        return rows.compactMap {
            return removeRowFromStackView($0, animated: animated)
        }
    }
    
    /// Replace an existing row with another new controller.
    ///
    /// - Parameter row: row to replace.
    /// - Parameter controller: view controller to replace.
    /// - Parameter animated: `true` to animate the transition.
    open func replaceRow(_ row: ScrollStackRow, withRow controller: UIViewController, animated: Bool = false) -> ScrollStackRow? {
        guard let index = rows.firstIndex(of: row) else {
            return nil
        }
        removeRow(row, animated: animated)
        return addRow(controller: controller, at: .atIndex(index), animated: animated)
    }
    
    // MARK: Show/Hide Rows
    
    /// Hide/Show row from the stack.
    /// Row is always on stack and it's returned from the `rows` property.
    ///
    /// - Parameter row: target row.
    /// - Parameter isHidden: `true` to hide the row, `false` to make it visible.
    /// - Parameter animated: `true` to perform animated transition.
    /// - Parameter completion: completion callback called once the operation did finish.
    open func setRowHidden(_ row: ScrollStackRow, isHidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        guard animated else {
            row.isHidden = isHidden
            return
        }
        
        guard row.isHidden != isHidden else {
            return
        }
        
        row.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            row.isHidden = isHidden
            row.layoutIfNeeded()
        }) { isFinished in
            if isFinished {
                completion?()
            }
        }
    }
    
    /// Hide/Show selected rows.
    /// Rows is always on stack and it's returned from the `rows` property.
    ///
    /// - Parameter rows: target rows.
    /// - Parameter isHidden: `true` to hide the row, `false` to make it visible.
    /// - Parameter animated: `true` to perform animated transition.
    /// - Parameter completion: completion callback called once the operation did finish.
    open func setRowsHidden(_ rows: [ScrollStackRow], isHidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        rows.forEach {
            setRowHidden($0, isHidden: isHidden, animated: animated)
        }
    }
    
    // MARK: - Row Appearance
    
    /// Return the row associated with passed `UIViewController` instance and its index into the `rows` array.
    ///
    /// - Parameter controller: target controller.
    open func rowForController(_ controller: UIViewController) -> (index: Int, cell: ScrollStackRow)? {
        guard let index = rows.firstIndex(where: {
            $0.controller === controller
        }) else {
            return nil
        }
        return (index, rows[index])
    }
    
    /// Return `true` if controller is inside the stackview as a row.
    ///
    /// - Parameter controller: controller to check.
    open func containsRowForController(_ controller: UIViewController) -> Bool {
        return rowForController(controller)?.index != nil
    }
    
    /// Return the index of the row.
    /// It return `nil` if row is not part of the stack.
    ///
    /// - Parameter row: row to search for.
    open func indexOfRow(_ row: ScrollStackRow) -> Int? {
        return rows.firstIndex(of: row)
    }
    
    /// Set the insets of the row's content related to parent row cell.
    ///
    /// - Parameter row: target row.
    /// - Parameter insets: new insets.
    open func setRowInsets(_ row: ScrollStackRow, insets: UIEdgeInsets) {
        row.rowInsets = insets
    }
    
    /// Set the ints of the row's content related to the parent row cell.
    ///
    /// - Parameter row: target rows.
    /// - Parameter insets: new insets.
    open func setRowsInsets(_ row: [ScrollStackRow], insets: UIEdgeInsets) {
        row.forEach {
            setRowInsets($0, insets: insets)
        }
    }
    
    /// Return the visibility status of a row.
    ///
    /// - Parameter row: row to check.
    open func isRowVisible(_ row: ScrollStackRow) -> RowVisibility {
        guard row.isHidden == false else {
            return .hidden
        }
        
        let rowFrame = convert(row.frame, to: self)
        guard bounds.intersects(rowFrame) else {
            return .offscreen
        }
        
        return (bounds.contains(rowFrame) ? .entire : .partial)
    }
    
    /// Return `true` if row is currently hidden.
    ///
    /// - Parameter row: row to check.
    open func isRowHidden(_ row: ScrollStackRow) -> Bool {
        return row.isHidden
    }
    
    // MARK: - Scroll
    
    /// Scroll to the passed row.
    ///
    /// - Parameter row: row to make visible.
    /// - Parameter location: visibility of the row, location of the center point.
    /// - Parameter animated: `true` to perform animated transition.
    open func scrollToRow(_ row: ScrollStackRow, at position: ScrollPosition = .automatic,  animated: Bool = true) {
        let rowFrame = convert(row.frame, to: self)
        
        if case .automatic = position {
            scrollRectToVisible(rowFrame, animated: animated)
            return
        }
                
        let offset = adjustedOffsetForFrame(rowFrame, toScrollAt: position)
        setContentOffset(offset, animated: animated)
    }
    
    /// Scroll to top.
    /// - Parameter animated: `true` to perform animated transition.
    open func scrollToTop(animated: Bool = true) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    /// Scroll to bottom.
    /// - Parameter animated: `true` to perform animated transition.
    open func scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if bottomOffset.y > 0 {
            setContentOffset(bottomOffset, animated: animated)
        }
    }
    
    
    // MARK: - Private Functions
    
    /// Initial configuration of the control.
    private func setupUI() {
        backgroundColor = .white
        
        // Create stack view and add it to the scrollview
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        backgroundColor = UIColor.yellow
        addSubview(stackView)
        
        // Configure constraints for stackview
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        didChangeAxis(axis)
    }
    
    /// Remove passed row from stack view.
    ///
    /// - Parameter row: row to remove.
    /// - Parameter animated: `true` to perform animated transition.
    @discardableResult
    private func removeRowFromStackView(_ row: ScrollStackRow?, animated: Bool = false) -> UIViewController? {
        guard let row = row else {
            return nil
        }
        
        let previousRow = rowBeforeRow(row)
        
        // Animate visibility
        let removedController = row.controller
        animateCellVisibility(row, animated: animated, hide: true, completion: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            // When removing a cell the cell above is the only cell whose separator visibility
            // will be affected, so we need to update its visibility.
            self.updateRowSeparatorVisibility(previousRow)
            
            self.onChangeRow?(row, true)
        })
                
        return removedController
    }
    
    /// Create a new row to handle passed controller and insert it at specified index.
    ///
    /// - Parameter controller: controller to manage.
    /// - Parameter index: position of the new row with controller's view.
    /// - Parameter animated: `true` to animate transition.
    /// - Parameter completion: completion callback called when operation is finished.
    @discardableResult
    private func createRowForController(_ controller: UIViewController, insertAt index: Int, animated: Bool, completion: (() -> Void)? = nil) -> ScrollStackRow {
        // Identify any other cell with the same controller to remove
        let cellToRemove = rowForController(controller)?.cell
        
        // Create the new container cell for this controller's view
        let newRow = ScrollStackRow(controller: controller, stackView: self)
        onChangeRow?(newRow, false)
        stackView.insertArrangedSubview(newRow, at: index)
        
        // Remove any duplicate cell with the same view
        removeRowFromStackView(cellToRemove)
        
        // Setup separator visibility for the new cell
        updateRowSeparatorVisibility(newRow)
        
        // A cell can affect the visibility of the cell before it, e.g. if
        // `automaticallyHidesLastSeparator` is true and a new cell is added as the last cell, so update
        // the previous cell's separator visibility as well.
        updateRowSeparatorVisibility(rowBeforeRow(newRow))
        
        // Animate visibility
        animateCellVisibility(newRow, animated: animated, hide: false, completion: completion)
        
        return newRow
    }
    
    private func updateRowSeparatorVisibility(_ row: ScrollStackRow?) {
        guard let row = row, row === stackView.arrangedSubviews.last else {
            return
        }
        
        row.isSeparatorHidden = hideSeparators

        let isLast = (row === rows.last)
        if isLast && autoHideLastRowSeparator {
            row.isSeparatorHidden = true
        }
    }
    
    /// Return the row before a given row, if exists.
    ///
    /// - Parameter row: row to check.
    private func rowBeforeRow(_ row: ScrollStackRow) -> ScrollStackRow? {
        guard let index = stackView.arrangedSubviews.firstIndex(of: row), index > 0 else {
            return nil
        }
        return stackView.arrangedSubviews[index - 1] as? ScrollStackRow
    }
    
    // MARK: - Animated Transition
    
    private func animateCellVisibility(_ cell: ScrollStackRow, animated: Bool, hide: Bool, completion: (() -> Void)? = nil) {
        
        func transitionToVisible() {
            guard animated else {
                cell.alpha = 1.0
                cell.isHidden = false
                completion?()
                return
            }
            
            cell.alpha = 0.0
            layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                cell.alpha = 1.0
            }) { isFinished in
                if isFinished { completion?() }
            }
            
        }
        
        func transitionToInvisible() {
            guard animated else {
                cell.isHidden = true
                completion?()
                return
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                cell.isHidden = true
            }) { isFinished in
                if isFinished { completion?() }
            }
        }
        
        if hide {
            transitionToInvisible()
        } else {
            transitionToVisible()
        }
        
    }
    
    // MARK: - Axis Change Events
    
    private func didChangeAxis(_ axis: NSLayoutConstraint.Axis) {
        didUpdateStackViewAxisTo(axis)
        didUpdateCellAxisTo(axis)
    }
    
    private func didUpdateStackViewAxisTo(_ axis: NSLayoutConstraint.Axis) {
        axisConstraint?.isActive = false
        switch axis {
        case .vertical:
            axisConstraint = stackView.widthAnchor.constraint(equalTo: widthAnchor)
            
        case .horizontal:
            axisConstraint = stackView.heightAnchor.constraint(equalTo: heightAnchor)
            
        @unknown default:
            break
            
        }
        
        rows.forEach {
            $0.layoutUI()
        }
        
        axisConstraint?.isActive = true
    }
    
    private func didUpdateCellAxisTo(_ axis: NSLayoutConstraint.Axis) {
        rows.forEach {
            $0.separatorAxis = (axis == .horizontal ? .vertical : .horizontal)
        }
    }
    
    // MARK: - Private Scroll
    
    private func adjustedOffsetForFrame(_ frame: CGRect, toScrollAt position: ScrollPosition) -> CGPoint {
        var adjustedPoint: CGPoint = frame.origin
        
        switch position {
        case .middle:
            if axis == .horizontal {
                adjustedPoint.x = frame.origin.x - ((bounds.size.width - frame.size.width) / 2.0)
            } else {
                adjustedPoint.y = frame.origin.y - (bounds.size.height - frame.size.height)
            }
            
        case .final:
            if axis == .horizontal {
                adjustedPoint.x = frame.origin.x - (bounds.size.width - frame.size.width)
            } else {
                adjustedPoint.y = frame.origin.y - (bounds.size.height - frame.size.height)
            }
            
        case .initial:
            if axis == .horizontal {
                adjustedPoint.x = frame.origin.x
            } else {
                adjustedPoint.y = frame.origin.y
            }
            
        case .automatic:
            break
            
        }
        
        if axis == .horizontal {
            adjustedPoint.x = max(adjustedPoint.x, 0)
            
            let reachedOffsetx = adjustedPoint.x + self.bounds.size.width
            if reachedOffsetx > self.contentSize.width {
                adjustedPoint.x -= (reachedOffsetx - self.contentSize.width)
            }
        } else {
            adjustedPoint.y = max(adjustedPoint.y, 0)
            
            let reachedOffsetY = adjustedPoint.y + self.bounds.size.height
            if reachedOffsetY > self.contentSize.height {
                adjustedPoint.y -= (reachedOffsetY - self.contentSize.height)
            }
        }
        
        return adjustedPoint
    }
    
}
