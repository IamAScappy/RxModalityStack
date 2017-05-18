//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

class YellowVC: PresentableViewController {
    private let dismissAllWithAnimationButton: UIButton = UIButton(type: .system)
    private let dismissAllButton: UIButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.yellow

        dismissAllWithAnimationButton.setTitle("Dismiss all with animation", for: .normal)
        dismissAllWithAnimationButton.frame.origin = CGPoint(x: 100, y: 300)
        dismissAllWithAnimationButton.sizeToFit()
        dismissAllWithAnimationButton.addTarget(self, action: #selector(self.dismissAllWithAnimation), for: .touchUpInside)

        dismissAllButton.setTitle("Dismiss all", for: .normal)
        dismissAllButton.frame.origin = CGPoint(x: 100, y: 360)
        dismissAllButton.sizeToFit()
        dismissAllButton.addTarget(self, action: #selector(self.dismissAll), for: .touchUpInside)

        view.addSubview(dismissAllWithAnimationButton)
        view.addSubview(dismissAllButton)
    }

    @objc func dismissAllWithAnimation() {
        ModalPresenter.shared.dismissAll(animated: true)
    }

    @objc func dismissAll() {
        ModalPresenter.shared.dismissAll(animated: false)
    }

}
