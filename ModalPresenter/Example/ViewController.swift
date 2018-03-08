//
//  ViewController.swift
//  ModalPresenter
//
//  Created by Chope on 2017. 5. 12..
//  Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxSwift

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        NotificationCenter.default.addObserver(forName: Notification.Name("reorder"), object: nil, queue: nil) { [weak self] notification in
//            guard let ss = self else { return }
//            ModalPresenter.shared.moveToFront(viewController: ss.blueVC) {
//                print("move to front")
//            }.subscribe().disposed(by: ss.disposeBag)
//        }
//
//        NotificationCenter.modalPresenter.addObserver(forName: Notification.Name.ModalPresenter.changedStack, object: nil, queue: nil) { notification in
//            let stackTypes = notification.userInfo?[ModalPresenter.stackTypesNotificationKey]
//            print("[ViewController]: changed stack in modal presenter: \(String(describing: stackTypes))")
//        }
    }


    @objc func presentTestVC() {
        ModalPresenter.shared.present(modalVC: .red).do(onSuccess: { _ in print("present red") }).subscribe()
        ModalPresenter.shared.present(modalVC: .blue).do(onSuccess: { _ in print("present blue") }).subscribe()
        ModalPresenter.shared.present(modalVC: .green).do(onSuccess: { _ in print("present green") }).subscribe()
        ModalPresenter.shared.present(modalVC: .yellow).do(onSuccess: { _ in print("present yellow") }).subscribe()
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

extension ModalPresentable {
    func present(modalVC: ModalVC, animated: Bool = true) -> Single<Void> {
        return ModalPresenter.shared.present(viewController: modalVC.viewController, animated: animated)
    }
}