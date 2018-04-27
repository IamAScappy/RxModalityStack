//
// Created by Chope on 2018. 3. 7..
// Copyright (c) 2018 Chope. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class RxTaskQueue: RxTaskQueueType {
    private struct Task {
        let uuid: String
        let observable: Single<Any>
    }
    private struct Result {
        let uuid: String
        let value: Any?
        let error: Error?
    }

    public let isExecuting: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    private var observable: Observable<Any> = Observable.empty()
    private var disposeBagForExecuting = DisposeBag()
    private var disposeBag = DisposeBag()

    private let actionQueue: PublishSubject<Task> = PublishSubject()
    private let completionSubject: PublishSubject<Result> = PublishSubject()


    public init() {
        configure()
    }

    public func add<T>(single: Single<T>) -> Single<T> {
        let uuid: String = UUID().uuidString
        let task = Task(uuid: uuid, observable: single.map { $0 as Any })

        return completionSubject
            .do(onSubscribed: { [weak self] in
                self?.actionQueue.onNext(task)
            })
            .filter { $0.uuid == uuid }
            .do(onNext: {
                if let error = $0.error {
                    throw error
                }
                if $0.value == nil {
                    throw RxTaskQueueError.emptyValue
                }
            })
            .map { result in
                guard let resultValue = result.value as? T else {
                    throw RxTaskQueueError.illegalType
                }
                return resultValue
            }
            .take(1)
            .asSingle()
    }

    public func cancelAll() {
        disposeBag = DisposeBag()
        disposeBagForExecuting = DisposeBag()

        isExecuting.accept(false)

        configure()
    }

    private func configure() {
        let executable: Observable<Bool> = isExecuting
            .distinctUntilChanged()
            .filter { $0 == false }
        Observable.zip(executable, actionQueue) { return $1 }
            .flatMap { [weak self] (task: Task) -> Observable<Any> in
                guard let ss = self else {
                    return .empty()
                }
                return ss.execute(task: task)
                    .catchError { error in
                        return .just(Void())
                    }
                    .asObservable()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func execute(task: Task) -> Single<Any> {
        return Single<Void>
            .create { [weak self] observer in
                guard let ss = self else {
                    observer(.error(RxTaskQueueError.selfIsNil))
                    return Disposables.create()
                }
                guard ss.isExecuting.value == false else {
                    assertionFailure()
                    observer(.error(RxTaskQueueError.alreadyExecuting))
                    return Disposables.create()
                }

                ss.isExecuting.accept(true)

                observer(.success(Void()))
                return Disposables.create()
            }
            .flatMap { _ in
                return task.observable
            }
            .do(
                onSuccess: { [weak self] value in
                    let result = Result(uuid: task.uuid, value: value, error: nil)
                    self?.completionSubject.onNext(result)
                },
                onError: { [weak self] error in
                    let result = Result(uuid: task.uuid, value: nil, error: error)
                    self?.completionSubject.onNext(result)
                },
                onDispose: { [weak self] in
                    self?.isExecuting.accept(false)
                }
            )
    }
}
