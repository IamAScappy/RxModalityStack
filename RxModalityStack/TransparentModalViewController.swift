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
        modalPresentationStyle = .overFullScreen
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .overFullScreen
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        if let _ = self as? OutsideTouchable {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
            tapGestureRecognizer.cancelsTouchesInView = true
            view.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: view)

        guard view.subviews.contains(where: { $0.frame.contains(point) }) == false else { return }
        guard let touchable = self as? OutsideTouchable else { return }

        touchable.onTouchOutside()
    }
}