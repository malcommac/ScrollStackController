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

// MARK: - ScrollStackRowAnimatable

public protocol ScrollStackRowAnimatable {
    
    /// Animation main info.
    var animationInfo: ScrollStackAnimationInfo { get }
    
    /// Animation will start to hide or show the row.
    /// - Parameter toHide: hide or show transition.
    func willBeginAnimationTransition(toHide: Bool)
    
    /// Animation to hide/show the row did end.
    /// - Parameter toHide: hide or show transition.
    func didEndAnimationTransition(toHide: Bool)
    
    /// Animation transition.
    /// - Parameter toHide: hide or show transition.
    func animateTransition(toHide: Bool)
    
}

// MARK: - ScrollStackRowAnimatable Extension

public extension ScrollStackRowAnimatable where Self: UIViewController {
    
    var animationInfo: ScrollStackAnimationInfo {
        return ScrollStackAnimationInfo()
    }
    
    func animateTransition(toHide: Bool) {
        
    }
    
    func willBeginAnimationTransition(toHide: Bool) {
        
    }
    
    func didEndAnimationTransition(toHide: Bool) {
        
    }
    
}


// MARK: - ScrollStackAnimationInfo

public struct ScrollStackAnimationInfo {
    
    /// Duration of the animation. By default is set to `0.25`.
    var duration: TimeInterval
    
    /// Delay before start animation.
    var delay: TimeInterval
    
    /// The springDamping value used to determine the amount of `bounce`.
    /// Default Value is `0.8`.
    var springDamping: CGFloat
    
    public init(duration: TimeInterval = 0.25, delay: TimeInterval = 0, springDamping: CGFloat = 0.8) {
        self.duration = duration
        self.delay = delay
        self.springDamping = springDamping
    }
    
}

// MARK: - ScrollStackRowAnimator

internal class ScrollStackRowAnimator {
    
    /// Row to animate.
    private let targetRow: ScrollStackRow
    
    /// Final state after animation, hidden or not.
    private let toHidden: Bool
    
    /// Animation handler, used to perform actions for animation in `ScrollStack`.
    private let internalHandler: () -> Void
    
    /// Completion handler.
    private let completion: ((Bool) -> Void)?
    
    /// Target row if animatable.
    private var animatableRow: ScrollStackRowAnimatable? {
        return targetRow.controller as? ScrollStackRowAnimatable
    }
    
    // MARK: - Initialization
    
    init(row: ScrollStackRow, toHidden: Bool,
         internalHandler: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        self.targetRow = row
        self.toHidden = toHidden
        self.internalHandler = internalHandler
        self.completion = completion
    }
    
    /// Execute animation.
    func execute() {
        animatableRow?.willBeginAnimationTransition(toHide: toHidden)
        
        let duration = animatableRow?.animationInfo.duration ?? 0.25
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: animatableRow?.animationInfo.springDamping ?? 1,
                       initialSpringVelocity: 0,
                       options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState],
                       animations: {
                        self.animatableRow?.animateTransition(toHide: self.toHidden)
                        self.internalHandler()
        }) { finished in
            self.animatableRow?.didEndAnimationTransition(toHide: self.toHidden)
            self.completion?(finished)
        }
    }

}
