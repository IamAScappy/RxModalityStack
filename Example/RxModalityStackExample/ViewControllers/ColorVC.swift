//
// Created by Chope on 2018. 3. 30..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit
import RxModalityStack

class ColorVC: ToolViewController, ModalPresentable {
    deinit {
        print("deinit color")
    }

    class func viewControllerOf(_ modal: Modal, with data: ModalData) -> (UIViewController & ModalityPresentable)? {
        switch data {
        case .color(let color):
            let vc = ColorVC()
            vc.view.backgroundColor = color
            return vc
        default:
            return nil
        }
    }

    class func transitionOf(_ modal: Modal, with data: ModalData) -> ModalityTransition? {
        return .system
    }
}
