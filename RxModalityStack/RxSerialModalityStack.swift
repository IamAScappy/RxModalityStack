//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class RxSerialModalityStack<T: ModalityType>: RxModalityStackType {
    public var queue: RxTaskQueue = RxSerialTaskQueue()
    public let changedStack: PublishSubject<[Modality<T>]> = PublishSubject()

    public private(set) var stack: [Modality<T>] = [] {
        didSet {
            guard oldValue != stack else { return }
            changedStack.onNext(stack)
        }
    }
    private var isExecutingAction: Bool = false
    private var taskObservable: Observable<Void> = Observable.empty()
    private var transitionDelegates: [UIViewController: UIViewControllerTransitioningDelegate] = [:]

    public init() {}

    public func present(_ modalityType: T, animated: Bool, transition: ModalityTransition) -> Single<UIViewController> {
        return Single<Modality<T>>
            .create { [unowned self] observer in
                do {
                    let vc = try self.viewController(for: modalityType)
                    let modality = Modality(type: modalityType, viewController: vc)
                    observer(.success(modality))
                } catch let e {
                    observer(.error(e))
                }
                return Disposables.create()
            }
            .flatMap { [unowned self] modality in
                let single = self.present(modality, onFrontViewControllerWithAnimated: animated, transition: transition)
                return self.queue.add(single: single).map { modality.viewController }
            }
    }

    public func dismissFront(animated: Bool) -> Single<Void> {
        let single = dismissFrontViewController(animated: animated)
        return queue.add(single: single)
    }

    public func dismiss(_ modalityType: T, animated: Bool) -> Single<Void> {
        return queue.add(single: _dismiss(modalityType))
    }

    private func _dismiss(_ modalityType: T) -> Single<Void> {
        return Single<Int>
            .create { [unowned self] observer in
                let modalities = self.modality(of: modalityType)

                guard modalities.count <= 1 else {
                    observer(.error(RxModalityStackTypeError.tooManyTypesInStack))
                    return Disposables.create()
                }
                guard let modality = modalities.first else {
                    observer(.error(RxModalityStackTypeError.notExistsInStack))
                    return Disposables.create()
                }
                guard let index = self.stack.index(where: { $0 == modality }) else {
                    observer(.error(RxModalityStackTypeError.notExistsInStack))
                    return Disposables.create()
                }

                observer(.success(index))
                return Disposables.create()
            }
            .map { [unowned self] index -> (index: Int, reorderedViewController: ArraySlice<Modality<T>>) in
                if index < (self.stack.count - 1) {
                    let range: Range<Int> = (index + 1)..<self.stack.count
                    return (index, self.stack[range])
                }
                return (index, [])
            }
            .flatMap { [unowned self] (index, reorderModality) -> Single<Void> in
                var concatObservable: Observable<Void> = Observable.just(Void())

                if reorderModality.count == 0 {
                    concatObservable = concatObservable.concat(self.dismissFrontViewController(animated: true))
                } else {
                    for _ in (0..<(reorderModality.count + 1)) {
                        concatObservable = concatObservable.concat(self.dismissFrontViewController(animated: false))
                    }
                }

                reorderModality
                    .forEach { [unowned self] (modality: Modality<T>) in
                        concatObservable = concatObservable.concat(self.present(modality, onFrontViewControllerWithAnimated: false, transition: .ignore))
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

    public func bring(toFront: T) -> Single<Void> {
        var modality: Modality<T>?

        return Single<Void>
            .create { [unowned self] observer in
                let modalities = self.modality(of: toFront)
                if modalities.count > 1 {
                    observer(.error(RxModalityStackTypeError.tooManyTypesInStack))
                    return Disposables.create()
                }
                guard let firstModality = modalities.first else {
                    observer(.error(RxModalityStackTypeError.notExistsInStack))
                    return Disposables.create()
                }

                modality = firstModality
                observer(.success(Void()))
                return Disposables.create()
            }
            .flatMap { [unowned self] _ -> Single<Void> in
                return self._dismiss(toFront)
            }
            .flatMap { _ -> Single<Modality<T>> in
                guard let m = modality else {
                    return Single.never()
                }
                return .just(m)
            }
            .flatMap { [unowned self] modality -> Single<Void> in
                return self.present(modality, onFrontViewControllerWithAnimated: false, transition: .ignore)
            }
    }

    public func isPresented(modalityType: T, onlyType: Bool) -> Bool {
        if onlyType {
            return stack.contains { (modality: Modality<T>) in
                modality.type ~= modalityType
            }
        }
        return modality(of: modalityType).count > 0
    }

    public func modality(at index: Int) -> Modality<T>? {
        guard stack.count > index else { return nil }
        return stack[index]
    }

    public func modality(of type: T) -> [Modality<T>] {
        return stack.filter { $0.type == type }
    }

    public func frontViewController() -> Single<UIViewController> {
        return Single.create { observer in
            DispatchQueue.main.async { [unowned self] in
                guard let viewController = self.stack.last?.viewController ?? UIApplication.shared.keyWindow?.rootViewController else {
                    observer(.error(RxModalityStackTypeError.frontViewControllerNotExists))
                    return
                }
                observer(.success(viewController))
            }
            return Disposables.create()
        }
    }


    // MARK: - present / dismiss viewController
    private func present(_ modality: Modality<T>, onFrontViewControllerWithAnimated animated: Bool, transition: ModalityTransition) -> Single<Void> {
        return frontViewController()
            .observeOn(MainScheduler.instance)
            .flatMap { [unowned self] (baseVC: UIViewController) in
                self.adjust(transition: transition, in: modality.viewController)
                return baseVC.rx.present(viewController: modality.viewController, animated: animated)
            }
            .do(onSuccess: { [unowned self] _ in
                if let modalVC = modality.viewController as? TransparentModalViewController {
                    let lastVC: UIViewController? = {
                        if self.stack.count == 0 {
                            return UIApplication.shared.keyWindow?.rootViewController
                        }
                        return self.stack[self.stack.count - 1].viewController
                    }()

                    if let view = lastVC?.view {
                        modalVC.nextViewForHitTest = view
                    }
                }

                self.stack.append(modality)
            })
    }

    private func dismissFrontViewController(animated: Bool) -> Single<Void> {
        return frontViewController()
            .do(onSuccess: { [unowned self] viewController in
                if self.stack.last?.viewController != viewController {
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

    private func viewController(for modalityType: T) throws -> UIViewController {
        return try modalityType.modalityPresentableType.viewController(for: modalityType)
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
