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

extension UIView {
    
    public func height(constant: CGFloat?) {
        setConstraint(value: constant, attribute: .height)
    }
    
    public func width(constant: CGFloat?) {
        setConstraint(value: constant, attribute: .width)
    }
    
    private func removeConstraint(attribute: NSLayoutConstraint.Attribute) {
        constraints.forEach {
            if $0.firstAttribute == attribute {
                removeConstraint($0)
            }
        }
    }
    
    private func setConstraint(value: CGFloat?, attribute: NSLayoutConstraint.Attribute) {
        removeConstraint(attribute: attribute)
        if let value = value {
            let constraint =
                NSLayoutConstraint(item: self,
                                   attribute: attribute,
                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                   toItem: nil,
                                   attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                   multiplier: 1,
                                   constant: value)
            self.addConstraint(constraint)
        }
    }
 
    public static func execute(animated: Bool = true, _ callback: @escaping (() -> Void), completion: (() -> Void)? = nil) {
        guard animated else {
            callback()
            completion?()
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: callback) { isFinished in
            if isFinished {
                completion?()
            }
        }
    }
    
}
