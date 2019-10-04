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
    func sizeForAxis(_ axis: NSLayoutConstraint.Axis, row: ScrollStackRow, in stackView: ScrollStack) -> CGFloat?
    
}


// MARK: - ScrollStack

public extension ScrollStack {
    
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
    enum RowVisibility {
        case hidden
        case partial
        case entire
        case offscreen
        
        /// Return if row is visible.
        public var isVisible: Bool {
            switch self {
            case .hidden, .offscreen:
                return false
            default:
                return true
            }
        }
    }
    
}
