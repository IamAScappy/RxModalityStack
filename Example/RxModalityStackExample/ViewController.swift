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

class ViewController: UIViewController {
    private let presentButton: UIButton = UIButton(type: .custom)
    private let blueVC = BlueVC()
    private let disposeBag = DisposeBag()

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

    @objc func presentTestVC() {
        RxModalityStack.shared.present(modalVC: .blue).do(onSuccess: { _ in print("present blue") }).subscribe()
        RxModalityStack.shared.present(modalVC: .red).do(onSuccess: { _ in print("present red") }).subscribe()
        RxModalityStack.shared.present(modalVC: .green).do(onSuccess: { _ in print("present green") }).subscribe()
        RxModalityStack.shared.present(modalVC: .yellow).do(onSuccess: { _ in print("present yellow") }).subscribe()
    }
}


enum ModalVC {
    case red
    case blue
    case green
    case yellow

    var viewController: UIViewController {
        switch self {
        case .red:
            return RedVC()
        case .blue:
            return BlueVC()
        case .green:
            return GreenVC()
        case .yellow:
            return YellowVC()
        }
    }
}

extension RxModalityStackType {
    func present(modalVC: ModalVC, animated: Bool = true) -> Single<Void> {
        return RxModalityStack.shared.present(viewController: modalVC.viewController, animated: animated)
    }
}