//
// Created by Chope on 2018. 3. 30..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit
import RxModalityStack

class ColorVC: UIViewController, ModalPresentable {
    class func viewControllerOf(_ modal: Modal) -> UIViewController {
        let vc = ColorVC()

        switch modal {
        case .color(let color):
            vc.view.backgroundColor = color
        default:
            break
        }
        return vc
    }
//    class func viewController<T: ModalityType>(for type: T) throws -> UIViewController {
//        let vc = ColorVC()
//
//        if let type = type as? Modal {
//            switch type {
//            case Modal.color(let color):
//                vc.view.backgroundColor = color
//            default:
//                break
//            }
//        }
//        return vc
//    }
}
