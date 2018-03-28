//
// Created by Chope on 2018. 3. 15..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

class SlideUpDownTransition: TransitionAnimatable {
    let duration: TimeInterval = 0.3

    func animateTransition(to: TransitionInfo, animation: @escaping () -> Void, completion: @escaping () -> Void) {
        var frame = to.finalFrame
        frame.origin.y = frame.height
        to.view.frame = frame

        UIView.animate(
            withDuration: duration,
            animations: {
                to.view.frame = to.finalFrame

                animation()
            },
            completion: { b in
                completion()
            })
    }

    func animateTransition(from: TransitionInfo, animation: @escaping () -> Void, completion: @escaping () -> Void) {
        var frame = from.initialFrame
        frame.origin.y = frame.height

        UIView.animate(
            withDuration: duration,
            animations: {
                from.view.frame = frame

                animation()
            },
            completion: { b in
                completion()
            })
    }
}
