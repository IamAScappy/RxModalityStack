//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

class GreenVC: ToolViewController {
    let contentView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    let button: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Touch me", for: .normal)
        view.setTitle("Don't touch me", for: .highlighted)
        view.setTitleColor(UIColor.blue, for: .normal)
        view.setTitleColor(UIColor.red, for: .highlighted)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(contentView)
        contentView.addSubview(button)

        contentView.backgroundColor = UIColor.green
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        contentView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        button.frame = contentView.bounds
    }
}