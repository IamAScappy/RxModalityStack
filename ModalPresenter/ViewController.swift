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
        ModalPresenter.shared.present(view: .red, animated: false) { print("present red") }
        ModalPresenter.shared.present(view: .blue, animated: true) { print("present blue") }
        ModalPresenter.shared.present(view: .green, animated: false) { print("present green") }
        ModalPresenter.shared.present(view: .yellow, animated: true) { print("present yellow") }
    }
}
