//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

class YellowVC: DismissibleViewController {
    private let dismissAllWithAnimationButton: UIButton = UIButton(type: .system)
    private let dismissAllButton: UIButton = UIButton(type: .system)
    private let reorderButton: UIButton = UIButton(type: .system)
    private let textField: UITextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.yellow

        dismissAllWithAnimationButton.setTitle("Dismiss all with animation", for: .normal)
        dismissAllWithAnimationButton.frame.origin = CGPoint(x: 100, y: 300)
        dismissAllWithAnimationButton.sizeToFit()
        dismissAllWithAnimationButton.addTarget(self, action: #selector(self.dismissAllWithAnimation), for: .touchUpInside)

        dismissAllButton.setTitle("Dismiss all", for: .normal)
        dismissAllButton.frame.origin = CGPoint(x: 100, y: 340)
        dismissAllButton.sizeToFit()
        dismissAllButton.addTarget(self, action: #selector(self.dismissAll), for: .touchUpInside)

        reorderButton.setTitle("Reorder", for: .normal)
        reorderButton.frame.origin = CGPoint(x: 100, y: 380)
        reorderButton.sizeToFit()
        reorderButton.addTarget(self, action: #selector(self.reorder), for: .touchUpInside)

        textField.frame = CGRect(x: 100, y: 420, width: 100, height: 30)
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.black

        view.addSubview(dismissAllWithAnimationButton)
        view.addSubview(dismissAllButton)
        view.addSubview(reorderButton)
        view.addSubview(textField)
    }

    @objc func dismissAllWithAnimation() {
        ModalPresenter.shared.dismissAll(animated: true)
    }

    @objc func dismissAll() {
        ModalPresenter.shared.dismissAll(animated: false)
    }

    @objc func reorder() {
        NotificationCenter.default.post(name: Notification.Name("reorder"), object: nil)
    }

}
