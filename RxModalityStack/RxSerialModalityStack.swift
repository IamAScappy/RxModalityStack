//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class RxSerialModalityStack: RxModalityStackType {
    public var queue: RxTaskQueue = RxSerialTaskQueue()

    private var stack: [UIViewController] = [] {
        didSet {
            let stackTypes = stack.map { type(of: $0) }
            print("stack: \(stackTypes)")
        }
    }
    private var isExecutingAction: Bool = false
    private var taskObservable: Observable<Void> = Observable.empty()
    private var transitionDelegates: [UIViewController: UIViewControllerTransitioningDelegate] = [:]

    public func present(viewController: UIViewController, animated: Bool, transition: ModalityTransition) -> Single<Void> {
        let single = present(viewController: viewController, onFrontViewControllerWithAnimated: animated, transition: transition)
        return queue.add(single: single)
    }

    public func dismiss(animated: Bool) -> Single<Void> {
        let single = dismissFrontViewController(animated: animated)
        return queue.add(single: single)
    }

    public func dismiss(viewController: UIViewController, animated: Bool) -> Single<Void> {
        return queue.add(single: _dismiss(viewController: viewController))
    }

    private func _dismiss(viewController: UIViewController) -> Single<Void> {
        return Single<Int>
            .create { [unowned self] observer in
                guard let index = self.stack.index(where: { $0 == viewController }) else {
                    observer(.error(RxModalityStackTypeError.notExistsInStack))
                    return Disposables.create()
                }

                observer(.success(index))
                return Disposables.create()
            }
            .map { [unowned self] index -> (index: Int, reorderedViewController: ArraySlice<UIViewController>) in
                if index < (self.stack.count - 1) {
                    let range: Range<Int> = (index + 1)..<self.stack.count
                    return (index, self.stack[range])
                }
                return (index, [])
            }
            .flatMap { [unowned self] (index, reorderViewControllers) -> Single<Void> in
                var concatObservable: Observable<Void> = Observable.just(Void())

                if reorderViewControllers.count == 0 {
                    concatObservable = concatObservable.concat(self.dismissFrontViewController(animated: true))
                } else {
                    for _ in (0..<(reorderViewControllers.count + 1)) {
                        concatObservable = concatObservable.concat(self.dismissFrontViewController(animated: false))
                    }
                }

                reorderViewControllers.forEach { [unowned self] (viewController: UIViewController) in
                    concatObservable = concatObservable.concat(self.present(viewController: viewController, onFrontViewControllerWithAnimated: false, transition: .ignore))
                }

                return concatObservable.takeLast(1).asSingle()
            }
    }

    public func dismissAll(animated: Bool) -> Single<Void> {
        let single = Single<Int>
            .create { [unowned self] observer in
                observer(.success(self.stack.count))
                return Disposables.create()
            }
            .do(onSuccess: { [unowned self] count in
                for _ in (0..<count) {
                    _ = self.queue.add(single: self.dismissFrontViewController(animated: animated))
                }
            })
            .map { _ in Void() }
        return queue.add(single: single)
    }

    public func moveToFront(viewController: UIViewController) -> Single<Void> {
        return _dismiss(viewController: viewController).flatMap { [unowned self] _ in
            self.present(viewController: viewController, onFrontViewControllerWithAnimated: false, transition: .ignore)
        }
    }

    public func isPresented(type viewControllerType: UIViewController.Type) -> Bool {
        return stack.contains { type(of: $0) == viewControllerType }
    }

    public func viewController(at index: Int) -> UIViewController? {
        guard stack.count > index else { return nil }
        return stack[index]
    }

    public func frontViewController() -> Single<UIViewController> {
        return Single.create { observer in
            DispatchQueue.main.async { [unowned self] in
                guard let viewController = self.stack.last ?? UIApplication.shared.keyWindow?.rootViewController else {
                    observer(.error(RxModalityStackTypeError.frontViewControllerNotExists))
                    return
                }
                observer(.success(viewController))
            }
            return Disposables.create()
        }
    }


    // MARK: - present / dismiss viewController
    private func present(viewController: UIViewController, onFrontViewControllerWithAnimated animated: Bool, transition: ModalityTransition) -> Single<Void> {
        return frontViewController()
            .observeOn(MainScheduler.instance)
            .flatMap { [unowned self] (baseVC: UIViewController) in
                self.adjust(transition: transition, in: viewController)
                return baseVC.rx.present(viewController: viewController, animated: animated)
            }
            .do(onSuccess: { [unowned self] _ in
                if let modalVC = viewController as? TransparentModalViewController, self.stack.count >= 1 {
                    let lastVC = self.stack[self.stack.count - 1]
                    modalVC.nextViewForHitTest = lastVC.view
                }
                self.stack.append(viewController)
            })
    }

    private func dismissFrontViewController(animated: Bool) -> Single<Void> {
        return frontViewController()
            .do(onSuccess: { [unowned self] viewController in
                if self.stack.last != viewController {
                    throw RxModalityStackTypeError.topOfStackIsNotFrontViewController
                }
            })
            .observeOn(MainScheduler.instance)
            .flatMap { viewController in
                return viewController.rx.dismiss(animated: animated).do(onSuccess: { [unowned self] _ in
                    self.transitionDelegates[viewController] = nil
                })
            }
            .do(onSuccess: { [unowned self] _ in
                _ = self.stack.removeLast()
            })
    }

    // MARK: - Transition
    private func adjust(transition: ModalityTransition, in viewController: UIViewController) {
        switch transition {
        case .ignore:
            return
        case .system:
            viewController.transitioningDelegate = nil
        default:
            transitionDelegates[viewController] = transition.toDelegate()
            viewController.transitioningDelegate = transitionDelegates[viewController]
            viewController.modalPresentationStyle = .custom
        }
    }
}
