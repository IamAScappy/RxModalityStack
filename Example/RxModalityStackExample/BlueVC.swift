//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

class BlueVC: ToolViewController {
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(contentView)

        contentView.backgroundColor = .blue
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width = view.bounds.width / 2.0
        let height = view.bounds.height / 2.0
        contentView.frame.size = CGSize(width: width, height: height)

        let x = (view.bounds.width - width) / 2
        let y = (view.bounds.height - height) / 2
        contentView.frame.origin = CGPoint(x: x, y: y)
    }
}
