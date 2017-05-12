//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

class YellowVC: PresentableViewController {
    private let dismissAllButton: UIButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.yellow

        dismissAllButton.setTitle("Dismiss all", for: .normal)
        dismissAllButton.frame.origin = CGPoint(x: 100, y: 300)
        dismissAllButton.sizeToFit()
        dismissAllButton.addTarget(self, action: #selector(self.dismissAll), for: .touchUpInside)
        view.addSubview(dismissAllButton)
    }

    @objc func dismissAll() {
        ModalPresenter.shared.dismissAll(animated: true)
    }

}
