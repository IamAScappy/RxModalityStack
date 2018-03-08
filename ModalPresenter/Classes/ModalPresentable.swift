//
// Created by Chope on 2018. 3. 8..
// Copyright (c) 2018 Chope. All rights reserved.
//

import UIKit
import RxSwift

public enum ModalPresentableError: Error {
    case viewControllerNotExists
    case notExistsInStack
}

public protocol ModalPresentable: class {
    var queue: RxTaskQueue! { get set }
    var frontViewController: UIViewController { get }

    func present(viewController: UIViewController, animated: Bool) -> Single<Void>
    func dismiss(animated: Bool) -> Single<Void>
    func dismiss(viewController: UIViewController, animated: Bool) -> Single<Void>
    func dismissAll(animated: Bool) -> Single<Void>
    func moveToFront(viewController: UIViewController) -> Observable<Void>
    func isPresented(type viewControllerType: UIViewController.Type) -> Bool
    func viewController(at index: Int) -> UIViewController?
}