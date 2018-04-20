//
// Created by Chope on 2018. 4. 20..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit
import RxSwift
import RxModalityStack

extension UIActivityViewController: ModalPresentable {
    static func viewControllerOf(_ modal: Modal, with data: ModalData) -> (UIViewController & ModalityPresentable)? {
        let activity = UIActivityViewController(activityItems: [], applicationActivities: nil)
        activity.completionWithItemsHandler = { [weak activity] (_, _, _, _) in
            guard let vc = activity else { return }
            _ = Modal.shared.setToDismissed(vc).subscribe()
        }
        return activity
    }
    static func transitionOf(_ modal: Modal, with data: ModalData) -> ModalityTransition? {
        return .system
    }
}