//
// Created by Chope on 2018. 3. 15..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

public enum ModalityTransition: Equatable {
    case ignore
    case system
    case slide(Direction)
    case nothing
    case delegate(UIViewControllerTransitioningDelegate?)

    public static func ==(lhs: ModalityTransition, rhs: ModalityTransition) -> Bool {
        switch (lhs, rhs) {
        case (.ignore, .ignore),
             (.system, .system),
             (.nothing, .nothing):
            return true
        case (.slide(let lhsValue), .slide(let rhsValue)):
            return lhsValue == rhsValue
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
        case .slide(let direction):
            return BaseViewControllerTransition(transitionAnimatable: SlideTransition(direction: direction))
        case .nothing:
            return BaseViewControllerTransition(transitionAnimatable: NothingTransition())
        case .delegate(let delegate):
            return delegate
        }
    }
}
