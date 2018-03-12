//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class RxSerialModalityStack: RxModalityStackType {
    public var queue: RxTaskQueue! {
        didSet {
            guard oldValue == nil else {
                assertionFailure()
                return
            }
        }
    }

    private var stack: [UIViewController] = [] {
        didSet {
            let stackTypes = stack.map { type(of: $0) }
            print("stack: \(stackTypes)")
        }
    }
    private var isExecutingAction: Bool = false
    private var taskObservable: Observable<Void> = Observable.empty()

    public func present(viewController: UIViewController, animated: Bool = true) -> Single<Void> {
        let single = frontViewController()
            .observeOn(MainScheduler.instance)
            .flatMap { (baseVC: UIViewController) in
                return baseVC.rx.present(viewController: viewController, animated: animated)
            }
            .do(onSuccess: { [unowned self] _ in
                self.stack.append(viewController)
            })
        return queue.add(single: single)
    }

    public func dismiss(animated: Bool = true) -> Single<Void> {
        return frontViewController()
            .observeOn(MainScheduler.instance)
            .flatMap { [unowned self] (viewController: UIViewController) -> Single<Void> in
                return self.dismiss(viewController: viewController, animated: animated)
            }
    }

    public func dismiss(viewController: UIViewController, animated: Bool = true) -> Single<Void> {
        guard let index = stack.index(where: { $0 == viewController }) else {
            return .error(RxModalityStackTypeError.notExistsInStack)
        }

        var lastSingle: Single<Void> = Single.just(Void())
        var reorderViewControllers: ArraySlice<UIViewController> = []

        if index < (stack.count - 1) {
            let range: Range<Int> = (index + 1)..<stack.count
            reorderViewControllers = stack[range]
            reorderViewControllers.reversed().forEach { [unowned self] (vc: UIViewController) in
                let single = self._dismiss(viewController: vc, animated: false)
                lastSingle = self.queue.add(single: single)
            }
        }

        let vc: UIViewController = stack[index]
        let animated: Bool = index == (stack.count - 1) ? animated : false
        let single: Single<Void> = _dismiss(viewController: vc, animated: animated)
        lastSingle = queue.add(single: single)

        if reorderViewControllers.count > 0 {
            reorderViewControllers.forEach { [unowned self] (viewController: UIViewController) in
                lastSingle = self.present(viewController: viewController, animated: false)
            }
        }
        return lastSingle
    }

    private func _dismiss(viewController: UIViewController, animated: Bool) -> Single<Void> {
        return Single<(UIViewController, (Int))>
            .create { [unowned self] observer in
                guard let index = self.stack.index(where: { $0 == viewController }) else {
                    observer(.error(RxModalityStackTypeError.notExistsInStack))
                    return Disposables.create()
                }

                observer(.success((viewController, index)))
                return Disposables.create()
            }
            .observeOn(MainScheduler.instance)
            .flatMap { (viewController, index) in
                return viewController.rx
                    .dismiss(animated: animated)
                    .do(onSuccess: { [unowned self] _ in
                        self.stack.remove(at: index)
                    })
            }
    }

    public func dismissAll(animated: Bool = true) -> Single<Void> {
        var lastSingle: Single<Void> = Single.just(Void())

        stack.reversed().forEach {
            let single = _dismiss(viewController: $0, animated: animated)
            lastSingle = queue.add(single: single)
        }

        return lastSingle
    }

    public func moveToFront(viewController: UIViewController) -> Observable<Void> {
        let retainedViewController: UIViewController = viewController
        return Observable.just(Void())
            .flatMap { [unowned self] _ in
                return self.dismiss(viewController: retainedViewController, animated: false)
            }
            .flatMap { [unowned self] _ in
                return self.present(viewController: retainedViewController, animated: false)
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
}
