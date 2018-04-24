//
// Created by Chope on 2018. 4. 24..
// Copyright (c) 2018 Chope Industry. All rights reserved.
//

import UIKit

open class TouchPassthroughModalViewController: TransparentModalViewController {
    open override func loadView() {
        super.loadView()
        view = TouchPassthroughView()
        (view as? TouchPassthroughView)?.nextViewForHitTest = presentingViewController?.view
    }
}
