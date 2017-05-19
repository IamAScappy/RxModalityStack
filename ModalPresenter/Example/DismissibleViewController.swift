//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

class DismissibleViewController: UIViewController {
    let dismissButton: UIButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        dismissButton.frame = CGRect(x: 50, y: 50, width: 200, height: 100)
        dismissButton.backgroundColor = UIColor.white
        dismissButton.setTitleColor(UIColor.black, for: .normal)
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.addTarget(self, action: #selector(self.dismissModal), for: .touchUpInside)
        view.addSubview(dismissButton)
    }

    @objc func dismissModal() {
        ModalPresenter.shared.dismiss(viewController: self, animated: true) {
            print("\(self): dismiss")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(self): viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(self): viewWillDisappear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(self): viewDidAppear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(self): viewDidDisappear")
    }

}
