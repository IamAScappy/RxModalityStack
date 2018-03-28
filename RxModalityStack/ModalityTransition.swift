//
// Created by Chope on 2018. 3. 15..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

public enum ModalityTransition {
    case ignore
    case system
    case slideUpDown
    case slideLeftRight
    case delegate(UIViewControllerTransitioningDelegate?)
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