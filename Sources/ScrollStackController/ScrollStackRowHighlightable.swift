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

/**
 * Indicates that a row in an `AloeStackView` should be highlighted when the user touches it.
 *
 * Rows that are added to an `AloeStackView` can conform to this protocol to have their
 * background color automatically change to a highlighted color (or some other custom behavior defined by the row) when the user is pressing down on
 * them.
 */
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
