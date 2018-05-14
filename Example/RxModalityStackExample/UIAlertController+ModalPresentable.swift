//
// Created by Chope on 2018. 4. 19..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit
import RxSwift
import RxModalityStack

extension UIAlertController: ModalPresentable {
    static func viewControllerOf(_ modal: Modal, with data: ModalData) -> (UIViewController & ModalityPresentable)? {
        switch (modal, data) {
        case (.alert, .alert(let title, let message)):
            let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "ok", style: .default) { [unowned vc] action in
                print("press ok")
                _ = Modal.shared.setToDismissed(vc).subscribe()
            })
            vc.addAction(UIAlertAction(title: "delete", style: .destructive) { [unowned vc] action in
                print("press delete")
                _ = Modal.shared.setToDismissed(vc).subscribe()
                _ = Modal.shared.dismissAll(animated: false).subscribe()
            })
            vc.addAction(UIAlertAction(title: "cancel", style: .cancel) { action in
                print("press cancel")
                _ = Modal.shared.setToDismissed(vc).subscribe()
            })
            return vc
        default:
            return nil
        }
    }

    static func transitionOf(_ modal: Modal, with data: ModalData) -> ModalityTransition? {
        return .fadeInOut
    }
}