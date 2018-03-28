//
// Created by Chope on 2018. 3. 13..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class TransparentModalViewController: UIViewController {
    weak var nextViewForHitTest: UIView? {
        didSet {
            (view as? TouchPassthroughView)?.nextViewForHitTest = nextViewForHitTest
        }
    }

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

        view.backgroundColor = .clear
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let point = touches.first?.location(in: view) else { return }

        if view.hitTest(point, with: event) == view {
            onTouchOutside()
        }
    }

    open func onTouchOutside() {
        print("touch outside")
    }
}

internal class TouchPassthroughView: UIView {
    weak var nextViewForHitTest: UIView?

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

        guard backgroundColor == .clear else {
            return self
        }
        guard let additionalView = nextViewForHitTest else { return nil }

        let additionalViewPoint = additionalView.convert(point, from: self)
        return additionalView.hitTest(additionalViewPoint, with: event)
    }
}