//
// Created by Chope on 2018. 3. 15..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

public enum Direction: Equatable {
    case up
    case down
    case left
    case right
}

class SlideTransition: TransitionAnimatable {
    let duration: TimeInterval = 0.3
    let direction: Direction

    init(direction: Direction) {
        self.direction = direction
    }

    func animateTransition(to: TransitionInfo, animation: @escaping () -> Void, completion: @escaping () -> Void) {
        var frame = to.finalFrame
        switch direction {
        case .up:
            frame.origin.y = frame.height
        case .down:
            frame.origin.y = -frame.height
        case .left:
            frame.origin.x = frame.width
        case .right:
            frame.origin.x = -frame.width
        }
        to.view.frame = frame

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                to.view.frame = to.finalFrame

                animation()
            },
            completion: { _ in
                completion()
            })
    }

    func animateTransition(from: TransitionInfo, animation: @escaping () -> Void, completion: @escaping () -> Void) {
        var frame = from.initialFrame
        switch direction {
        case .up:
            frame.origin.y = frame.height
        case .down:
            frame.origin.y = -frame.height
        case .left:
            frame.origin.x = frame.width
        case .right:
            frame.origin.x = -frame.width
        }

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                from.view.frame = frame

                animation()
            },
            completion: { _ in
                completion()
            })
    }
}
