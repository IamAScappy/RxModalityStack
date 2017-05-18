//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

enum ModalAction {
    case present
    case dismiss
}

class ModalInfo {
    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

class ModalActionInfo {
    var viewController: UIViewController
    let action: ModalAction
    let animated: Bool
    let completion: (()->Void)?

    init(viewController: UIViewController, action: ModalAction, animated: Bool, completion: (()->Void)? = nil) {
        self.viewController = viewController
        self.action = action
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
    private var queue: [ModalActionInfo] = [] {
        didSet {
            print("queue: \(queue)")
        }
    }
    private var isExecutingAction: Bool = false

    private init() {}

    func present(viewController: UIViewController, animated: Bool = true, completion: (()->Void)? = nil) {
        guard isExecutingAction == false else {
            queue.append(ModalActionInfo(viewController: viewController, action: .present, animated: animated, completion: completion))
            return
        }
        guard let baseVC = stack.last?.viewController ?? UIApplication.shared.keyWindow?.rootViewController else {
            return
        }

        isExecutingAction = true

        baseVC.present(viewController, animated: animated) { [weak self] in
            guard let ss = self else { return }
            ss.stack.append(ModalInfo(viewController: viewController))
            ss.isExecutingAction = false

            completion?()

            ss.processModalActionInQueue()
        }
    }

    func dismiss(viewController: UIViewController, animated: Bool, completion: (()->Void)? = nil) {
        guard isExecutingAction == false else {
            queue.append(ModalActionInfo(viewController: viewController, action: .dismiss, animated: animated, completion: completion))
            return
        }
        guard let index = stack.index(where: { $0.viewController == viewController }) else {
            assertionFailure()
            return
        }

        isExecutingAction = true

        let modal = stack.remove(at: index)
        modal.viewController?.dismiss(animated: animated) { [weak self] in
            guard let ss = self else { return }

            ss.isExecutingAction = false
            completion?()

            ss.processModalActionInQueue()
        }
    }

    func dismissAll(animated: Bool = false) {
        stack.reversed().flatMap { $0.viewController }.forEach { [weak self] in
            self?.dismiss(viewController: $0, animated: animated)
        }
    }

    private func processModalActionInQueue() {
        guard queue.count > 0 else { return }

        assert(isExecutingAction == false)

        let info: ModalActionInfo = queue.removeFirst()

        switch info.action {
        case .present:
            present(viewController: info.viewController, animated: info.animated, completion: info.completion)
        case .dismiss:
            dismiss(viewController: info.viewController, animated: info.animated, completion: info.completion)
        }
    }
}
