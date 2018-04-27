//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import RxModalityStack
import RxSwift

class BlueVC: TouchPassthroughModalViewController, OutsideTouchable, ModalPresentable {
    private let contentView = UIView()
    private let toolView: UIView = ToolView()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(contentView)
        view.addSubview(toolView)

        contentView.backgroundColor = .blue
        contentView.isUserInteractionEnabled = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width = view.bounds.width / 2.0
        let height = view.bounds.height / 2.0
        contentView.frame.size = CGSize(width: width, height: height)

        let x = (view.bounds.width - width) / 2
        let y = (view.bounds.height - height) / 2
        contentView.frame.origin = CGPoint(x: x, y: y)

        toolView.frame.size.height = 120
        toolView.frame.size.width = view.bounds.size.width
        toolView.frame.origin.y = view.bounds.size.height - toolView.frame.size.height
    }

    func onTouchOutside() {
        _ = Modal.shared.dismiss(self, animated: true).subscribe()
    }

    class func viewControllerOf(_ modal: Modal, with data: ModalData) -> (UIViewController & ModalityPresentable)? {
        return BlueVC()
    }

    class func transitionOf(_ modal: Modal, with data: ModalData) -> ModalityTransition? {
        return .slideUpDown
    }
}
