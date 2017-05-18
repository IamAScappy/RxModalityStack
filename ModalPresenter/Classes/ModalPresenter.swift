//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

enum ModalAction {
    case present
    case dismiss
    case moveToFront
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
        fixStack()

        guard isExecutingAction == false else {
            queue.append(ModalActionInfo(viewController: viewController, action: .present, animated: animated, completion: completion))
            return
        }
        guard let baseVC = stack.last?.viewController ?? UIApplication.shared.keyWindow?.rootViewController else {
            assertionFailure()
            return
        }

        isExecutingAction = true

        baseVC.present(viewController, animated: animated) { [unowned self] in
            self.stack.append(ModalInfo(viewController: viewController))
            self.isExecutingAction = false

            completion?()

            self.processModalActionInQueue()
        }
    }

    func dismiss(viewController: UIViewController, animated: Bool, completion: (()->Void)? = nil) {
        fixStack()

        guard isExecutingAction == false else {
            queue.append(ModalActionInfo(viewController: viewController, action: .dismiss, animated: animated, completion: completion))
            return
        }

        if let frontVC = stack.last?.viewController, frontVC === viewController {
            dismiss(index: stack.count - 1, animated: animated, completion: completion)
        } else {
            dismissNotFront(viewController: viewController, completion: completion)
        }
    }

    private func dismiss(index: Int, animated: Bool, completion: (()->Void)?) {
        isExecutingAction = true

        let modal = stack.remove(at: index)
        modal.viewController?.dismiss(animated: animated) { [unowned self] in
            self.isExecutingAction = false
            completion?()

            self.processModalActionInQueue()
        }
    }

    private func dismissNotFront(viewController: UIViewController, completion: (()->Void)?) {
        guard let index = stack.index(where: { $0.viewController == viewController }) else {
            assertionFailure()
            return
        }

        let reorderViewControllers = stack[(index + 1)..<stack.count]
        reorderViewControllers.reversed().forEach {
            guard let viewController = $0.viewController else {
                return
            }
            dismiss(viewController: viewController, animated: false)
        }

        dismiss(viewController: viewController, animated: false, completion: completion)

        reorderViewControllers.forEach {
            guard let viewController = $0.viewController else {
                return
            }
            present(viewController: viewController, animated: false)
        }
    }

    func dismissAll(animated: Bool = false) {
        stack.reversed().flatMap { $0.viewController }.forEach { [unowned self] in
            self.dismiss(viewController: $0, animated: animated)
        }
    }

    func moveToFront(viewController: UIViewController, completion: (()->Void)? = nil) {
        fixStack()

        dismiss(viewController: viewController, animated: false)
        present(viewController: viewController, animated: false, completion: completion)
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
        case .moveToFront:
            moveToFront(viewController: info.viewController, completion: info.completion)
        }
    }

    private func fixStack() {
        stack = stack.filter { $0.viewController != nil }
    }
}
