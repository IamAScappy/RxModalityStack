//
// Created by Chope on 2018. 3. 13..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class TransparentModalViewController: UIViewController {
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overCurrentContext
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .overCurrentContext
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let point = touches.first?.location(in: view) else { return }

        if view.hitTest(point, with: event) == view {
            onTouchOutside()
        }
    }

    open func onTouchOutside() {
        print("touch outside")
    }
}