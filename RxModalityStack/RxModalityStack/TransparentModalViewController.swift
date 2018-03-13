//
// Created by Chope on 2018. 3. 13..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

open class TransparentModalViewController: UIViewController {
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overCurrentContext
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .overCurrentContext
    }

    open override func loadView() {
        super.loadView()
        view = TouchPassthroughView()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        (view as? TouchPassthroughView)?.additionalSubviewsForHitTest = { [weak self] in
            return self?.presentingViewController?.view.subviews ?? []
        }

        view.backgroundColor = .clear
    }
}

internal class TouchPassthroughView: UIView {
    var additionalSubviewsForHitTest: (() -> [UIView])?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isUserInteractionEnabled || isHidden || alpha <= 0.01 {
            return nil
        }
        let views = subviews.reversed() + (additionalSubviewsForHitTest?() ?? [])

        if self.point(inside: point, with: event) {
            for subview in views {
                let p = subview.convert(point, from: self)
                let view = subview.hitTest(p, with: event)
                if let view = view {
                    return view
                }
            }
        }
        return nil
    }
}