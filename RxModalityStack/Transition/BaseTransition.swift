//
// Created by Chope on 2018. 3. 28..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import Foundation
import UIKit

struct TransitionInfo {
    let viewController: UIViewController
    let view: UIView
    var initialFrame: CGRect
    var finalFrame: CGRect
}

protocol TransitionAnimatable {
    var duration: TimeInterval { get }

    func animateTransition(to: TransitionInfo, animation: @escaping ()->Void, completion: @escaping ()->Void)
    func animateTransition(from: TransitionInfo, animation: @escaping ()->Void, completion: @escaping ()->Void)
}

class BasePresentedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let transitionAnimatable: TransitionAnimatable

    init(transitionAnimatable: TransitionAnimatable) {
        self.transitionAnimatable = transitionAnimatable
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionAnimatable.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if transitionContext.isPresenting {
            animatePresentingTransition(using: transitionContext)
        } else {
            animateDismissingTransition(using: transitionContext)
        }
    }

    private func animatePresentingTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toTransitionInfo: TransitionInfo = transitionContext.transitionInfo(for: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(toTransitionInfo.view)

        let backgroundView: UIView? = {
            guard let backgroundColorAlphaAnimation = toTransitionInfo.viewController as? BackgroundColorAlphaAnimation else { return nil }

            let backgroundView = UIView()
            backgroundView.backgroundColor = backgroundColorAlphaAnimation.color.withAlphaComponent(0)
            backgroundView.frame = toTransitionInfo.finalFrame
            return backgroundView
        }()

        if let backgroundView = backgroundView {
            containerView.insertSubview(backgroundView, at: 0)
        }

        transitionAnimatable.animateTransition(
            to: toTransitionInfo,
            animation: {
                guard let backgroundColorAlphaAnimation = toTransitionInfo.viewController as? BackgroundColorAlphaAnimation else { return }
                guard let backgroundView = backgroundView else { return }
                backgroundView.backgroundColor = backgroundColorAlphaAnimation.color.withAlphaComponent(backgroundColorAlphaAnimation.alpha)
            },
            completion: {
                let success = !transitionContext.transitionWasCancelled

                if !success {
                    toTransitionInfo.view.removeFromSuperview()
                }

                backgroundView?.removeFromSuperview()

                if let backgroundColorAlphaAnimation = toTransitionInfo.viewController as? BackgroundColorAlphaAnimation {
                    toTransitionInfo.view.backgroundColor = backgroundColorAlphaAnimation.color.withAlphaComponent(backgroundColorAlphaAnimation.alpha)
                }

                transitionContext.completeTransition(success)
            })
    }

    private func animateDismissingTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromTransitionInfo: TransitionInfo = transitionContext.transitionInfo(for: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(fromTransitionInfo.view)

        let backgroundView: UIView? = {
            guard let _ = fromTransitionInfo.viewController as? BackgroundColorAlphaAnimation else { return nil }

            let backgroundView = UIView()
            backgroundView.backgroundColor = fromTransitionInfo.view.backgroundColor
            backgroundView.frame = fromTransitionInfo.initialFrame
            return backgroundView
        }()

        if let backgroundView = backgroundView {
            containerView.insertSubview(backgroundView, at: 0)

            fromTransitionInfo.view.backgroundColor = .clear
        }

        transitionAnimatable.animateTransition(
            from: fromTransitionInfo,
            animation: {
                guard let backgroundView = backgroundView else { return }
                backgroundView.backgroundColor = .clear
            },
            completion: {
                let success = !transitionContext.transitionWasCancelled

                if !success {
                    fromTransitionInfo.view.removeFromSuperview()
                }

                transitionContext.completeTransition(success)
            })
    }
}

class BaseViewControllerTransition: NSObject, UIViewControllerTransitioningDelegate {
    let transitionAnimatable: TransitionAnimatable

    init(transitionAnimatable: TransitionAnimatable) {
        self.transitionAnimatable = transitionAnimatable
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BasePresentedTransition(transitionAnimatable: transitionAnimatable)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BasePresentedTransition(transitionAnimatable: transitionAnimatable)
    }
}

extension UIViewControllerContextTransitioning {
    var isPresenting: Bool {
        guard let _ = view(forKey: .from) else { return true }
        return false
    }

    func transitionInfo(for key: UITransitionContextViewControllerKey) -> TransitionInfo? {
        guard let viewKey = key.transitionContextViewKey else { return nil }
        guard let vc = viewController(forKey: key) else { return nil }
        guard let view = view(forKey: viewKey) else { return nil }

        let initialFrame = self.initialFrame(for: vc)
        let finalFrame = self.finalFrame(for: vc)
        let transitionInfo = TransitionInfo(viewController: vc, view: view, initialFrame: initialFrame, finalFrame: finalFrame)
        return transitionInfo
    }
}

extension UITransitionContextViewControllerKey {
    var transitionContextViewKey: UITransitionContextViewKey? {
        switch self {
        case UITransitionContextViewControllerKey.to:
            return .to
        case UITransitionContextViewControllerKey.from:
            return .from
        default:
            return nil
        }
    }
}