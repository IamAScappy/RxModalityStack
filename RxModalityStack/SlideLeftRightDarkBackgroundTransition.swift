//
// Created by Chope on 2018. 3. 15..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

class SlideLeftRightDarkBackgroundTransition: NSObject, UIViewControllerTransitioningDelegate {
    private var alpha: CGFloat = 0.6

    init(alpha: CGFloat) {
        super.init()
        self.alpha = alpha
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideLeftPresentingDarkBackgroundTransition(alpha: alpha)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideRightDismissingDarkBackgroundTransition(alpha: alpha)
    }
}

private class SlideLeftPresentingDarkBackgroundTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private var alpha: CGFloat = 0.6

    init(alpha: CGFloat) {
        super.init()
        self.alpha = alpha
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }

        var toViewStartFrame = transitionContext.initialFrame(for: toVC)
        let toViewFinalFrame = transitionContext.finalFrame(for: toVC)
        let containerView = transitionContext.containerView

        toViewStartFrame.size = toViewFinalFrame.size
        toViewStartFrame.origin = CGPoint(x: toViewFinalFrame.width, y: 0)

        let backgroundView = UIView()
        backgroundView.frame = toViewFinalFrame
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0

        containerView.addSubview(backgroundView)
        containerView.addSubview(toView)
        toView.frame = toViewStartFrame

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.frame = toViewFinalFrame
            backgroundView.alpha = self.alpha
        }, completion: { finished in
            let success = !transitionContext.transitionWasCancelled

            if !success {
                toView.removeFromSuperview()
            }

            backgroundView.removeFromSuperview()

            toView.backgroundColor = UIColor.black.withAlphaComponent(self.alpha)
            transitionContext.completeTransition(success)
        })
    }
}

private class SlideRightDismissingDarkBackgroundTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private var alpha: CGFloat = 0.6

    init(alpha: CGFloat) {
        super.init()
        self.alpha = alpha
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
        guard let fromView = transitionContext.view(forKey: .from) else { return }

        let fromViewStartFrame = transitionContext.initialFrame(for: fromVC)
        var fromViewFinalFrame = transitionContext.finalFrame(for: fromVC)

        fromViewFinalFrame.size = fromViewStartFrame.size
        fromViewFinalFrame.origin = CGPoint(x: fromViewFinalFrame.width, y: 0)

        let backgroundView = UIView()
        backgroundView.frame = fromViewStartFrame
        backgroundView.backgroundColor = .black
        backgroundView.alpha = alpha

        let containerView = transitionContext.containerView
        containerView.addSubview(backgroundView)
        containerView.addSubview(fromView)
        fromView.frame = fromViewStartFrame
        fromView.backgroundColor = .clear

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.frame = fromViewFinalFrame
            backgroundView.alpha = 0
        }, completion: { finished in
            let success = !transitionContext.transitionWasCancelled

            if !success {
                fromView.removeFromSuperview()
            }

            backgroundView.removeFromSuperview()

            transitionContext.completeTransition(success)
        })
    }
}

private protocol TransitionBackgroundRender { }

private class TransitionBackgroundView: UIView, TransitionBackgroundRender {

}