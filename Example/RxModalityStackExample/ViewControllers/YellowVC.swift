//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxModalityStack

class YellowVC: ToolViewController, ModalityPresentable {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.yellow
    }

    class func viewController<T: ModalityType>(for type: T) throws -> UIViewController {
        return YellowVC()
    }
}
