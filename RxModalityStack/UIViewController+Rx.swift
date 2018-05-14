//
// Created by Chope on 2018. 3. 6..
// Copyright (c) 2018 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public enum TransitionState {
    case presenting
    case dismissing
    case completed
}

public extension Reactive where Base: UIViewController {
    public func present(viewController: UIViewController, animated: Bool) -> Observable<TransitionState> {
        return Observable.create { observer in
            observer.onNext(.presenting)

            self.base.present(viewController, animated: animated) {
                observer.onNext(.completed)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    public func dismiss(animated: Bool) -> Observable<TransitionState> {
        return Observable.create { observer in
            observer.onNext(.dismissing)

            if self.base.presentingViewController == nil {
                observer.onNext(.completed)
                observer.onCompleted()
            } else {
                self.base.dismiss(animated: animated) {
                    observer.onNext(.completed)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}