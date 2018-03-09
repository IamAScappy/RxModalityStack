//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

class GreenVC: ToolViewController {
    let contentView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .custom
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(contentView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        contentView.backgroundColor = UIColor.green
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        contentView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }

}
