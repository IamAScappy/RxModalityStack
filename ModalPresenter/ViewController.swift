//
//  ViewController.swift
//  ModalPresenter
//
//  Created by Chope on 2017. 5. 12..
//  Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    private let presentButton: UIButton = UIButton(type: .custom)
    private let blueVC = BlueVC()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(presentButton)

        presentButton.addTarget(self, action: #selector(presentTestVC), for: .touchUpInside)
        presentButton.backgroundColor = UIColor.lightGray
        presentButton.setTitle("Present four viewControllers", for: .normal)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        presentButton.frame.size = CGSize(width: view.frame.size.width - 40, height: 60)
        presentButton.center.x = view.center.x
        presentButton.frame.origin.y = 100
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(forName: Notification.Name("reorder"), object: nil, queue: nil) { [weak self] notification in
            guard let ss = self else { return }
            ModalPresenter.shared.moveToFront(viewController: ss.blueVC) {
                print("move to front")
            }
        }

        NotificationCenter.modalPresenter.addObserver(forName: Notification.Name.ModalPresenter.changedStack, object: nil, queue: nil) { notification in
            let stackTypes = notification.userInfo?[ModalPresenter.stackTypesNotificationKey]
            print("[ViewController]: changed stack in modal presenter: \(String(describing: stackTypes))")
        }
    }


    @objc func presentTestVC() {
        ModalPresenter.shared.present(viewController: RedVC()) { print("present red") }
        ModalPresenter.shared.present(viewController: blueVC) { print("present blue") }
        ModalPresenter.shared.present(viewController: GreenVC()) { print("present green") }
        ModalPresenter.shared.present(viewController: YellowVC()) { print("present yellow") }

//        ModalPresenter.shared.moveToFront(viewController: blueVC) {
//            print("move to front")
//        }
//        ModalPresenter.shared.dismiss(viewController: blueVC, animated: true) {
//            print("blueVC dismissed")
//        }
    }
}
