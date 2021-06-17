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

open class ScrollStack: UIScrollView, UIScrollViewDelegate {
    
    // MARK: Default Properties
    
    private static let defaultRowInsets = UIEdgeInsets(
        top: 12,
        left: UITableView().separatorInset.left,
        bottom: 12,
        right: UITableView().separatorInset.left
    )
    
    private static let defaultRowPadding: UIEdgeInsets = .zero
    
    public static let defaultSeparatorInset: UIEdgeInsets = UITableView().separatorInset
    public static let defaultSeparatorColor = (UITableView().separatorColor ?? .clear)
    public static let defaultRowColor = UIColor.clear
    public static let defaultRowHighlightColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    
    /// Cached content size for did change content size callback in scrollstack delegate.
    private var cachedContentSize: CGSize = .zero
    
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
    
    /// Return all visible (partially or enterly) rows.
    public var visibleRows: [ScrollStackRow]? {
        return rows.enumerated().compactMap { (idx, item) in
            return (isRowVisible(index: idx).isVisible ? item : nil)
        }
    }
    
    /// Return only entirly visible rows.
    public var enterlyVisibleRows: [ScrollStackRow]? {
        return rows.enumerated().compactMap { (idx, item) in
            return (isRowVisible(index: idx) == .entire ? item : nil)
        }
    }
    
    /// Return `true` if no rows are into the stack.
    public var isEmpty: Bool {
        return rows.isEmpty
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
    
    /// Padding for rows `contentView` (the view of the view controller handled by row).
    open var rowPadding: UIEdgeInsets = ScrollStack.defaultRowPadding {
        didSet {
            rows.forEach { row in
                row.rowPadding = rowPadding
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
            updateRowsSeparatorVisibility()
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
    
    // MARK: Delegates
    
    /// Delegate event.
    /// If you set it to non `nil` value class will take the `UIScrollViewDelegate` events
    /// for its own.
    public weak var stackDelegate: ScrollStackControllerDelegate? {
        didSet {
            self.delegate = (stackDelegate != nil ? self : nil)
        }
    }
    
    // MARK: Private Properties
    
    /// Store the previous visibility state of the rows.
    private var prevVisibilityState = [ScrollStackRow: RowVisibility]()

    /// Event to monitor row changes
    internal var onChangeRow: ((_ row: ScrollStackRow, _ isRemoved: Bool) -> Void)?
       
    /// Innert stack view.
    public let stackView = UIStackView()
    
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
    
    // MARK: - Set Rows
    
    /// Remove all existing rows and put in place the new list based upon passed controllers.
    ///
    /// - Parameter controllers: controllers to set.
    @discardableResult
    open func setRows(controllers: [UIViewController]) -> [ScrollStackRow] {
        removeAllRows(animated: false)
        return addRows(controllers: controllers)
    }
    
    /// Remove all existing rows and put in place the new list based upon passed views.
    ///
    /// - Parameter views: views to set.
    @discardableResult
    open func setRows(views: [UIView]) -> [ScrollStackRow] {
        removeAllRows(animated: false)
        return addRows(views: views)
    }
    
    // MARK: - Insert Rows
    
    /// Insert a new to manage passed view without associated controller.
    ///
    /// - Parameters:
    ///   - view: view to add. It will be added as contentView of the row.
    ///   - location: location inside the stack of the new row.
    ///   - animated: `true` to animate operation, by default is `false`.
    ///   - completion: completion: optional completion callback to call at the end of insertion.
    @discardableResult
    open func addRow(view: UIView, at location: InsertLocation = .bottom, animated: Bool = false, completion: (() -> Void)? = nil) -> ScrollStackRow? {
        guard let index = indexForLocation(location) else {
            return nil
        }
        
        return createRowForView(view, insertAt: index, animated: animated, completion: completion)
    }
    
    /// Add new rows for each passed view.
    ///
    /// - Parameter controllers: controllers to add as rows.
    /// - Parameter location: location inside the stack of the new row.
    /// - Parameter animated: `true` to animate operatio, by default is `false`.
    @discardableResult
    open func addRows(views: [UIView], at location: InsertLocation = .bottom, animated: Bool = false) -> [ScrollStackRow] {
        enumerateItems(views, insertAt: location) {
            addRow(view: $0, at: location, animated: animated)
        }
    }
    
    
    /// Insert a new row to manage passed controller instance.
    ///
    /// - Parameter controller: controller to manage; it's `view` will be added as contentView of the row.
    /// - Parameter location: location inside the stack of the new row.
    /// - Parameter animated: `true` to animate operation, by default is `false`.
    /// - Parameter completion: optional completion callback to call at the end of insertion.
    @discardableResult
    open func addRow(controller: UIViewController, at location: InsertLocation = .bottom, animated: Bool = false, completion: (() -> Void)? = nil) -> ScrollStackRow? {
        guard let index = indexForLocation(location) else {
            return nil
        }
        
        return createRowForController(controller, insertAt: index, animated: animated, completion: completion)
    }
    
    /// Add new rows for each passed controllers.
    ///
    /// - Parameter controllers: controllers to add as rows.
    /// - Parameter location: location inside the stack of the new row.
    /// - Parameter animated: `true` to animate operatio, by default is `false`.
    @discardableResult
    open func addRows(controllers: [UIViewController], at location: InsertLocation = .bottom, animated: Bool = false) -> [ScrollStackRow] {
        enumerateItems(controllers, insertAt: location) {
            addRow(controller: $0, at: location, animated: animated)
        }
    }
    
    // MARK: - Reload Rows
    
    /// Perform a reload method by updating any constraint of the stack view's row.
    /// If row's managed controller implements `ScrollStackContainableController` it also call
    /// the reload event.
    ///
    /// - Parameter index: index of the row to reload.
    /// - Parameter animated: `true` to animate reload (any constraint change).
    /// - Parameter completion: optional completion callback to call.
    open func reloadRow(index: Int, animated: Bool = false, completion: (() -> Void)? = nil) {
        reloadRows(indexes: [index], animated: animated, completion: completion)
    }
    
    /// Perform a reload method on multiple rows.
    ///
    /// - Parameter indexes: indexes of the rows to reload.
    /// - Parameter animated: `true` to animate reload (any constraint change).
    /// - Parameter completion:  optional completion callback to call.
    open func reloadRows(indexes: [Int], animated: Bool = false, completion: (() -> Void)? = nil) {
        let selectedRows = safeRowsAtIndexes(indexes)
        reloadRows(selectedRows, animated: animated, completion: completion)
    }
    
    /// Reload all rows of the stack view.
    ///
    /// - Parameter animated: `true` to animate reload (any constraint change).
    /// - Parameter completion: optional completion callback to call.
    open func reloadAllRows(animated: Bool = false, completion: (() -> Void)? = nil) {
        reloadRows(rows, animated: animated, completion: completion)
    }

    // MARK: - Remove Rows
    
    /// Remove all rows currently in place into the stack.
    ///
    /// - Parameter animated: `true` to perform animated removeal, by default is `false`.
    open func removeAllRows(animated: Bool = false) {
        rows.forEach {
            removeRowFromStackView($0, animated: animated)
        }
    }
    
    /// Remove specified row.
    ///
    /// - Parameter row: row instance to remove.
    /// - Parameter animated: `true` to perform animation to remove item, by default is `false`.
    @discardableResult
    open func removeRow(index: Int, animated: Bool = false) -> UIViewController? {
        guard let row = safeRowAtIndex(index) else {
            return nil
        }
        return removeRowFromStackView(row, animated: animated)
    }
    
    /// Remove passed rows.
    ///
    /// - Parameter rowIndexes: indexes of the row to remove.
    /// - Parameter animated: `true` to animate the removeal, by default is `false`.
    @discardableResult
    open func removeRows(indexes rowIndexes: [Int], animated: Bool = false) -> [UIViewController]? {
        return rowIndexes.compactMap {
            return removeRowFromStackView(safeRowAtIndex($0), animated: animated)
        }
    }
    
    /// Replace an existing row with another new row which manage passed view.
    ///
    /// - Parameters:
    ///   - sourceIndex: row to replace.
    ///   - view: view to use as `contentView` of the row.
    ///   - animated: `true` to animate the transition.
    ///   - completion: optional callback called at the end of the transition.
    open func replaceRow(index sourceIndex: Int, withRow view: UIView, animated: Bool = false, completion: (() -> Void)? = nil) {
        doReplaceRow(index: sourceIndex, createRow: { (index, animated) -> ScrollStackRow in
            return self.createRowForView(view, insertAt: index, animated: animated)
        }, animated: animated, completion: completion)
    }
    
    /// Replace an existing row with another new row which manage passed controller.
    ///
    /// - Parameter row: row to replace.
    /// - Parameter controller: view controller to replace.
    /// - Parameter animated: `true` to animate the transition.
    /// - Parameter completion: optional callback called at the end of the transition.
    open func replaceRow(index sourceIndex: Int, withRow controller: UIViewController, animated: Bool = false, completion: (() -> Void)? = nil) {
        doReplaceRow(index: sourceIndex, createRow: { (index, animated) in
            return self.createRowForController(controller, insertAt: sourceIndex, animated: false)
        }, animated: animated, completion: completion)
    }
    
    
    /// Move the row at given index to another index.
    /// If one of the indexes is not valid nothing is made.
    ///
    /// - Parameter sourceIndex: source index.
    /// - Parameter destIndex: destination index.
    /// - Parameter animated: `true` to animate the transition.
    /// - Parameter completion: optional callback called at the end of the transition.
    open func moveRow(index sourceIndex: Int, to destIndex: Int, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard sourceIndex >= 0, sourceIndex < rows.count, destIndex < rows.count else {
            return
        }
        
        let sourceRow = rows[sourceIndex]
        
        func executeMoveRow() {
            if sourceRow == stackView.arrangedSubviews.first {
                sourceRow.removeFromSuperview()
            }
            stackView.insertArrangedSubview(sourceRow, at: destIndex)
            postInsertRow(sourceRow, animated: false)
            stackView.setNeedsLayout()
        }
        
        guard animated else {
            executeMoveRow()
            completion?()
            return
        }
        
        UIView.execute(executeMoveRow, completion: completion)
    }
    
    // MARK: Show/Hide Rows
    
    /// Hide/Show row from the stack.
    /// Row is always on stack and it's returned from the `rows` property.
    ///
    /// - Parameter rowIndex: target row index.
    /// - Parameter isHidden: `true` to hide the row, `false` to make it visible.
    /// - Parameter animated: `true` to perform animated transition.
    /// - Parameter completion: completion callback called once the operation did finish.
    open func setRowHidden(index rowIndex: Int, isHidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        guard let row = safeRowAtIndex(rowIndex) else {
            return
        }
        
        guard animated else {
            row.isHidden = isHidden
            return
        }
        
        guard row.isHidden != isHidden else {
            return
        }
        
        let coordinator = ScrollStackRowAnimator(row: row, toHidden: isHidden, internalHandler: {
            row.isHidden = isHidden
            row.layoutIfNeeded()
        })
        coordinator.execute()
    }
    
    /// Hide/Show selected rows.
    /// Rows is always on stack and it's returned from the `rows` property.
    ///
    /// - Parameter rowIndexes: indexes of the row to hide or show.
    /// - Parameter isHidden: `true` to hide the row, `false` to make it visible.
    /// - Parameter animated: `true` to perform animated transition.
    /// - Parameter completion: completion callback called once the operation did finish.
    open func setRowsHidden(indexes rowIndexes: [Int], isHidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        rowIndexes.forEach {
            setRowHidden(index: $0, isHidden: isHidden, animated: animated)
        }
    }
    
    // MARK: - Row Appearance
    
    /// Return the first row which manages a controller of given type.
    ///
    /// - Parameter type: type of controller to get
    open func firstRowForControllerOfType<T: UIViewController>(_ type: T.Type) -> ScrollStackRow? {
        return rows.first {
            if let _ = $0.controller as? T {
                return true
            }
            return false
        }
    }
    
    /// Return the row associated with passed `UIView` instance and its index into the `rows` array.
    ///
    /// - Parameter view: target view (the `contentView` of the associated `ScrollStackRow` instance).
    open func rowForView(_ view: UIView) -> (index: Int, cell: ScrollStackRow)? {
        guard let index = rows.firstIndex(where: {
            $0.contentView == view
        }) else {
            return nil
        }
        
        return (index, rows[index])
    }
    
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
    open func setRowInsets(index rowIndex: Int, insets: UIEdgeInsets) {
        safeRowAtIndex(rowIndex)?.rowInsets = insets
    }
    
    /// Set the insets of the row's content related to the parent row cell.
    ///
    /// - Parameter row: target rows.
    /// - Parameter insets: new insets.
    open func setRowsInsets(indexes rowIndexes: [Int], insets: UIEdgeInsets) {
        rowIndexes.forEach {
            setRowInsets(index: $0, insets: insets)
        }
    }
    
    /// Set the padding of the row's content related to parent row cell.
    ///
    /// - Parameter row: target row.
    /// - Parameter padding: new insets.
    open func setRowPadding(index rowIndex: Int, padding: UIEdgeInsets) {
        safeRowAtIndex(rowIndex)?.rowPadding = padding
    }
    
    /// Set the padding of the row's content related to the parent row cell.
    ///
    /// - Parameter row: target rows.
    /// - Parameter insets: new padding.
    open func setRowPadding(indexes rowIndexes: [Int], padding: UIEdgeInsets) {
        rowIndexes.forEach {
            setRowPadding(index: $0, padding: padding)
        }
    }
    
    /// Return the visibility status of a row.
    ///
    /// - Parameter index: index of the row to check.
    open func isRowVisible(index: Int) -> RowVisibility {
        guard let row = safeRowAtIndex(index), row.isHidden == false else {
            return .hidden
        }
        
        return rowVisibilityType(row: row)
    }
    
    /// Return `true` if row is currently hidden.
    ///
    /// - Parameter row: row to check.
    open func isRowHidden(index: Int) -> Bool {
        return safeRowAtIndex(index)?.isHidden ?? false
    }
    
    // MARK: - Scroll
    
    /// Scroll to the passed row.
    ///
    /// - Parameter rowIndex: index of the row to make visible.
    /// - Parameter location: visibility of the row, location of the center point.
    /// - Parameter animated: `true` to perform animated transition.
    open func scrollToRow(index rowIndex: Int, at position: ScrollPosition = .automatic,  animated: Bool = true) {
        guard let row = safeRowAtIndex(rowIndex) else {
            return
        }
        
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
    
    /// Invert axis of scroll.
    ///
    /// - Parameter animated: `true` to animate operation.
    /// - Parameter completion: completion callback.
    open func toggleAxis(animated: Bool = false, completion: (() -> Void)? = nil) {
        UIView.execute(animated: animated, {
            self.axis = (self.axis == .horizontal ? .vertical : .horizontal)
        }, completion: completion)
    }
    
    // MARK: - Private Functions
    
    private func doReplaceRow(index sourceIndex: Int, createRow handler: @escaping ((Int, Bool) -> ScrollStackRow), animated: Bool, completion: (() -> Void)? = nil) {
        guard sourceIndex >= 0, sourceIndex < rows.count else {
            return
        }
        
        let sourceRow = rows[sourceIndex]
        guard animated else {
            removeRow(index: sourceRow.index!)
            _ = handler(sourceIndex, false)
            return
        }
        
        stackView.setNeedsLayout()
        
        UIView.execute({
            sourceRow.isHidden = true
        }) {
            let newRow = handler(sourceIndex, false)
            newRow.isHidden = true
            UIView.execute({
                newRow.isHidden = false
            }, completion: completion)
        }
    }
    
    /// Enumerate items to insert into the correct order based upon the location of destination.
    ///
    /// - Parameters:
    ///   - list: list to enumerate.
    ///   - location: insert location.
    ///   - callback: callback to call on enumrate.
    private func enumerateItems<T>(_ list: [T], insertAt location: InsertLocation, callback: ((T) -> ScrollStackRow?)) -> [ScrollStackRow] {
        switch location {
            case .top:
                return list.reversed().compactMap(callback).reversed() // double reversed() is to avoid strange behaviour when additing rows on tops.
            
            default:
                return list.compactMap(callback)
            
        }
    }
    
    /// Return the destination index for passed location. `nil` if index is not valid.
    ///
    /// - Parameter location: location.
    private func indexForLocation(_ location: InsertLocation) -> Int? {
        switch location {
            case .top:
                return 0
            
            case .bottom:
                return rows.count
            
            case .atIndex(let index):
                return index
            
            case .after(let controller):
                guard let index = rowForController(controller)?.index else {
                    return nil
                }
                return ((index + 1) >= rows.count ? rows.count : (index + 1))
            
            case .afterView(let view):
                guard let index = rowForView(view)?.index else {
                    return nil
                }
                return ((index + 1) >= rows.count ? rows.count : (index + 1))
            
            case .before(let controller):
                guard let index = rowForController(controller)?.index else {
                    return nil
                }
                return index
            
            case .beforeView(let view):
                guard let index = rowForView(view)?.index else {
                    return nil
                }
                return index
        }
    }
    
    /// Initial configuration of the control.
    private func setupUI() {
        backgroundColor = .white
        
        // Create stack view and add it to the scrollview
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        backgroundColor = .white
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
    
    /// Reload selected rows of the stackview.
    ///
    /// - Parameter rows: rows to reload.
    /// - Parameter animated: `true` to animate reload.
    /// - Parameter completion: completion callback to call at the end of the reload.
    private func reloadRows(_ rows: [ScrollStackRow], animated: Bool = false, completion: (() -> Void)? = nil) {
        guard rows.isEmpty == false else {
            return
        }
        
        rows.forEach {
            ($0.controller as? ScrollStackContainableController)?.reloadContentFromStackView(stackView: self, row: $0, animated: animated)
            $0.askForCutomizedSizeOfContentView(animated: animated)
        }
        
        UIView.execute(animated: animated, {
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
    /// Get the row at specified index; if index is invalid `nil` is returned.
    ///
    /// - Parameter index: index of the row to get.
    private func safeRowAtIndex(_ index: Int) -> ScrollStackRow? {
        return safeRowsAtIndexes([index]).first
    }
    
    /// Get the rows at specified indexes, invalid indexes are ignored.
    ///
    /// - Parameter indexes: indexes of the rows to get.
    private func safeRowsAtIndexes(_ indexes: [Int]) -> [ScrollStackRow] {
        return indexes.compactMap { index in
            guard index >= 0, index < rows.count else {
                return nil
            }
            return rows[index]
        }
    }
    
    /// Get the row visibility type for a specific row.
    ///
    /// - Parameter row: row to get.
    private func rowVisibilityType(row: ScrollStackRow) -> RowVisibility {
        let rowFrame = convert(row.frame, to: self)
        guard bounds.intersects(rowFrame) else {
            return .offscreen
        }
        
        return (bounds.contains(rowFrame) ? .entire : .partial)
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
                
        // Animate visibility
        let removedController = row.controller
        animateCellVisibility(row, animated: animated, hide: true, completion: { [weak self] in
            guard let self = self else { return }
            
            self.onChangeRow?(row, true)

            row.removeFromStackView()

            // When removing a cell the cell above is the only cell whose separator visibility
            // will be affected, so we need to update its visibility.
            self.updateRowsSeparatorVisibility()
            
            // Remove from the status
            self.prevVisibilityState.removeValue(forKey: row)
        })

        return removedController
    }
    
    /// Create a new row to handle passed view and insert it at specified index.
    ///
    /// - Parameters:
    ///   - view: view to use as `contentView` of the row.
    ///   - index: position of the new row with controller's view.
    ///   - animated: `true` to animate transition.
    ///   - completion:  completion callback called when operation is finished.
    @discardableResult
    private func createRowForView(_ view: UIView, insertAt index: Int, animated: Bool, completion: (() -> Void)? = nil) -> ScrollStackRow {
        // Identify any other cell with the same controller
        let cellToRemove = rowForView(view)?.cell
        
        // Create the new container cell for this view.
        let newRow = ScrollStackRow(view: view, stackView: self)
        return createRow(newRow, at: index, cellToRemove: cellToRemove, animated: animated, completion: completion)
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
        return createRow(newRow, at: index, cellToRemove: cellToRemove, animated: animated, completion: completion)
    }
    
    /// Private implementation to add new row.
    private func createRow(_ newRow: ScrollStackRow, at index: Int,
                           cellToRemove: ScrollStackRow?,
                           animated: Bool, completion: (() -> Void)? = nil) -> ScrollStackRow {
        onChangeRow?(newRow, false)
        stackView.insertArrangedSubview(newRow, at: index)
        
        // Remove any duplicate cell with the same view
        removeRowFromStackView(cellToRemove)
        
        postInsertRow(newRow, animated: animated, completion: completion)
        
        if animated {
            UIView.execute({
                self.layoutIfNeeded()
            }, completion: nil)
        }
        
        scrollViewDidScroll(self)
        
        return newRow
    }
    
    private func postInsertRow(_ row: ScrollStackRow, animated: Bool, completion: (() -> Void)? = nil) {
        updateRowsSeparatorVisibility() // update visibility of the separators
        animateCellVisibility(row, animated: animated, hide: false, completion: completion) // Animate visibility of the cell
    }
    
    /// Update the separator visibility.
    ///
    /// - Parameter row: row target.
    private func updateRowsSeparatorVisibility() {
        let rows = stackView.arrangedSubviews as? [ScrollStackRow] ?? []
        for (idx, row) in rows.enumerated() {
            row.separatorView.isHidden = (idx == rows.last?.index ? true : row.isSeparatorHidden)
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
    
    // MARK: - Row Animated Transitions
    
    private func animateCellVisibility(_ cell: ScrollStackRow, animated: Bool, hide: Bool, completion: (() -> Void)? = nil) {
        if hide {
            animateCellToInvisibleState(cell, animated: animated, hide: hide, completion: completion)
        } else {
            animateCellToVisibleState(cell, animated: animated, hide: hide, completion: completion)
        }
    }
    
    /// Animate transition of the cell to visible state.
    private func animateCellToVisibleState(_ row: ScrollStackRow, animated: Bool, hide: Bool, completion: (() -> Void)? = nil) {
        guard animated else {
            row.alpha = 1.0
            row.isHidden = false
            completion?()
            return
        }
        
        row.alpha = 0.0
        layoutIfNeeded()
        UIView.execute({
            row.alpha = 1.0
        }, completion: completion)
    }
    
    /// Animate transition of the cell to invisibile state.
    private func animateCellToInvisibleState(_ row: ScrollStackRow, animated: Bool, hide: Bool, completion: (() -> Void)? = nil) {
        UIView.execute(animated: animated, {
            row.isHidden = true
        }, completion: completion)
    }
    
    // MARK: - Axis Change Events
    
    /// Update the constraint due to axis change of the stack view.
    ///
    /// - Parameter axis: new axis.
    private func didChangeAxis(_ axis: NSLayoutConstraint.Axis) {
        didUpdateStackViewAxisTo(axis)
        didReflectAxisChangeToRows(axis)
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
    
    private func didReflectAxisChangeToRows(_ axis: NSLayoutConstraint.Axis) {
        rows.forEach {
            $0.separatorAxis = (axis == .horizontal ? .vertical : .horizontal)
        }
    }
    
    private func dispatchRowsVisibilityChangesTo(_ delegate: ScrollStackControllerDelegate) {
        delegate.scrollStackDidScroll(self, offset: contentOffset)
        
        rows.enumerated().forEach { (idx, row) in
            let current = isRowVisible(index: idx)
            if let previous = prevVisibilityState[row] {
                switch (previous, current) {
                case (.offscreen, .partial), // row will become invisible
                     (.hidden, .partial),
                     (.hidden, .entire):
                    delegate.scrollStackRowDidBecomeVisible(self, row: row, index: idx, state: current)
                    
                case (.partial, .offscreen), // row will become visible
                     (.partial, .hidden),
                     (.entire, .hidden):
                    delegate.scrollStackRowDidBecomeHidden(self, row: row, index: idx, state: current)

                default:
                    break
                }
            }
            
            // store previous state
            prevVisibilityState[row] = current
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
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let stackDelegate = stackDelegate else {
            return
        }
        
        dispatchRowsVisibilityChangesTo(stackDelegate)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let stackDelegate = stackDelegate else {
            return
        }
        
        stackDelegate.scrollStackDidUpdateLayout(self)
        
        if cachedContentSize != self.contentSize {
            stackDelegate.scrollStackContentSizeDidChange(self, from: cachedContentSize, to: contentSize)
        }
        cachedContentSize = self.contentSize
    }
    
}
