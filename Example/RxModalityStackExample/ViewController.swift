//
//  ViewController.swift
//  ModalPresenter
//
//  Created by Chope on 2017. 5. 12..
//  Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxModalityStack

class ViewController: RedVC {
//    private let presentButton: UIButton = UIButton(type: .custom)
//    private let disposeBag = DisposeBag()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.addSubview(presentButton)
//
//        presentButton.addTarget(self, action: #selector(presentTestVC), for: .touchUpInside)
//        presentButton.backgroundColor = UIColor.lightGray
//        presentButton.setTitle("Present four viewControllers", for: .normal)
//    }
//
//    open override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        presentButton.frame.size = CGSize(width: view.frame.size.width - 40, height: 60)
//        presentButton.center.x = view.center.x
//        presentButton.frame.origin.y = 100
//    }
//
//    @objc func presentTestVC() {
//        RxModalityStack.shared.present(viewController: BlueVC(), animated: true, transition: .slideUpDown).do(onSuccess: { _ in print("present blue") }).subscribe()
//        RxModalityStack.shared.present(viewController: RedVC(), animated: true, transition: .slideLeftRight).do(onSuccess: { _ in print("present red") }).subscribe()
//        RxModalityStack.shared.present(viewController: GreenVC(), animated: true, transition: .system).do(onSuccess: { _ in print("present green") }).subscribe()
//        RxModalityStack.shared.present(viewController: YellowVC(), animated: true, transition: .system).do(onSuccess: { _ in print("present yellow") }).subscribe()
//    }
}

public extension BackgroundColorAlphaAnimation {
    public var color: UIColor {
        return UIColor.black
    }
    public var alpha: CGFloat {
        return 0.6
    }
}