//
// Created by Chope on 2018. 3. 15..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

public enum ModalityTransition {
    case ignore
    case system
    case slideUpDownDarkBackground(alpha: CGFloat)
    case slideLeftRightDarkBackground(alpha: CGFloat)
    case delegate(UIViewControllerTransitioningDelegate?)
}

extension ModalityTransition {
    func toDelegate() -> UIViewControllerTransitioningDelegate? {
        switch self {
        case .ignore:
            return nil
        case .system:
            return nil
        case .slideLeftRightDarkBackground(let alpha):
            return SlideLeftRightDarkBackgroundTransition(alpha: alpha)
        case .slideUpDownDarkBackground(let alpha):
            return SlideUpDownDarkBackgroundTransition(alpha: alpha)
        case .delegate(let delegate):
            return delegate
        }
    }
}