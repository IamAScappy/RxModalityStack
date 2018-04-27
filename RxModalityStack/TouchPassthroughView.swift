//
// Created by Chope on 2018. 4. 24..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

internal class TouchPassthroughView: UIView {
    weak var nextViewForHitTest: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        backgroundColor = .clear
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isHittable(self) == true else {
            return nil
        }

        if self.point(inside: point, with: event) {
            let validSubviews = subviews
                .filter {
                    return isHittable($0)
                }
                .reversed()
            for subview in validSubviews {
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

private func isHittable(_ view: UIView) -> Bool {
    return view.isHidden == false && view.isUserInteractionEnabled == true && view.alpha > 0.01
}