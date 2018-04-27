//
// Created by Chope on 2018. 4. 24..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

open class TouchPassthroughModalViewController: UIViewController {
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .overFullScreen
    }

    open override func loadView() {
        super.loadView()
        view = TouchPassthroughView()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (view as? TouchPassthroughView)?.nextViewForHitTest = presentingViewController?.view
    }
}
