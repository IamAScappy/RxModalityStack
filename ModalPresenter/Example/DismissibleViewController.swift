//
// Created by Chope on 2017. 5. 12..
// Copyright (c) 2017 Chope. All rights reserved.
//

import UIKit

class DismissibleViewController: UIViewController {
    var controlView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        controlView = createControlView()
        view.addSubview(controlView)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        controlView.frame.size.width = view.bounds.size.width
        controlView.frame.origin.y = view.bounds.size.height - controlView.frame.size.height
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(self): viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(self): viewWillDisappear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(self): viewDidAppear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(self): viewDidDisappear")
    }

    func createControlView() -> UIView? {
        let height: CGFloat = 100
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: height))
        view.backgroundColor = UIColor.black
        view.addSubview(createControlButton(title: "dismiss all", origin: CGPoint(x: 6, y: 6), action: #selector(self.dismissAll)))
        view.addSubview(createControlButton(title: "dismiss front", origin: CGPoint(x: 90, y: 6), action: #selector(self.dismissFront)))
        view.addSubview(createControlButton(title: "dismiss First", origin: CGPoint(x: 190, y: 6), action: #selector(self.dismissFirst)))
        view.addSubview(createControlButton(title: "first to front", origin: CGPoint(x: 6, y: 40), action: #selector(self.firstToFront)))
        return view
    }

    func createControlButton(title: String, origin: CGPoint, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.frame.origin = origin
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.sizeToFit()
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc func dismissAll() {
        ModalPresenter.shared.dismissAll(animated: true)
    }

    @objc func dismissFront() {
        ModalPresenter.shared.dismiss(animated: true)
    }

    @objc func dismissFirst() {
        guard let viewController = ModalPresenter.shared.viewController(at: 0) else { return }
        ModalPresenter.shared.dismiss(viewController: viewController, animated: true)
    }

    @objc func firstToFront() {
        guard let viewController = ModalPresenter.shared.viewController(at: 0) else { return }
        ModalPresenter.shared.moveToFront(viewController: viewController)
    }
}
