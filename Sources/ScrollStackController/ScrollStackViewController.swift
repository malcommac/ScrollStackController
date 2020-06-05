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

open class ScrollStackViewController: UIViewController {
    
    // MARK: Public Properties
    
    /// Inner stack view control.
    public let scrollStack = ScrollStack()
    
    /// Displays the scroll indicators momentarily.
    open var automaticallyFlashScrollIndicators = false
    
    // MARK: Init

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: View Lifecycle
    
    open override func loadView() {
        view = scrollStack
        // monitor remove or add of a row to manage the view controller's hierarchy
        scrollStack.onChangeRow = { [weak self] (row, isRemoved) in
            guard let self = self else {
                return
            }
            self.didAddOrRemoveRow(row, isRemoved: isRemoved)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
        
      if automaticallyFlashScrollIndicators {
          scrollStack.flashScrollIndicators()
      }
    }
    
    // MARK: - Private Functions
    
    private func didAddOrRemoveRow(_ row: ScrollStackRow, isRemoved: Bool) {
        guard let controller = row.controller else {
            return
        }
        
        if isRemoved {
            controller.removeFromParent()
            controller.didMove(toParent: nil)

        } else {
            self.addChild(controller)
            controller.didMove(toParent: self)
        }
    }
}
