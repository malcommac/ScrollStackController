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

// MARK: - ScrollStackContainableController

/// You can implement the following protocol in your view controller in order
/// to specify explictely (without using autolayout constraints) the best size (width/height depending
/// by the axis) of the controller when inside a scroll stack view.
public protocol ScrollStackContainableController: UIViewController {
    
    /// If you implement this protocol you can manage the size of the controller
    /// when is placed inside a `ScrollStackView`.
    /// This method is also called when scroll stack change the orientation.
    /// You can return `nil` to leave the opportunity to change the size to the
    /// controller's view constraints.
    /// By default it returns `nil`.
    ///
    /// - Parameter axis: axis of the stackview.
    /// - Parameter row: row where the controller is placed.
    /// - Parameter stackView: stackview where the row is placed.
    func scrollStackRowSizeForAxis(_ axis: NSLayoutConstraint.Axis, row: ScrollStackRow, in stackView: ScrollStack) -> ScrollStack.ControllerSize?
    
    /// Method is called when you call a `reloadRow` function on a row where this controller is contained in.
    func reloadContentFromStackView(stackView: ScrollStack, row: ScrollStackRow, animated: Bool)
    
}

// MARK: - ScrollStackControllerDelegate

/// You can implement the following delegate to receive events about row visibility changes during scroll of the stack.
/// NOTE: No events are currently sent at the time of add/remove/move. A PR about is is accepted :-)
public protocol ScrollStackControllerDelegate: AnyObject {
    
    /// Tells the delegate when the user scrolls the content view within the receiver.
    ///
    /// - Parameter stackView: target stack view.
    /// - Parameter offset: current scroll offset.
    func scrollStackDidScroll(_ stackView: ScrollStack, offset: CGPoint)
    
    /// Row did become partially or entirely visible.
    ///
    /// - Parameter row: target row.
    /// - Parameter index: index of the row.
    /// - Parameter state: state of the row.
    func scrollStackRowDidBecomeVisible(_ stackView: ScrollStack, row: ScrollStackRow, index: Int, state: ScrollStack.RowVisibility)
    
    /// Row did become partially or entirely invisible.
    ///
    /// - Parameter row: target row.
    /// - Parameter index: index of the row.
    /// - Parameter state: state of the row.
    func scrollStackRowDidBecomeHidden(_ stackView: ScrollStack, row: ScrollStackRow, index: Int, state: ScrollStack.RowVisibility)
    
    
    /// This function is called when layout is updated (added, removed, hide or show one or more rows).
    /// - Parameter stackView: target stack view.
    func scrollStackDidUpdateLayout(_ stackView: ScrollStack)
    
    /// This function is called when content size of the stack did change (remove/add, hide/show rows).
    ///
    /// - Parameters:
    ///   - stackView: target stack view
    ///   - oldValue: old content size.
    ///   - newValue: new content size.
    func scrollStackContentSizeDidChange(_ stackView: ScrollStack, from oldValue: CGSize, to newValue: CGSize)
    
}

// MARK: - ScrollStackRowHighlightable

/// Indicates that a row into the stackview should be highlighted when the user touches it.
public protocol ScrollStackRowHighlightable {
    
    /// Checked when the user touches down on a row to determine if the row should be highlighted.
    ///
    /// The default implementation of this method always returns `true`.
    var isHighlightable: Bool { get }
    
    /// Called when the highlighted state of the row changes.
    /// Override this method to provide custom highlighting behavior for the row.
    ///
    /// The default implementation of this method changes the background color of the row to the `rowHighlightColor`.
    func setIsHighlighted(_ isHighlighted: Bool)
    
}

extension ScrollStackRowHighlightable where Self: UIView {
    
    public var isHighlightable: Bool {
        return true
    }
    
    public func setIsHighlighted(_ isHighlighted: Bool) {
        guard let row = superview as? ScrollStackRow else {
            return
        }
        row.backgroundColor = (isHighlighted ? row.rowHighlightColor : row.rowBackgroundColor)
    }
    
}


// MARK: - ScrollStack

public extension ScrollStack {
    
    /// Define the controller size.
    /// - `fixed`: fixed size in points.
    /// - `fitLayoutForAxis`: attempt to size the controller to fits its content set with autolayout.
    enum ControllerSize {
        case fixed(CGFloat)
        case fitLayoutForAxis
    }
    
    /// Insertion of the new row.
    /// - `top`: insert row at the top of the stack.
    /// - `bottom`: append the row at the end of the stack rows.
    /// - `atIndex`: insert at specified index. If index is invalid nothing happens.
    /// - `after`: insert after the location of specified row.
    /// - `before`: insert before the location of the specified row.
    enum InsertLocation {
         case top
         case bottom
         case atIndex(Int)
         case afterView(UIView)
         case beforeView(UIView)
         case after(UIViewController)
         case before(UIViewController)
     }
    
    /// Scrolling position
    /// - `middle`: row is in the middle x/y of the container when possible.
    /// - `final`: row left/top side is aligned to the left/top anchor of the container when possible.
    /// - `final`: row right/top side is aligned to the right/top anchor of the container when possible.
    /// - `automatic`: row is aligned automatically.
    enum ScrollPosition {
        case middle
        case final
        case initial
        case automatic
    }
    
    /// Row visibility
    /// - `partial`: row is partially visible.
    /// - `entire`: row is entirely visible.
    /// - `hidden`: row is invisible and hidden.
    /// - `offscreen`: row is not hidden but currently offscreen due to scroll position.
    /// - `removed`: row is removed manually.
    enum RowVisibility {
        case hidden
        case partial
        case entire
        case offscreen
        case removed
        
        /// Return if row is visible.
        public var isVisible: Bool {
            switch self {
            case .hidden, .offscreen, .removed:
                return false
            default:
                return true
            }
        }
    }
    
}
