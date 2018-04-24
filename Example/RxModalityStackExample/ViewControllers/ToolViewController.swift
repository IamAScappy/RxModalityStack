//
// Created by Chope on 2018. 4. 24..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit
import RxModalityStack

class ToolViewController: UIViewController {
    let toolView: UIView = ToolView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(toolView)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        toolView.frame.size.height = 120
        toolView.frame.size.width = view.bounds.size.width
        toolView.frame.origin.y = view.bounds.size.height - toolView.frame.size.height
    }
}