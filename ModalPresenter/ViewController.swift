//
//  ViewController.swift
//  ModalPresenter
//
//  Created by Chope on 2017. 5. 12..
//  Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentTestVC))
        self.view.addGestureRecognizer(tapGesture)
    }


    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.backgroundColor = UIColor.black
    }


    @objc func presentTestVC() {
        let blueVC = BlueVC()

        ModalPresenter.shared.present(viewController: RedVC()) { print("present red") }
        ModalPresenter.shared.present(viewController: blueVC) { print("present blue") }
        ModalPresenter.shared.present(viewController: GreenVC()) { print("present green") }
        ModalPresenter.shared.present(viewController: YellowVC()) { print("present yellow") }

        ModalPresenter.shared.moveToFront(viewController: blueVC) {
            print("move to front")
        }
//        ModalPresenter.shared.dismiss(viewController: blueVC, animated: true) {
//            print("blueVC dismissed")
//        }
    }
}
