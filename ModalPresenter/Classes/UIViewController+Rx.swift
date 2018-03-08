//
// Created by Chope on 2018. 3. 6..
// Copyright (c) 2018 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    func present(viewController: UIViewController, animated: Bool) -> Single<Void> {
        return Single.create { observer in
            self.base.present(viewController, animated: animated) {
                observer(.success(Void()))
            }
            return Disposables.create()
        }
    }

    func dismiss(animated: Bool) -> Single<Void> {
        return Single.create { observer in
            self.base.dismiss(animated: animated) {
                observer(.success(Void()))
            }
            return Disposables.create()
        }
    }
}