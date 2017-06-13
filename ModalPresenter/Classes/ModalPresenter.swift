//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

public extension NotificationCenter {
    static let modalPresenter = NotificationCenter()
}

public extension Notification.Name {
    public struct ModalPresenter {
        public static let changedStack: Notification.Name = Notification.Name("ModalPresenter-ChangedStack")
    }
}

public class ModalPresenter {
    public static let shared = ModalPresenter()
    public static let stackTypesNotificationKey = "StackTypesNotificationKey"

    public var frontViewController: UIViewController? {
        return stack.last?.viewController
    }

    private var stack: [ModalInfo] = [] {
        didSet {
            let fixedStack = fixingStack()

            guard stack.count == fixedStack.count else {
                stack = fixedStack
                return
            }

            let stackTypes = stack.flatMap { $0.viewController } .map { type(of: $0) }
            print("stack: \(stackTypes)")
            NotificationCenter.modalPresenter.post(name: Notification.Name.ModalPresenter.changedStack, object: nil, userInfo: [
                type(of: self).stackTypesNotificationKey: stackTypes
            ])
        }
    }
    private var queue: [ModalActionInfo] = [] {
        didSet {
            print("queue: \(queue.map { "\($0.action): \(type(of: $0.viewController))" })")
        }
    }
    private var isExecutingAction: Bool = false

    private init() {}

    public func present(viewController: UIViewController, animated: Bool = true, completion: (()->Void)? = nil) {
        fixedStack()

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
            completion?()

            self.isExecutingAction = false
            self.processModalActionInQueue()
        }
    }

    public func dismiss(animated: Bool, completion: (()->Void)? = nil) {
        assert(isExecutingAction == false)

        guard let viewController = stack.last?.viewController else { return }
        dismiss(viewController: viewController, animated: animated, completion: completion)
    }

    public func dismiss(viewController: UIViewController, animated: Bool, completion: (()->Void)? = nil) {
        fixedStack()

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
            completion?()

            self.isExecutingAction = false
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

    public func dismissAll(animated: Bool) {
        stack.reversed().flatMap { $0.viewController }.forEach { [unowned self] in
            self.dismiss(viewController: $0, animated: animated)
        }
    }

    public func moveToFront(viewController: UIViewController, completion: (()->Void)? = nil) {
        fixedStack()

        dismiss(viewController: viewController, animated: false) { [unowned self] in
            self.present(viewController: viewController, animated: false, completion: completion)
        }
    }

    public func isPresented(type: UIViewController.Type) -> Bool {
        fixedStack()

        return stack.flatMap { $0.viewController }.contains { type(of: $0) == type }
    }

    public func viewController(at index: Int) -> UIViewController? {
        guard stack.count > index else { return nil }
        return stack[index].viewController
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

    private func fixingStack() -> [ModalInfo] {
        return stack.filter { $0.viewController != nil }
    }

    private func fixedStack() {
        stack = fixingStack()
    }
}

private enum ModalAction {
    case present
    case dismiss
    case moveToFront
}

private class ModalInfo {
    weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

private class ModalActionInfo {
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
