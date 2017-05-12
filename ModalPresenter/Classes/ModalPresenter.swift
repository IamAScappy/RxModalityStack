//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

enum ModalView {
    case red
    case blue
    case green
    case yellow
    case viewController(UIViewController, Bool)

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
        case .viewController(let vc, _):
            return vc
        }
    }

    var isPresentation: Bool {
        switch self {
        case .red:
            return false
        case .blue:
            return false
        case .green:
            return false
        case .yellow:
            return false
        case .viewController(_, let presentation):
            return presentation
        }
    }
}

class ModalInfo {
    let modalView: ModalView
    weak var viewController: UIViewController?

    init(modalView: ModalView, viewController: UIViewController) {
        self.modalView = modalView
        self.viewController = viewController
    }
}

class PresentInfo {
    let modalView: ModalView
    let animated: Bool
    let completion: (()->Void)?

    init(modalView: ModalView, animated: Bool, completion: (()->Void)? = nil) {
        self.modalView = modalView
        self.animated = animated
        self.completion = completion
    }
}

class DismissInfo {
    weak var viewController: UIViewController?
    let animated: Bool
    let completion: (()->Void)?

    init(viewController: UIViewController, animated: Bool, completion: (()->Void)? = nil) {
        self.viewController = viewController
        self.animated = animated
        self.completion = completion
    }
}

class ModalPresenter {
    static let shared = ModalPresenter()

    private var stack: [ModalInfo] = [] {
        didSet {
            print("stack: \(stack)")
        }
    }
    private var presentQueue: [PresentInfo] = []
    private var isPresentAnimating: Bool = false

    private var dismissQueue: [DismissInfo] = []
    private var isDismissAnimating: Bool = false

    private init() {}

    func present(view: ModalView, animated: Bool = true, completion: (()->Void)? = nil) {
        guard isPresentAnimating == false else {
            presentQueue.append(PresentInfo(modalView: view, animated: animated, completion: completion))
            return
        }
        guard let baseVC = stack.last?.viewController ?? UIApplication.shared.keyWindow?.rootViewController else {
            return
        }

        isPresentAnimating = true

        let viewController = view.viewController
        baseVC.present(viewController, animated: animated) {
            self.stack.append(ModalInfo(modalView: view, viewController: viewController))
            self.isPresentAnimating = false

            completion?()

            if self.presentQueue.count > 0 {
                let info = self.presentQueue.removeFirst()
                self.present(view: info.modalView, animated: info.animated, completion: info.completion)
            }
        }
    }

    func dismiss(viewController: UIViewController, animated: Bool, completion: (()->Void)? = nil) {
        guard isDismissAnimating == false else {
            dismissQueue.append(DismissInfo(viewController: viewController, animated: animated, completion: completion))
            return
        }
        guard let index = stack.index(where: { info in
            guard let vc = info.viewController, vc === viewController else { return false }
            return true
        }) else {
            assertionFailure()
            return
        }

        isDismissAnimating = true

        let info = stack.remove(at: index)
        info.viewController?.dismiss(animated: animated) {
            self.isDismissAnimating = false
            completion?()

            if self.dismissQueue.count > 0 {
                let dismissInfo = self.dismissQueue.removeFirst()

                if let vc = dismissInfo.viewController {
                    self.dismiss(viewController: vc, animated: dismissInfo.animated, completion: dismissInfo.completion)
                }
            }
        }
    }

    func dismissAll(animated: Bool = false) {
        dismissQueue = stack.reversed().flatMap { $0.viewController }.map { DismissInfo(viewController: $0, animated: animated) }

        let info = dismissQueue.removeFirst()
        if let vc = info.viewController {
            dismiss(viewController: vc, animated: info.animated)
        }
    }
}
