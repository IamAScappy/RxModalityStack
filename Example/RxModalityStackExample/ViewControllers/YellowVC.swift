//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxModalityStack

class YellowVC: TransparentToolViewController, ModalPresentable {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.yellow
    }

    class func viewControllerOf(_ modal: Modal, with data: ModalData) -> (UIViewController & ModalityPresentable)? {
        return YellowVC()
    }

    class func transitionOf(_ modal: Modal, with data: ModalData) -> ModalityTransition? {
        return .system
    }
}
