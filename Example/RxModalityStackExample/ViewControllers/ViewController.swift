//
//  ViewController.swift
//  ModalPresenter
//
//  Created by Chope on 2017. 5. 12..
//  Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxSwift
import RxModalityStack

class ViewController: ToolViewController {
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        Modal.shared.stackEvent
            .filter {
                switch $0 {
                case .presented, .dismissed:
                    return true
                default:
                    return false
                }
            }
            .map { _ in
                return Modal.shared.stack.map { $0.type }
            }
            .subscribe(onNext: { event in
                print(event)
            })
            .disposed(by: disposeBag)
    }
}

public extension BackgroundColorAlphaAnimation {
    public var color: UIColor {
        return UIColor.black
    }
    public var alpha: CGFloat {
        return 0.6
    }
}