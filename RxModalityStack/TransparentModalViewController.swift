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

        (view as? TouchPassthroughView)?.additionalView = presentingViewController?.view
        view.backgroundColor = .clear
    }
}

internal class TouchPassthroughView: UIView {
    weak var additionalView: UIView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isUserInteractionEnabled || isHidden || alpha <= 0.01 {
            return nil
        }

        if self.point(inside: point, with: event) {
            for subview in subviews.reversed() {
                let p = subview.convert(point, from: self)
                let view = subview.hitTest(p, with: event)
                if let view = view {
                    return view
                }
            }
        }

        guard backgroundColor == .clear else { return nil }
        guard let additionalView = additionalView else { return nil }

        let additionalViewPoint = additionalView.convert(point, from: self)
        return additionalView.hitTest(additionalViewPoint, with: event)
    }
}