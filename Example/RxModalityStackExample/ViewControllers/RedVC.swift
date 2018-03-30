//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit
import QuartzCore
import RxModalityStack

class RedVC: ToolViewController, ModalityPresentable {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        return gradientLayer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.layer.addSublayer(gradientLayer)

        view.bringSubview(toFront: toolView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width * 2, height: view.bounds.height)
        contentView.frame.size = scrollView.contentSize
        gradientLayer.frame = contentView.bounds
    }

    class func viewController<T: ModalityType>(for type: T) throws -> UIViewController {
        return RedVC()
    }
}
