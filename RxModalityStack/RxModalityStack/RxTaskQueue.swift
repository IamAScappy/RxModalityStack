//
// Created by Chope on 2018. 3. 7..
// Copyright (c) 2018 Chope. All rights reserved.
//

import Foundation
import RxSwift

public enum RxTaskQueueError: Error {
    case illegalType
    case emptyValue
}

public protocol RxTaskQueue {
    func add<T>(single: Single<T>) -> Single<T>
    func cancelAll()
}