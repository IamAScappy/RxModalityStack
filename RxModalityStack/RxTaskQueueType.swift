//
// Created by Chope on 2018. 3. 7..
// Copyright (c) 2018 Chope. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public enum RxTaskQueueError: Error {
    case illegalType
    case emptyValue
    case selfIsNil
    case alreadyExecuting
}

public protocol RxTaskQueueType {
    var isExecuting: BehaviorRelay<Bool> { get }

    func add<T>(single: Single<T>) -> Single<T>
    func cancelAll()
}