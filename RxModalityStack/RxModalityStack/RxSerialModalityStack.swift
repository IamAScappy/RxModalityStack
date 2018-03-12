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

    public var frontViewController: UIViewController? {
        return stack.last?.viewController ?? UIApplication.shared.keyWindow?.rootViewController
    }

    private var stack: [ModalityInfo] = [] {
        didSet {
            let fixedStack = fixingStack()

            guard stack.count == fixedStack.count else {
                stack = fixedStack
                return
            }

            let stackTypes = stack.flatMap { $0.viewController } .map { type(of: $0) }
            print("stack: \(stackTypes)")
        }
    }
    private var isExecutingAction: Bool = false
    private var taskObservable: Observable<Void> = Observable.empty()

    public func present(viewController: UIViewController, animated: Bool = true) -> Single<Void> {
        let single = Single<UIViewController>
            .create { [unowned self] observer in
                guard let frontViewController = self.frontViewController else {
                    observer(.error(RxModalityStackTypeError.frontViewControllerNotExists))
                    return Disposables.create()
                }
                observer(.success(frontViewController))
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
            .flatMap { (baseVC: UIViewController) in
                return baseVC.rx.present(viewController: viewController, animated: animated)
            }
            .do(onSuccess: { [unowned self] _ in
                self.stack.append(ModalityInfo(viewController: viewController))
            })
        return queue.add(single: single)
    }

    public func dismiss(animated: Bool = true) -> Single<Void> {
        return Single<UIViewController>
            .create { [unowned self] observer in
                guard let viewController = self.stack.last?.viewController else {
                    observer(.error(RxModalityStackTypeError.frontViewControllerNotExists))
                    return Disposables.create()
                }
                observer(.success(viewController))
                return Disposables.create()
            }
            .subscribeOn(MainScheduler.instance)
            .flatMap { [unowned self] (viewController: UIViewController) -> Single<Void> in
                return self.dismiss(viewController: viewController, animated: animated)
            }
    }

    public func dismiss(viewController: UIViewController, animated: Bool = true) -> Single<Void> {
        guard let index = stack.index(where: { $0.viewController == viewController }) else {
            return .error(RxModalityStackTypeError.notExistsInStack)
        }

        var lastSingle: Single<Void> = Single.just(Void())
        var reorderViewControllers: ArraySlice<ModalityInfo> = []

        if index < (stack.count - 1) {
            let range: Range<Int> = (index + 1)..<stack.count
            reorderViewControllers = stack[range]
            reorderViewControllers.reversed().forEach { [unowned self] (modalInfo: ModalityInfo) in
                let single = self.dismiss(modalInfo: modalInfo, animated: false)
                lastSingle = self.queue.add(single: single)
            }
        }

        let modalInfo: ModalityInfo = stack[index]
        let animated: Bool = index == (stack.count - 1) ? animated : false
        let single: Single<Void> = dismiss(modalInfo: modalInfo, animated: animated)
        lastSingle = queue.add(single: single)

        if reorderViewControllers.count > 0 {
            reorderViewControllers
                .flatMap {
                    $0.viewController
                }
                .forEach { [unowned self] (viewController: UIViewController) in
                    lastSingle = self.present(viewController: viewController, animated: false)
                }
        }
        return lastSingle
    }

    private func dismiss(modalInfo: ModalityInfo, animated: Bool) -> Single<Void> {
        return Single<(UIViewController, (Int))>
            .create { [unowned self] observer in
                guard let viewController = modalInfo.viewController else {
                    observer(.error(RxModalityStackTypeError.viewControllerNotExists))
                    return Disposables.create()
                }
                guard let index = self.stack.index(where: { $0.viewController == modalInfo.viewController }) else {
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
            let single = dismiss(modalInfo: $0, animated: animated)
            lastSingle = queue.add(single: single)
        }

        return lastSingle
    }

    public func moveToFront(viewController: UIViewController) -> Observable<Void> {
        let retainedViewController: UIViewController = viewController
        return Observable.just(Void())
            .do(onNext: { [unowned self] _ in
                self.fixedStack()
            })
            .flatMap { [unowned self] _ in
                return self.dismiss(viewController: retainedViewController, animated: false)
            }
            .flatMap { [unowned self] _ in
                return self.present(viewController: retainedViewController, animated: false)
            }
    }

    public func isPresented(type viewControllerType: UIViewController.Type) -> Bool {
        fixedStack()

        return stack.flatMap { $0.viewController }.contains { type(of: $0) == viewControllerType }
    }

    public func viewController(at index: Int) -> UIViewController? {
        guard stack.count > index else { return nil }
        return stack[index].viewController
    }

    private func fixingStack() -> [ModalityInfo] {
        return stack.filter { $0.viewController != nil }
    }

    private func fixedStack() {
        stack = fixingStack()
    }
}
