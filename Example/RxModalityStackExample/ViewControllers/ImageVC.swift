//
// Created by Chope on 2018. 4. 18..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit
import RxModalityStack

class ImageVC: ToolViewController {
    var image: UIImage?

    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.insertSubview(imageView, at: 0)

        imageView.image = image
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        imageView.frame = view.bounds
    }
}

extension ImageVC: ModalPresentable {
    class func viewControllerOf(_ modal: Modal, with data: ModalData) -> (UIViewController & ModalityPresentable)? {
        switch (modal, data) {
        case (.image, .image(let image)):
            let vc = ImageVC()
            vc.image = image
            return vc
        default:
            return nil
        }
    }

    class func transitionOf(_ modal: Modal, with data: ModalData) -> ModalityTransition? {
        return .system
    }
}