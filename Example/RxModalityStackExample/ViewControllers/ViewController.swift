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
            .debug()
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