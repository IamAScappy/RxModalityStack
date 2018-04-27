//
// Created by Chope on 2018. 4. 19..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit
import MobileCoreServices
import RxSwift
import RxModalityStack

extension UIImagePickerController: ModalPresentable {
    static func viewControllerOf(_ modal: Modal, with data: ModalData) -> (UIViewController & ModalityPresentable)? {
        switch (modal, data) {
        case (.imagePicker, .empty):
            let vc = UIImagePickerController()
            vc.allowsEditing = true
            vc.sourceType = .savedPhotosAlbum
            vc.mediaTypes = [kUTTypeImage as String]
            _ = vc.rx.didCancel
                .subscribe(onNext: { [weak vc] _ in
                    guard let vc = vc else { return }
                    _ = Modal.shared.dismiss(vc, animated: true).subscribe()
                })
            return vc
        default:
            return nil
        }
    }

    static func transitionOf(_ modal: Modal, with data: ModalData) -> ModalityTransition? {
        return .system
    }
}