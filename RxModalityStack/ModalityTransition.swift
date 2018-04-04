//
// Created by Chope on 2018. 3. 15..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

public enum ModalityTransition: Equatable {
    case ignore
    case system
    case slideUpDown
    case slideLeftRight
    case delegate(UIViewControllerTransitioningDelegate?)

    public static func ==(lhs: ModalityTransition, rhs: ModalityTransition) -> Bool {
        switch (lhs, rhs) {
        case (.ignore, .ignore),
             (.system, .system),
             (.slideUpDown, .slideUpDown),
             (.slideLeftRight, .slideLeftRight):
            return true
        case (.delegate(let lhsValue), .delegate(let rhsValue)):
            guard let lhsValue = lhsValue else {
                return rhsValue == nil
            }
            guard let rhsValue = rhsValue else {
                return false
            }
            return lhsValue.isEqual(rhsValue)
        default:
            return false
        }
    }
}

extension ModalityTransition {
    func toDelegate() -> UIViewControllerTransitioningDelegate? {
        switch self {
        case .ignore:
            return nil
        case .system:
            return nil
        case .slideLeftRight:
            return BaseViewControllerTransition(transitionAnimatable: SlideLeftRightTransition())
        case .slideUpDown:
            return BaseViewControllerTransition(transitionAnimatable: SlideUpDownTransition())
        case .delegate(let delegate):
            return delegate
        }
    }
}