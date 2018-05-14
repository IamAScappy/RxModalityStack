//
// Created by Chope on 2018. 4. 27..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

class NothingTransition: TransitionAnimatable {
    let duration: TimeInterval = 0.3

    func animateTransition(to: TransitionInfo, animation: @escaping () -> Void, completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
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
                animation()
            },
            completion: { b in
                completion()
            })
    }
}
