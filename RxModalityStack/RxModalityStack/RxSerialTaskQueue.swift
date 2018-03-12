//
// Created by Chope on 2018. 3. 7..
// Copyright (c) 2018 Chope. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class RxSerialTaskQueue: RxTaskQueue {
    private struct Task {
        let uuid: String
        let observable: Single<Any>
    }
    private struct Result {
        let uuid: String
        let value: Any?
        let error: Error?
    }

    private var observable: Observable<Any> = Observable.empty()
    private var disposeBagForExecuting = DisposeBag()
    private var disposeBag = DisposeBag()

    private let isExecuting: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    private let actionQueue: PublishSubject<Task> = PublishSubject()
    private let completionSubject: PublishSubject<Result> = PublishSubject()


    public init() {
        configure()
    }

    public func add<T>(single: Single<T>) -> Single<T> {
        let uuid: String = UUID().uuidString
        let task = Task(uuid: uuid, observable: single.map { $0 as Any })

        actionQueue.onNext(task)

        return completionSubject
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
        Observable.zip(
                isExecuting
                    .distinctUntilChanged()
                    .filter { $0 == false }
                    .debug(),
                actionQueue
                    .buffer(timeSpan: 1, count: 10, scheduler: MainScheduler.instance)
                    .filter { $0.count > 0 }
            ) { return $1 }
            .debug()
            .subscribe(onNext: { [weak self] (tasks: [Task]) in
                self?.execute(tasks: tasks)
            })
            .disposed(by: disposeBag)
    }

    private func execute(tasks: [Task]) {
        guard tasks.count > 0 else { return }
        guard isExecuting.value == false else {
            assertionFailure()
            return
        }

        isExecuting.accept(true)

        var observable = Observable<Any>.create { [weak self] observer in
            self?.isExecuting.accept(true)
            observer.onNext(Void())
            observer.onCompleted()
            return Disposables.create()
        }

        for task in tasks {
            let taskObservable: Single<Any> = task.observable
                .debug()
                .do(
                    onSuccess: { [weak self] value in
                        let result = Result(uuid: task.uuid, value: value, error: nil)
                        self?.completionSubject.onNext(result)
                    },
                    onError: { [weak self] error in
                        let result = Result(uuid: task.uuid, value: nil, error: error)
                        self?.completionSubject.onNext(result)
                    }
                )
                .asObservable().timeout(10, scheduler: MainScheduler.instance).asSingle()
            observable = observable.concat(taskObservable)
        }

        observable
            .debug()
            .subscribe(onDisposed: { [weak self] in
                self?.isExecuting.accept(false)
            })
            .disposed(by: disposeBagForExecuting)

        self.observable = observable
    }
}
