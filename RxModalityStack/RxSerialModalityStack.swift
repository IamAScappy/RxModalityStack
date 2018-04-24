//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class RxSerialModalityStack<T: ModalityType, D: ModalityData>: RxModalityStackType {
    public var queue: RxTaskQueue = RxSerialTaskQueue()
    public let stackEvent: PublishSubject<StackEvent<Modality<T, D>>> = PublishSubject()

    public private(set) var stack: [Modality<T, D>] = [] {
        didSet {
            guard oldValue != stack else { return }

            let oldSet = Set(oldValue)
            let newSet = Set(stack)

            oldSet.subtracting(newSet).forEach {
                stackEvent.onNext(.dismissed($0))
            }
            newSet.subtracting(oldSet).forEach {
                stackEvent.onNext(.presented($0))
            }

            if stack.isEmpty {
                stackEvent.onNext(.empty)
            }
        }
    }
    private var isExecutingAction: Bool = false
    private var taskObservable: Observable<Void> = Observable.empty()
    private var transitionDelegates: [String: UIViewControllerTransitioningDelegate] = [:]

    public init() {}

    public func present(_ modalityType: T, with data: D, animated: Bool) -> Single<Modality<T, D>> {
        return Single<Modality<T, D>>
            .create { [unowned self] observer in
                do {
                    let vc = try self.viewController(for: modalityType, with: data)
                    let transition = try modalityType.modalityPresentableType.transition(for: modalityType, with: data)
                    let modality = Modality(id: UUID().uuidString, type: modalityType, data: data, transition: transition, viewController: vc)
                    observer(.success(modality))
                } catch let e {
                    observer(.error(e))
                }
                return Disposables.create()
            }
            .flatMap { [unowned self] modality -> Single<Modality<T, D>> in
                let single = self.present(modality, onFrontViewControllerWithAnimated: animated, transition: modality.transition)
                return self.queue.add(single: single)
            }
    }

    public func dismissFront(animated: Bool) -> Single<Modality<T, D>> {
        let single = dismissFrontViewController(animated: animated)
        return queue.add(single: single)
    }

    public func dismiss(_ viewController: UIViewController, animated: Bool) -> Single<Modality<T, D>> {
        return queue.add(single: _dismiss(viewController, animated: animated))
    }

    public func dismiss(_ id: String, animated: Bool) -> Single<Modality<T, D>> {
        return Single<Modality<T, D>>.create { [unowned self] observer in
            guard let modality = self.modality(of: id) else {
                observer(.error(RxModalityStackTypeError.invalidID))
                return Disposables.create()
            }

            observer(.success(modality))
            return Disposables.create()
        }
        .flatMap { [unowned self] modality in
            self.dismiss(modality.viewController, animated: animated)
        }
    }

    private func _dismiss(_ viewController: UIViewController, animated: Bool) -> Single<Modality<T, D>> {
        return Single<Int>
            .create { [unowned self] observer in
                guard let index = self.stack.index(where: { $0.viewController == viewController }) else {
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
                    concatObservable = concatObservable.concat(self.dismissFrontViewController(animated: animated))
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
        return Single<Int>
            .create { [unowned self] observer in
                observer(.success(self.stack.count))
                return Disposables.create()
            }
            .flatMap { [unowned self] count in
                guard count > 0 else {
                    return Single.just(Void())
                }

                var concatObservable: Observable<Modality<T, D>> = Observable.empty()

                for _ in (0..<count) {
                    concatObservable = concatObservable.concat(self.queue.add(single: self.dismissFrontViewController(animated: animated)))
                }

                let dismissSingle: Single<Void> = concatObservable.asSingle().map { _ in Void() }

                return self.queue.add(single: dismissSingle)
            }
    }

    public func dismissAll(except types: [T]) -> Single<Void> {
        return Single
            .create { [unowned self] observer in
                let result = self.stack.filter {
                    types.contains($0.type) == false
                }
                observer(.success(result))
                return Disposables.create()
            }
            .flatMap { [unowned self] (modalities: [Modality<T, D>]) -> Single<Void> in
                guard modalities.count > 0 else {
                    return .just(Void())
                }

                var concatObservable: Observable<Modality<T, D>> = Observable.empty()

                modalities.reversed().forEach { modality in
                    concatObservable = concatObservable.concat(self._dismiss(modality.viewController, animated: false).asObservable())
                }

                let dismissSingle: Single<Void> = concatObservable.asSingle().map { _ in Void() }

                return self.queue.add(single: dismissSingle)
            }
    }

    public func bringModality(toFront id: String) -> Single<Modality<T, D>> {
        return Single<Modality<T,D>>.create { [unowned self] observer in
                guard let modality = self.modality(of: id) else {
                    observer(.error(RxModalityStackTypeError.notExistsInStack))
                    return Disposables.create()
                }
                observer(.success(modality))
                return Disposables.create()
            }
            .flatMap { [unowned self] modality -> Single<Modality<T, D>> in
                return self.bringModality(toFront: modality)
            }
    }

    public func bringModality(toFront viewController: UIViewController) -> Single<Modality<T, D>> {
        return Single<Modality<T,D>>.create { [unowned self] observer in
                guard let modality = self.modality(of: viewController) else {
                    observer(.error(RxModalityStackTypeError.notExistsInStack))
                    return Disposables.create()
                }
                observer(.success(modality))
                return Disposables.create()
            }
            .flatMap { [unowned self] modality -> Single<Modality<T, D>> in
                return self.bringModality(toFront: modality)
            }
    }

    private func bringModality(toFront modality: Modality<T, D>) -> Single<Modality<T, D>> {
        return Single<Void>.just(Void())
            .flatMap { [unowned self] _ -> Single<Modality<T, D>> in
                _ = self.dismiss(modality.viewController, animated: false)
                return self.queue.add(single: self.present(modality, onFrontViewControllerWithAnimated: false, transition: .ignore))
            }
    }

    public func isPresented(_ type: T) -> Bool {
        return stack.contains { (modality: Modality<T, D>) in
            return modality.type == type
        }
    }

    public func isPresented(_ id: String) -> Bool {
        return stack.contains { (modality: Modality<T, D>) in
            return modality.id == id
        }
    }

    public func isPresented(_ viewController: UIViewController) -> Bool {
        return stack.contains { (modality: Modality<T, D>) in
            return modality.viewController == viewController
        }
    }

    public func modality(of id: String) -> Modality<T, D>? {
        return stack.filter { $0.id == id }.first
    }

    public func modality(of viewController: UIViewController) -> Modality<T, D>? {
        return stack.filter { $0.viewController == viewController }.first
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

    public func setToDismissed(_ id: String) -> Single<Void> {
        let single = Single<Void>.create { [unowned self] observer in
            self.stack = self.stack.filter {
                $0.id != id
            }
            observer(.success(Void()))
            return Disposables.create()
        }
        return queue.add(single: single)
    }

    public func setToDismissed(_ viewController: UIViewController) -> Single<Void> {
        let single = Single<Void>.create { [unowned self] observer in
            self.stack = self.stack.filter {
                $0.viewController != viewController
            }
            observer(.success(Void()))
            return Disposables.create()
        }
        return queue.add(single: single)
    }

    private func fixStack() -> Single<Void> {
        return Single.create { [unowned self] observer in
            self.stack = self.stack.filter {
                $0.viewController.presentingViewController != nil
            }
            observer(.success(Void()))
            return Disposables.create()
        }
    }

    // MARK: - present / dismiss viewController
    private func present(_ modality: Modality<T, D>, onFrontViewControllerWithAnimated animated: Bool, transition: ModalityTransition) -> Single<Modality<T, D>> {
        return fixStack()
            .flatMap { [unowned self] _ in
                return self.frontViewController()
            }
            .observeOn(MainScheduler.instance)
            .flatMap { [unowned self] (baseVC: UIViewController) -> Single<Void> in
                self.adjustTransition(in: modality)
                return baseVC.rx
                    .present(viewController: modality.viewController, animated: animated)
                    .do(onNext: { [unowned self] state in
                        switch state {
                        case .presenting:
                            self.stackEvent.onNext(.presenting(modality))
                        default:
                            break
                        }
                    })
                    .filter { $0 == .completed }
                    .take(1)
                    .map { _ in Void() }
                    .asSingle()
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
        return Single<Modality<T, D>>
            .create { [unowned self] observer in
                guard let modality = self.stack.last else {
                    observer(.error(RxModalityStackTypeError.stackIsEmpty))
                    return Disposables.create()
                }
                observer(.success(modality))
                return Disposables.create()
            }
            .observeOn(MainScheduler.instance)
            .flatMap { (modality: Modality<T, D>) in
                return modality.viewController.rx.dismiss(animated: animated)
                    .do(onNext: { [unowned self] state in
                        switch state {
                        case .dismissing:
                            self.stackEvent.onNext(.dismissing(modality))
                        case .completed:
                            self.transitionDelegates[modality.id] = nil
                        default:
                            break
                        }
                    })
                    .filter { $0 == .completed }
                    .take(1)
                    .map { _ in Void() }
                    .asSingle()
            }
            .map { [unowned self] _ in
                return self.stack.removeLast()
            }
    }

    private func viewController(for modalityType: T, with data: D) throws -> (UIViewController & ModalityPresentable) {
        return try modalityType.modalityPresentableType.viewController(for: modalityType, with: data)
    }

    // MARK: - Transition
    private func adjustTransition(in modality: Modality<T, D>) {
        switch modality.transition {
        case .ignore:
            return
        case .system:
            modality.viewController.transitioningDelegate = nil
        default:
            transitionDelegates[modality.id] = modality.transition.toDelegate()
            modality.viewController.transitioningDelegate = transitionDelegates[modality.id]
            modality.viewController.modalPresentationStyle = .custom
        }
    }
}
