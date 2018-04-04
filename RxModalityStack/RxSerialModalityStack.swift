//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class RxSerialModalityStack<T: ModalityType, D: ModalityData>: RxModalityStackType {
    public var queue: RxTaskQueue = RxSerialTaskQueue()
    public let changedStack: PublishSubject<[Modality<T, D>]> = PublishSubject()

    public private(set) var stack: [Modality<T, D>] = [] {
        didSet {
            guard oldValue != stack else { return }
            changedStack.onNext(stack)
        }
    }
    private var isExecutingAction: Bool = false
    private var taskObservable: Observable<Void> = Observable.empty()
    private var transitionDelegates: [UIViewController: UIViewControllerTransitioningDelegate] = [:]

    public init() {}

    public func present(_ modalityType: T, with data: D, animated: Bool) -> Single<Modality<T, D>> {
        return Single<Modality<T, D>>
            .create { [unowned self] observer in
                do {
                    let vc = try self.viewController(for: modalityType, with: data)
                    let transition = try modalityType.modalityPresentableType.transition(for: modalityType, with: data)
                    let modality = Modality(type: modalityType, data: data, transition: transition, viewController: vc)
                    observer(.success(modality))
                } catch let e {
                    observer(.error(e))
                }
                return Disposables.create()
            }
            .flatMap { [unowned self] modality in
                let single = self.present(modality, onFrontViewControllerWithAnimated: animated, transition: modality.transition)
                return self.queue.add(single: single)
            }
    }

    public func dismissFront(animated: Bool) -> Single<Modality<T, D>> {
        let single = dismissFrontViewController(animated: animated)
        return queue.add(single: single)
    }

    public func dismiss(_ modalityType: T, animated: Bool) -> Single<Modality<T, D>> {
        return queue.add(single: _dismiss(modalityType))
    }

    private func _dismiss(_ modalityType: T) -> Single<Modality<T, D>> {
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
            .map { [unowned self] index -> (index: Int, reorderedViewController: ArraySlice<Modality<T, D>>) in
                if index < (self.stack.count - 1) {
                    let range: Range<Int> = (index + 1)..<self.stack.count
                    return (index, self.stack[range])
                }
                return (index, [])
            }
            .flatMap { [unowned self] (index, reorderModality) -> Single<Modality<T, D>> in
                var concatObservable: Observable<Modality<T, D>> = Observable.empty()

                if reorderModality.count == 0 {
                    concatObservable = concatObservable.concat(self.dismissFrontViewController(animated: true))
                } else {
                    for _ in (0..<(reorderModality.count + 1)) {
                        concatObservable = concatObservable.concat(self.dismissFrontViewController(animated: false))
                    }
                }

                reorderModality
                    .forEach { [unowned self] (modality: Modality<T, D>) in
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

    public func bring(toFront: T) -> Single<Modality<T, D>> {
        return Single<Void>
            .create { [unowned self] observer in
                let modalities = self.modality(of: toFront)
                if modalities.count > 1 {
                    observer(.error(RxModalityStackTypeError.tooManyTypesInStack))
                    return Disposables.create()
                }
                observer(.success(Void()))
                return Disposables.create()
            }
            .flatMap { [unowned self] _ -> Single<Modality<T, D>> in
                self._dismiss(toFront)
            }
            .flatMap { [unowned self] modality -> Single<Modality<T, D>> in
                return self.present(modality, onFrontViewControllerWithAnimated: false, transition: .ignore)
            }
    }

    public func isPresented(modalityType: T, onlyType: Bool) -> Bool {
        if onlyType {
            return stack.contains { (modality: Modality<T, D>) in
                modality.type ~= modalityType
            }
        }
        return modality(of: modalityType).count > 0
    }

    public func modality(at index: Int) -> Modality<T, D>? {
        guard stack.count > index else { return nil }
        return stack[index]
    }

    public func modality(of type: T) -> [Modality<T, D>] {
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
    private func present(_ modality: Modality<T, D>, onFrontViewControllerWithAnimated animated: Bool, transition: ModalityTransition) -> Single<Modality<T, D>> {
        return frontViewController()
            .observeOn(MainScheduler.instance)
            .flatMap { [unowned self] (baseVC: UIViewController) -> Single<Void> in
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
            .map { _ in
                return modality
            }
    }

    private func dismissFrontViewController(animated: Bool) -> Single<Modality<T, D>> {
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
            .map { [unowned self] _ in
                return self.stack.removeLast()
            }
    }

    private func viewController(for modalityType: T, with data: D) throws -> (UIViewController & ModalityPresentable) {
        return try modalityType.modalityPresentableType.viewController(for: modalityType, with: data)
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
