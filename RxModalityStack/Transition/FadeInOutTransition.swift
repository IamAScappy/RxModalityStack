//
// Created by Chope on 2018. 4. 27..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

class FadeInOutTransition: TransitionAnimatable {
    let duration: TimeInterval = 0.3

    func animateTransition(to: TransitionInfo, animation: @escaping () -> Void, completion: @escaping () -> Void) {
        to.view.alpha = 0
        to.view.frame = to.finalFrame

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                to.view.alpha = 1

                animation()
            },
            completion: { b in
                completion()
            })
    }

    func animateTransition(from: TransitionInfo, animation: @escaping () -> Void, completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                from.view.alpha = 0

                animation()
            },
            completion: { b in
                completion()
            })
    }
}
